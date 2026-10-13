import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

import '../../support/api_fakes.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<SyncService> serviceAnswering(Future<http.Response> Function(http.Request) answer) async => SyncService(
        db: db,
        sender: CommandSender(ApiClient(baseUrl: testBaseUrl, tokens: await signedInTokens(), httpClient: MockClient(answer))),
      );

  Future<int> queue(String op, String id, Map<String, Object?> payload) =>
      db.syncQueueDao.enqueue(operationType: op, referenceId: id, warehouseId: 'w1', payload: jsonEncode(payload));

  Future<String> statusOf(int id) async => (await db.syncQueueDao.commandById(id))!.status;

  test('each task and alert command goes to its own endpoint with its own body', () async {
    await queue(SyncOps.taskCreate, 't1', {
      'title': 'Count aisle C',
      'body': {'id': 't1', 'title': 'Count aisle C', 'type': 'StockCount'},
    });
    await queue(SyncOps.taskAssign, 't1', {'title': 'Count aisle C', 'assigneeUserId': 'u2'});
    await queue(SyncOps.taskStart, 't1', {'title': 'Count aisle C'});
    await queue(SyncOps.taskComplete, 't1', {'title': 'Count aisle C'});
    await queue(SyncOps.alertRead, 'a1', {'title': 'New task'});
    final calls = <String>[];
    final bodies = <String, Object?>{};
    final service = await serviceAnswering((r) async {
      calls.add('${r.method} ${r.url.path}');
      if (r.body.isNotEmpty) bodies[r.url.path] = jsonDecode(r.body);
      return jsonResponse({});
    });

    expect(await service.flushQueue(), FlushOutcome.done);

    expect(calls, [
      'POST /api/warehouses/w1/tasks',
      'POST /api/warehouses/w1/tasks/t1/assign',
      'POST /api/warehouses/w1/tasks/t1/start',
      'POST /api/warehouses/w1/tasks/t1/complete',
      'POST /api/alerts/a1/read',
    ]);
    expect(bodies, {
      '/api/warehouses/w1/tasks': {'id': 't1', 'title': 'Count aisle C', 'type': 'StockCount'},
      '/api/warehouses/w1/tasks/t1/assign': {'assigneeUserId': 'u2'},
    });
  });

  test('a task the server no longer has is a conflict; an alert it no longer has is simply done', () async {
    final start = await queue(SyncOps.taskStart, 't9', {'title': 'Gone task'});
    final read = await queue(SyncOps.alertRead, 'a9', {'title': 'Gone alert'});
    final service = await serviceAnswering((r) async => r.url.path.contains('/tasks/')
        ? jsonResponse({'status': 404, 'code': 'task-not-found', 'title': 'Task not found'}, 404)
        : jsonResponse({'status': 404, 'code': 'alert-not-found', 'title': 'Alert not found'}, 404));

    expect(await service.flushQueue(), FlushOutcome.done);

    expect(await statusOf(start), 'conflicted');
    expect(await statusOf(read), 'synced');
  });

  test('a start for a task this phone created waits on that create, and says why when it was refused', () async {
    await queue(SyncOps.taskCreate, 't1', {
      'title': 'Count aisle C',
      'body': {'id': 't1', 'title': 'Count aisle C', 'type': 'StockCount', 'locationId': 'elsewhere'},
    });
    final start = await queue(SyncOps.taskStart, 't1', {'title': 'Count aisle C'});
    final calls = <String>[];
    final service = await serviceAnswering((r) async {
      calls.add(r.url.path);
      return jsonResponse({
        'status': 422,
        'title': 'One or more validation errors occurred.',
        'errors': {'locationId': ['Location is not in this warehouse.']},
      }, 422);
    });

    await service.flushQueue();

    expect(calls, ['/api/warehouses/w1/tasks']);
    final command = (await db.syncQueueDao.commandById(start))!;
    expect(command.status, 'failed');
    expect(command.lastError, contains('Not sent: the task was not created.'));
  });
}
