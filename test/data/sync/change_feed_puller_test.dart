import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/change_feed_puller.dart';

import '../../support/api_fakes.dart';

const w = '22222222-2222-4222-8222-222222222222';
const item = 'aaaaaaaa-0000-4000-8000-000000000001';
const bin = 'bbbbbbbb-0000-4000-8000-000000000001';
const count = 'cccccccc-0000-4000-8000-000000000001';

Map<String, dynamic> change(String entity, String id, int seq, [Map<String, dynamic>? data]) =>
    {'entity': entity, 'id': id, 'seq': seq, 'deleted': data == null, 'data': data};

Map<String, dynamic> page(List<Map<String, dynamic>> changes, {required int next, bool more = false}) =>
    {'nextCursor': next, 'hasMore': more, 'changes': changes};

void main() {
  late AppDatabase db;
  late List<String> cursorsAsked;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cursorsAsked = [];
  });
  tearDown(() => db.close());

  Future<ChangeFeedPuller> pullerServing(List<Object> answers) async => ChangeFeedPuller(
        db: db,
        client: ApiClient(
          baseUrl: testBaseUrl,
          tokens: await signedInTokens(),
          httpClient: MockClient((r) async {
            cursorsAsked.add(r.url.queryParameters['cursor']!);
            final answer = answers.removeAt(0);
            if (answer is Exception) throw answer;
            return http.Response(jsonEncode(answer), 200);
          }),
        ),
      );

  test('applies items, barcodes, locations and counts page by page, and remembers the cursor', () async {
    final puller = await pullerServing([
      page([
        change('item', item, 1, {'id': item, 'sku': 'WT-0001', 'name': 'Beras Wangi 10kg', 'uom': 'BAG', 'lowStockThreshold': 10, 'isActive': true}),
        change('itemBarcode', 'bc-1', 2, {'id': 'bc-1', 'itemId': item, 'code': '9556001000011'}),
        change('location', bin, 3, {'id': bin, 'warehouseId': w, 'code': 'A-01-01', 'type': 'Bin'}),
      ], next: 3, more: true),
      page([
        change('countSession', count, 4, {
          'id': count, 'warehouseId': w, 'createdByUserId': 'u1', 'label': 'Aisle A', 'status': 'Submitted',
          'submittedAt': '2026-10-11T00:12:00Z', 'reviewedByUserId': null, 'reviewedAt': null, 'rejectReason': null,
          'lines': [{'id': 'l1', 'itemId': item, 'locationId': bin, 'counted': 8, 'systemAtSubmit': 10, 'adjustment': null}],
        }),
        change('purchaseOrder', 'po-1', 5, {'id': 'po-1', 'warehouseId': w, 'number': 'PO-1', 'supplier': 'S', 'expectedDate': null, 'status': 'Open', 'lines': []}),
      ], next: 5),
    ]);

    final applied = await puller.pull(w);

    expect(applied, 5);
    expect(cursorsAsked, ['0', '3']);
    expect(await db.serverMirrorDao.cursorFor(w), 5);
    expect((await db.serverMirrorDao.itemByBarcode('9556001000011'))?.sku, 'WT-0001');
    expect((await db.serverMirrorDao.locationsFor(w)).single.code, 'A-01-01');
    final session = (await db.serverMirrorDao.countSessions(warehouseId: w)).single;
    expect(session.status, 'Submitted');
    expect((await db.serverMirrorDao.linesFor(count)).single.counted, 8);
  });

  test('deleted rows leave the copy, and the next pull starts from the stored cursor', () async {
    await (await pullerServing([
      page([change('location', bin, 7, {'id': bin, 'warehouseId': w, 'code': 'A-01-01', 'type': 'Bin'})], next: 7),
    ])).pull(w);

    await (await pullerServing([page([change('location', bin, 9)], next: 9)])).pull(w);

    expect(cursorsAsked, ['0', '7']);
    expect(await db.serverMirrorDao.locationsFor(w), isEmpty);
  });

  test('a page that cannot be fetched keeps everything applied before it', () async {
    final puller = await pullerServing([
      page([change('item', item, 1, {'id': item, 'sku': 'WT-0001', 'name': 'Beras', 'uom': 'BAG', 'lowStockThreshold': null, 'isActive': true})], next: 1, more: true),
      const ApiOfflineException(),
    ]);

    await expectLater(puller.pull(w), throwsA(isA<ApiOfflineException>()));

    expect(await db.serverMirrorDao.cursorFor(w), 1);
    expect((await db.serverMirrorDao.itemById(item))?.name, 'Beras');
  });

  test('item search matches SKU or name and leaves out inactive items', () async {
    await (await pullerServing([
      page([
        change('item', item, 1, {'id': item, 'sku': 'WT-0001', 'name': 'Beras Wangi 10kg', 'uom': 'BAG', 'lowStockThreshold': null, 'isActive': true}),
        change('item', 'old', 2, {'id': 'old', 'sku': 'WT-0099', 'name': 'Beras Lama', 'uom': 'BAG', 'lowStockThreshold': null, 'isActive': false}),
      ], next: 2),
    ])).pull(w);

    expect((await db.serverMirrorDao.searchItems('beras')).map((i) => i.sku), ['WT-0001']);
    expect((await db.serverMirrorDao.searchItems('wt-0001')).single.name, 'Beras Wangi 10kg');
  });

  test('signing out clears the copy, the cursor and the queue', () async {
    await (await pullerServing([
      page([change('location', bin, 7, {'id': bin, 'warehouseId': w, 'code': 'A-01-01', 'type': 'Bin'})], next: 7),
    ])).pull(w);
    await db.syncQueueDao.enqueue(operationType: 'count.submit', referenceId: count, payload: '{}');

    await db.clearServerData();

    expect(await db.serverMirrorDao.locationsFor(w), isEmpty);
    expect(await db.serverMirrorDao.cursorFor(w), 0);
    expect(await db.syncQueueDao.countPending(), 0);
  });

  test('a_page_arriving_after_sign_out_is_not_written_back', () async {
    final tokens = await signedInTokens();
    final puller = ChangeFeedPuller(
      db: db,
      client: ApiClient(
        baseUrl: testBaseUrl,
        tokens: tokens,
        httpClient: MockClient((r) async {
          await tokens.clear(); // signed out while this page was on its way
          return http.Response(jsonEncode(page([change('location', bin, 7, {'id': bin, 'warehouseId': w, 'code': 'A-01-01', 'type': 'Bin'})], next: 7)), 200);
        }),
      ),
    );

    await expectLater(puller.pull(w), throwsA(isA<SessionExpiredException>()));

    expect(await db.serverMirrorDao.locationsFor(w), isEmpty);
    expect(await db.serverMirrorDao.cursorFor(w), 0);
  });

  test('purchase orders arrive with their lines, and closed ones are left out', () async {
    await (await pullerServing([
      page([
        change('purchaseOrder', 'po-1', 1, {
          'id': 'po-1', 'warehouseId': w, 'number': 'PO-SA1-001', 'supplier': 'Gula Prai Trading', 'expectedDate': '2026-10-14', 'status': 'Partial',
          'lines': [{'id': 'pl-1', 'lineNo': 1, 'itemId': item, 'ordered': 10, 'received': 4}],
        }),
        change('purchaseOrder', 'po-2', 2, {
          'id': 'po-2', 'warehouseId': w, 'number': 'PO-SA1-002', 'supplier': 'Old', 'expectedDate': null, 'status': 'Closed', 'lines': [],
        }),
      ], next: 2),
    ])).pull(w);

    final orders = await db.serverMirrorDao.purchaseOrders(w);
    expect(orders.map((o) => o.number), ['PO-SA1-001']);
    expect(orders.single.expectedDate, DateTime(2026, 10, 14));
    final line = (await db.serverMirrorDao.poLinesFor('po-1')).single;
    expect((line.ordered, line.received), (10, 4));
  });

  test('a pull that reaches the end remembers which sent commands it has seen the result of', () async {
    final sent = await db.syncQueueDao.enqueue(operationType: 'receipt.create', referenceId: 'r1', warehouseId: w, payload: '{}');
    await db.syncQueueDao.markSynced(sent);
    final puller = await pullerServing([page([], next: 1, more: true), page([], next: 2)]);

    expect(await db.serverMirrorDao.caughtUpThrough(w), 0);
    await puller.pull(w);

    expect(await db.serverMirrorDao.caughtUpThrough(w), sent);
  });

  test('a_phone_on_an_older_mirror_reads_the_feed_again_from_the_start', () async {
    // What a 3a phone saved: cursor 40 under mirror version 1, which never stored purchase orders.
    await db.customStatement("INSERT INTO sync_cursors (warehouse_id, cursor, mirror_version) VALUES ('$w', 40, 1)");

    await (await pullerServing([page([], next: 40)])).pull(w);

    expect(cursorsAsked, ['0']);
    expect(await db.serverMirrorDao.cursorFor(w), 40); // saved again under the current version
  });
}
