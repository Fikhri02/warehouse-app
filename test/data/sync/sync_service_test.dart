import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

import '../../support/api_fakes.dart';

void main() {
  late AppDatabase db;
  late SyncService syncService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    syncService = SyncService(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('flushQueue marks all pending items as synced', () async {
    await db.syncQueueDao.enqueue(
      operationType: 'count_submit',
      referenceId: 's-1',
      payload: '{"sessionId":"s-1"}',
    );
    await db.syncQueueDao.enqueue(
      operationType: 'receive_submit',
      referenceId: 'po-1',
      payload: '{"poId":"po-1"}',
    );

    expect(await db.syncQueueDao.countPending(), 2);

    await syncService.flushQueue();

    expect(await db.syncQueueDao.countPending(), 0);
  });

  test('flushQueue is a no-op when queue is empty', () async {
    expect(await db.syncQueueDao.countPending(), 0);
    await syncService.flushQueue();
    expect(await db.syncQueueDao.countPending(), 0);
  });

  group('with the server', () {
    Future<SyncService> serviceAnswering(Future<http.Response> Function(http.Request) answer) async => SyncService(
          db: db,
          sender: CommandSender(ApiClient(baseUrl: testBaseUrl, tokens: await signedInTokens(), httpClient: MockClient(answer))),
        );

    Future<void> queueCount(String id, {String warehouse = 'w1'}) =>
        db.syncQueueDao.enqueue(operationType: SyncOps.countSubmit, referenceId: id, warehouseId: warehouse, payload: jsonEncode({'label': id, 'lines': []}));

    test('an_offline_flush_keeps_the_command_and_resends_it_with_the_same_key', () async {
      await queueCount('c1');
      final keys = <String>[];
      var online = false;
      final service = await serviceAnswering((r) async {
        keys.add(r.headers['Idempotency-Key']!);
        if (!online) throw http.ClientException('offline');
        return jsonResponse({'id': 'c1'});
      });

      expect(await service.flushQueue(), FlushOutcome.offline);
      expect(await db.syncQueueDao.countPending(), 1);

      online = true;
      expect(await service.flushQueue(), FlushOutcome.done);
      expect(await db.syncQueueDao.countPending(), 0);
      expect(keys.toSet(), hasLength(1)); // the server replays or finishes the first attempt instead of counting twice
    });

    test('a_refused_command_is_kept_with_its_reason_and_the_next_one_still_goes', () async {
      await queueCount('c1');
      await queueCount('c2');
      final sent = <String>[];
      final service = await serviceAnswering((r) async {
        sent.add(r.url.pathSegments[4]);
        return r.url.path.contains('/c1/')
            ? jsonResponse({'status': 409, 'code': 'session-already-reviewed', 'title': 'Count already reviewed', 'detail': 'This count was already approved.'}, 409)
            : jsonResponse({'id': 'c2'});
      });

      expect(await service.flushQueue(), FlushOutcome.done);

      expect(sent, ['c1', 'c2']);
      final issues = await db.syncQueueDao.watchIssues().first;
      expect(issues.single.referenceId, 'c1');
      expect(issues.single.status, 'conflicted');
      expect(ApiException.fromJson(jsonDecode(issues.single.lastError!) as Map<String, dynamic>).message, 'This count was already approved.');
    });

    test('server trouble stops the flush so later commands keep their order', () async {
      await queueCount('c1');
      await queueCount('c2');
      final sent = <String>[];
      final service = await serviceAnswering((r) async {
        sent.add(r.url.pathSegments[4]);
        return http.Response('', 503);
      });

      expect(await service.flushQueue(), FlushOutcome.serverTrouble);

      expect(sent, ['c1']);
      expect(await db.syncQueueDao.countPending(), 2);
    });

    test('an invalid command is marked failed and not sent again', () async {
      await queueCount('c1');
      var calls = 0;
      final service = await serviceAnswering((_) async {
        calls++;
        return jsonResponse({'status': 422, 'code': 'validation-failed', 'errors': {'lines.itemId': ['Unknown item.']}}, 422);
      });

      await service.flushQueue();
      await service.flushQueue();

      expect(calls, 1);
      expect((await db.syncQueueDao.watchIssues().first).single.status, 'failed');
    });
  });
}
