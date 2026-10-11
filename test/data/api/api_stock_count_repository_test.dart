import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/api/api_stock_count_repository.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide CountItem, CountSession, UserSession;
import 'package:warehouse_app/data/sync/command_sender.dart';

import '../../support/api_fakes.dart';

const w = '22222222-2222-4222-8222-222222222222';
const me = '11111111-1111-4111-8111-111111111111';
const beras = 'aaaaaaaa-0000-4000-8000-000000000001';
const bin = 'bbbbbbbb-0000-4000-8000-000000000001';

UserSession worker() => const UserSession(
      userId: me,
      name: 'Arjun Nair',
      email: 'arjun@waretrack.local',
      site: 'Shah Alam DC',
      role: UserRole.worker,
      token: 't',
      warehouseId: w,
      warehouses: [WarehouseMembership(warehouseId: w, code: 'SA1', name: 'Shah Alam DC', role: UserRole.worker)],
    );

void main() {
  late AppDatabase db;
  late int kicks;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    kicks = 0;
    await db.serverMirrorDao.upsertItem(CatalogItemsCompanion.insert(id: beras, sku: 'WT-0001', name: 'Beras Wangi 10kg', uom: 'BAG', isActive: true));
    await db.serverMirrorDao.upsertBarcode(CatalogBarcodesCompanion.insert(id: 'bc1', itemId: beras, code: '9556001000011'));
    await db.serverMirrorDao.upsertLocation(WarehouseLocationsCompanion.insert(id: bin, warehouseId: w, code: 'A-01-01', type: 'Bin'));
  });
  tearDown(() => db.close());

  Future<ApiStockCountRepository> repo([Future<http.Response> Function(http.Request)? answer]) async => ApiStockCountRepository(
        client: ApiClient(baseUrl: testBaseUrl, tokens: await signedInTokens(), httpClient: MockClient(answer ?? (_) async => http.Response('', 404))),
        db: db,
        session: worker,
        onQueued: () => kicks++,
      );

  test('barcode lookup uses the phone copy first, then asks the server for codes it has not seen', () async {
    final asked = <String>[];
    final counts = await repo((r) async {
      asked.add(r.url.path);
      return jsonResponse({
        'barcode': '9556001000028',
        'item': {'id': 'new-item', 'sku': 'WT-0002', 'name': 'Gula Pasir 1kg', 'uom': 'PKT', 'lowStockThreshold': null, 'isActive': true},
      });
    });

    expect((await counts.lookupItemByBarcode('9556001000011'))?.sku, 'WT-0001');
    expect(asked, isEmpty);
    expect((await counts.lookupItemByBarcode('9556001000028'))?.name, 'Gula Pasir 1kg');
    expect(asked, ['/api/catalog/barcodes/9556001000028']);
  });

  test('a_count_listing_an_item_twice_sends_one_line_with_the_total', () async {
    final counts = await repo();
    final session = CountSession(
      id: 'c0ffee00-0000-4000-8000-000000000001',
      location: 'A-01-01',
      locationId: bin,
      label: null,
      startedAt: DateTime(2026, 10, 11),
      status: CountSessionStatus.inProgress,
      items: [
        CountItem(itemId: beras, itemCode: 'WT-0001', itemName: 'Beras Wangi 10kg', expected: 0, counted: 5),
        CountItem(itemId: beras, itemCode: 'WT-0001', itemName: 'Beras Wangi 10kg', expected: 0, counted: 3),
      ],
    );

    await counts.submitSession(session);

    final queued = (await db.syncQueueDao.getPendingItems()).single;
    expect(queued.operationType, SyncOps.countSubmit);
    expect(queued.referenceId, session.id);
    expect(queued.warehouseId, w);
    expect(jsonDecode(queued.payload), {
      'label': 'A-01-01', // no label given: the location names it for the reviewer
      'lines': [{'itemId': beras, 'locationId': bin, 'counted': 8}],
    });
    expect(kicks, 1);
  });

  test('recent counts show what is waiting, what was refused and what the supervisor decided', () async {
    final counts = await repo();
    await db.syncQueueDao.enqueue(operationType: SyncOps.countSubmit, referenceId: 'queued', warehouseId: w, payload: jsonEncode({'label': 'Cold room', 'lines': [{}, {}]}));
    await db.syncQueueDao.enqueue(operationType: SyncOps.countSubmit, referenceId: 'refused', warehouseId: w, payload: jsonEncode({'label': 'Dock', 'lines': [{}]}));
    final refused = (await db.syncQueueDao.getPendingItems()).last;
    await db.syncQueueDao.markFailed(refused.id, const ApiException(status: 422, errors: {'lines.itemId': ['Unknown item.']}));
    await db.serverMirrorDao.upsertCountSession(
      RemoteCountSessionsCompanion.insert(id: 'done', warehouseId: w, createdByUserId: me, status: 'Rejected', submittedAt: DateTime(2026, 10, 10), rejectReason: const Value('Count the back row too')),
      [],
    );

    final recent = await counts.getRecentCounts();

    expect(recent.map((c) => c.progress), [CountProgress.notAccepted, CountProgress.sending, CountProgress.rejected]);
    expect(recent[0].note, 'Unknown item.');
    expect(recent[1].lineCount, 2);
    expect(recent[2].note, 'Count the back row too');
  });
}
