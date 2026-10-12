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

    Future<void> queueReceipt(String receiptId, {bool signed = true}) async {
      await db.syncQueueDao.enqueue(
        operationType: SyncOps.receiptCreate,
        referenceId: receiptId,
        warehouseId: 'w1',
        payload: jsonEncode({
          'purchaseOrderId': 'po-1',
          'lines': [{'poLineId': 'pl-1', 'locationId': 'bin-1', 'quantity': 4}],
          'receivedAt': '2026-10-12T01:00:00.000Z',
        }),
      );
      if (signed) {
        await db.syncQueueDao.enqueue(
          operationType: SyncOps.receiptSignature,
          referenceId: receiptId,
          warehouseId: 'w1',
          payload: jsonEncode({'png': base64Encode([0x89, 0x50, 0x4E, 0x47, 1, 2, 3])}),
        );
      }
    }

    test('a receipt and then its signature go to their own endpoints', () async {
      await queueReceipt('r1');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add('${r.method} ${r.url.path}');
        if (r.method == 'POST') {
          expect(jsonDecode(r.body), {
            'receiptId': 'r1',
            'lines': [{'poLineId': 'pl-1', 'locationId': 'bin-1', 'quantity': 4}],
            'receivedAt': '2026-10-12T01:00:00.000Z',
          });
        }
        return jsonResponse({'id': 'r1'});
      });

      expect(await service.flushQueue(), FlushOutcome.done);

      expect(calls, ['POST /api/warehouses/w1/purchase-orders/po-1/receipts', 'PUT /api/warehouses/w1/receipts/r1/signature']);
    });

    test('every command carries the phone clock, so the server can correct a phone set to the wrong time', () async {
      await queueCount('s1');
      await queueReceipt('r1');
      final sent = <String?>[];
      final service = await serviceAnswering((r) async {
        sent.add(r.headers['X-Client-Time']);
        return jsonResponse({'id': 'x'});
      });
      final before = DateTime.now().toUtc().subtract(const Duration(seconds: 1));

      await service.flushQueue();

      expect(sent, hasLength(3));
      for (final value in sent) {
        expect(value, isNotNull);
        final time = DateTime.parse(value!);
        expect(time.isUtc, isTrue);
        expect(time.isAfter(before), isTrue);
      }
    });

    Future<void> queueOrder(String id, {String kind = 'Delivery', String status = 'Submitted'}) async {
      final save = await db.syncQueueDao.enqueue(
        operationType: SyncOps.orderSave,
        referenceId: id,
        warehouseId: 'w1',
        payload: jsonEncode({
          'kind': kind,
          'body': {'number': 'DO-1', 'destination': 'Outlet', 'deliveryDate': '2026-10-13', 'requiresApproval': false, 'notes': null, 'lines': []},
        }),
      );
      await db.syncQueueDao.enqueue(
        operationType: SyncOps.orderStatus,
        referenceId: id,
        warehouseId: 'w1',
        payload: jsonEncode({'kind': kind, 'status': status, 'changedAt': '2026-10-12T02:00:00.000Z', 'number': 'DO-1', 'afterSave': save}),
      );
    }

    test('a status for an order the server already has is not held by an older refused save', () async {
      await queueOrder('o1');
      for (final command in await db.syncQueueDao.getPendingItems()) {
        await db.syncQueueDao.markFailed(command.id, const ApiException(status: 409, title: 'Order already dispatched'));
      }
      // Later, after a pull shows the order In Transit, the person marks it Shipped.
      await db.syncQueueDao.enqueue(
        operationType: SyncOps.orderStatus,
        referenceId: 'o1',
        warehouseId: 'w1',
        payload: jsonEncode({'kind': 'Delivery', 'status': 'Shipped', 'changedAt': '2026-10-12T03:00:00.000Z', 'number': 'DO-1'}),
      );
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add('${r.method} ${r.url.path}');
        return jsonResponse({'id': 'o1'});
      });

      await service.flushQueue();

      expect(calls, ['POST /api/warehouses/w1/delivery-orders/o1/status']);
    });

    test('an order is saved and then moved on, each at its own endpoint', () async {
      await queueOrder('o1');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add('${r.method} ${r.url.path}');
        if (r.method == 'PUT') expect((jsonDecode(r.body) as Map)['destination'], 'Outlet');
        if (r.method == 'POST') expect(jsonDecode(r.body), {'status': 'Submitted', 'changedAt': '2026-10-12T02:00:00.000Z'});
        return jsonResponse({'id': 'o1'});
      });

      expect(await service.flushQueue(), FlushOutcome.done);

      expect(calls, ['PUT /api/warehouses/w1/delivery-orders/o1', 'POST /api/warehouses/w1/delivery-orders/o1/status']);
    });

    test('a sales order goes to the sales endpoints', () async {
      await queueOrder('o2', kind: 'Sales');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add('${r.method} ${r.url.path}');
        return jsonResponse({'id': 'o2'});
      });

      await service.flushQueue();

      expect(calls, ['PUT /api/warehouses/w1/sales-orders/o2', 'POST /api/warehouses/w1/sales-orders/o2/status']);
    });

    test('a status change for an order the server refused says why', () async {
      await queueOrder('o1');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add(r.method);
        return jsonResponse({'status': 422, 'title': 'One or more validation errors occurred.'}, 422);
      });

      await service.flushQueue();

      expect(calls, ['PUT']);
      final issues = await db.syncQueueDao.watchIssues().first;
      expect(issues.map((i) => i.operationType), [SyncOps.orderStatus, SyncOps.orderSave]);
      expect(ApiException.fromJson(jsonDecode(issues.first.lastError!) as Map<String, dynamic>).message, contains('the order was not saved'));
    });

    test('a status change goes once a later save of its order went through', () async {
      await queueOrder('o1');
      final firstSave = (await db.syncQueueDao.getPendingItems()).first;
      await db.syncQueueDao.markFailed(firstSave.id, const ApiException(status: 422, title: 'Bad number'));
      await queueOrder('o1'); // the person fixed the order: a second save, then the status change again
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add(r.method);
        return jsonResponse({'id': 'o1'});
      });

      await service.flushQueue();

      // The first status change looks at the save queued just before it (refused) and is held with a reason; the
      // second save and its status change go.
      expect(calls, ['PUT', 'POST']);
      final issues = await db.syncQueueDao.watchIssues().first;
      expect(issues.map((i) => i.operationType), [SyncOps.orderStatus, SyncOps.orderSave]);
    });

    test('a_signature_whose_receipt_was_refused_says_why', () async {
      await queueReceipt('r1');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add(r.method);
        return jsonResponse({'status': 409, 'code': 'po-closed', 'title': 'Purchase order is closed', 'detail': 'PO-SA1-001 is closed; nothing more can be received against it.'}, 409);
      });

      await service.flushQueue();

      expect(calls, ['POST']); // the signature was never sent to a receipt that doesn't exist
      final issues = await db.syncQueueDao.watchIssues().first;
      expect(issues.map((i) => i.operationType), [SyncOps.receiptSignature, SyncOps.receiptCreate]);
      expect(ApiException.fromJson(jsonDecode(issues.first.lastError!) as Map<String, dynamic>).message, contains('its receipt was not accepted'));
    });
  });
}
