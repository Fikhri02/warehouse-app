import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_receiving_repository.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide CountItem, CountSession, PoLineItem, PurchaseOrder, UserSession;
import 'package:warehouse_app/data/sync/command_sender.dart';

const w = '22222222-2222-4222-8222-222222222222';
const beras = 'aaaaaaaa-0000-4000-8000-000000000001';
const dock = 'dddddddd-0000-4000-8000-000000000001';

UserSession worker() => const UserSession(
      userId: 'u1',
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
  late ApiReceivingRepository repo;
  late int kicks;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    kicks = 0;
    repo = ApiReceivingRepository(db: db, session: worker, onQueued: () => kicks++);
    final dao = db.serverMirrorDao;
    await dao.upsertItem(CatalogItemsCompanion.insert(id: beras, sku: 'WT-0001', name: 'Beras Wangi 10kg', uom: 'BAG', isActive: true));
    await dao.upsertBarcode(CatalogBarcodesCompanion.insert(id: 'bc1', itemId: beras, code: '9556001000011'));
    await dao.upsertLocation(WarehouseLocationsCompanion.insert(id: 'bin-1', warehouseId: w, code: 'A-01-01', type: 'Bin'));
    await dao.upsertLocation(WarehouseLocationsCompanion.insert(id: dock, warehouseId: w, code: 'DOCK-1', type: 'Dock'));
    await dao.upsertPurchaseOrder(
      RemotePurchaseOrdersCompanion.insert(id: 'po-1', warehouseId: w, number: 'PO-SA1-001', supplier: 'Gula Prai Trading', status: 'Partial', expectedDate: Value(DateTime(2026, 10, 14))),
      [RemotePoLinesCompanion.insert(id: 'pl-1', purchaseOrderId: 'po-1', lineNo: 1, itemId: beras, ordered: 10, received: 4)],
    );
  });
  tearDown(() => db.close());

  test('orders come from the phone copy with item names, barcodes and what is already received', () async {
    final order = (await repo.getPurchaseOrders()).single;

    expect(order.displayNumber, 'PO-SA1-001');
    expect(order.status, PoStatus.inProgress);
    final line = order.lineItems.single;
    expect((line.itemName, line.itemCode, line.expected, line.received, line.alreadyReceived), ('Beras Wangi 10kg', 'WT-0001', 10, 4, 4));
    expect(line.matches('9556001000011'), isTrue);
  });

  test('a receipt remembers when the goods arrived, for a phone that sends it later', () async {
    final order = (await repo.getPurchaseOrders()).single;
    final before = DateTime.now().toUtc();

    await repo.submitReceive(order.copyWithLines([order.lineItems.single.copyWith(received: 5)]), locationId: dock);

    final payload = jsonDecode((await db.syncQueueDao.getPendingItems()).single.payload) as Map<String, dynamic>;
    final receivedAt = DateTime.parse(payload['receivedAt'] as String);
    expect(receivedAt.isUtc, isTrue);
    expect(receivedAt.isBefore(before.subtract(const Duration(seconds: 1))), isFalse);
  });

  test('a receipt sends only what was added now, to the chosen location, then its signature', () async {
    final order = (await repo.getPurchaseOrders()).single;
    final receiving = order.copyWithLines([order.lineItems.single.copyWith(received: 7)]);

    await repo.submitReceive(receiving, signature: Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]), locationId: dock);

    final queued = await db.syncQueueDao.getPendingItems();
    expect(queued.map((q) => q.operationType), [SyncOps.receiptCreate, SyncOps.receiptSignature]);
    expect(queued[0].referenceId, queued[1].referenceId);
    final payload = jsonDecode(queued[0].payload) as Map<String, dynamic>;
    expect(payload..remove('receivedAt'), {
      'purchaseOrderId': 'po-1',
      'lines': [{'poLineId': 'pl-1', 'locationId': dock, 'quantity': 3}],
    });
    expect(base64Decode((jsonDecode(queued[1].payload) as Map)['png'] as String), [0x89, 0x50, 0x4E, 0x47]);
    expect(kicks, 1);
  });

  test('a receipt the server took still shows until the phone has pulled the order back', () async {
    final order = (await repo.getPurchaseOrders()).single;
    await repo.submitReceive(order.copyWithLines([order.lineItems.single.copyWith(received: 7)]), locationId: dock);
    final receipt = (await db.syncQueueDao.getPendingItems()).single;
    await db.syncQueueDao.markSynced(receipt.id);

    expect((await repo.getPurchaseOrders()).single.lineItems.single.alreadyReceived, 7);
  });

  test('once a pull that began after the receipt went has finished, the order comes from the server alone', () async {
    final order = (await repo.getPurchaseOrders()).single;
    await repo.submitReceive(order.copyWithLines([order.lineItems.single.copyWith(received: 7)]), locationId: dock);
    final receipt = (await db.syncQueueDao.getPendingItems()).single;
    await db.syncQueueDao.markSynced(receipt.id);

    await db.serverMirrorDao.upsertPurchaseOrder(
      RemotePurchaseOrdersCompanion.insert(id: 'po-1', warehouseId: w, number: 'PO-SA1-001', supplier: 'Gula Prai Trading', status: 'Partial'),
      [RemotePoLinesCompanion.insert(id: 'pl-1', purchaseOrderId: 'po-1', lineNo: 1, itemId: beras, ordered: 10, received: 7)],
    );
    await db.serverMirrorDao.saveCursor(w, 9);
    await db.serverMirrorDao.markCaughtUp(w, through: receipt.id);

    expect((await repo.getPurchaseOrders()).single.lineItems.single.alreadyReceived, 7);
  });

  test('a_queued_receipt_shows_on_the_order_until_the_server_has_it', () async {
    final order = (await repo.getPurchaseOrders()).single;
    await repo.submitReceive(order.copyWithLines([order.lineItems.single.copyWith(received: 10)]), locationId: dock);

    final again = (await repo.getPurchaseOrders()).single;

    expect(again.lineItems.single.received, 10);
    expect(again.lineItems.single.alreadyReceived, 10); // nothing more to receive here until the server says otherwise
    expect(again.status, PoStatus.received);
  });

  test('receiving_more_than_is_left_is_stopped_before_it_is_queued', () async {
    final order = (await repo.getPurchaseOrders()).single;

    await expectLater(
      repo.submitReceive(order.copyWithLines([order.lineItems.single.copyWith(received: 12)]), locationId: dock),
      throwsA(isA<StateError>().having((e) => e.message, 'message', contains('only 6 more'))),
    );
    expect(await db.syncQueueDao.countPending(), 0);
  });

  test('put-away locations list docks first', () async {
    expect((await repo.getPutAwayLocations()).map((l) => l.code), ['DOCK-1', 'A-01-01']);
  });
}
