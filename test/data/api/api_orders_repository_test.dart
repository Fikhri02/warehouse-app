import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/api/api_orders_repository.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/sync/command_sender.dart';

const w = '22222222-2222-4222-8222-222222222222';
const beras = 'aaaaaaaa-0000-4000-8000-000000000001';
const newId = '9f3c0000-0000-4000-8000-000000000001';

UserSession member(UserRole role) => UserSession(
      userId: 'u1',
      name: role == UserRole.worker ? 'Arjun Nair' : 'Hafiz Rahman',
      email: 'u1@waretrack.local',
      site: 'Shah Alam DC',
      role: role,
      token: 't',
      warehouseId: w,
      warehouses: [WarehouseMembership(warehouseId: w, code: 'SA1', name: 'Shah Alam DC', role: role)],
    );

RemoteOrdersCompanion order(String id, String status, {List<Map<String, String>>? history}) => RemoteOrdersCompanion.insert(
      id: id,
      warehouseId: w,
      kind: 'Delivery',
      number: 'DO-SA1-001',
      destination: const Value('Outlet Damansara'),
      orderDate: DateTime(2026, 10, 14),
      status: status,
      requiresApproval: status == 'PendingApproval',
      createdByName: 'Arjun Nair',
      createdAt: DateTime.utc(2026, 10, 12, 1),
      statusHistory: jsonEncode(history ??
          [
            {'status': 'Draft', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T01:00:00Z'},
            {'status': status, 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T01:05:00Z'},
          ]),
    );

void main() {
  late AppDatabase db;
  late UserSession session;
  late ApiOrdersRepository repo;
  late int kicks;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    session = member(UserRole.worker);
    kicks = 0;
    repo = ApiOrdersRepository(db: db, session: () => session, onQueued: () => kicks++);
    final dao = db.serverMirrorDao;
    await dao.upsertItem(CatalogItemsCompanion.insert(id: beras, sku: 'WT-0001', name: 'Beras Wangi 10kg', uom: 'BAG', isActive: true));
    await dao.upsertBarcode(CatalogBarcodesCompanion.insert(id: 'bc1', itemId: beras, code: '9556001000011'));
    await dao.upsertLocation(WarehouseLocationsCompanion.insert(id: 'dock-1', warehouseId: w, code: 'DOCK-1', type: 'Dock'));
    await dao.upsertLocation(WarehouseLocationsCompanion.insert(id: 'bin-1', warehouseId: w, code: 'A-01-01', type: 'Bin'));
    await dao.upsertOrder(order('do-1', 'Submitted'), [
      RemoteOrderLinesCompanion.insert(id: 'l1', orderId: 'do-1', itemId: beras, locationId: 'bin-1', quantity: 4),
    ]);
  });
  tearDown(() => db.close());

  test('orders come from the copy with item names, bins and who moved them', () async {
    final o = (await repo.getDeliveryOrders(active: true)).single;

    expect((o.orderNumber, o.destination, o.createdBy, o.status), ('DO-SA1-001', 'Outlet Damansara', 'Arjun Nair', OrderStatus.submitted));
    final line = o.items.single;
    expect((line.itemName, line.itemSku, line.quantity, line.locationCode), ('Beras Wangi 10kg', 'WT-0001', 4, 'A-01-01'));
    expect(o.statusHistory.map((h) => h.status), [OrderStatus.draft, OrderStatus.submitted]);
  });

  test('a new delivery needing approval is queued as a save and then a request for approval, and shows at once', () async {
    await repo.saveDeliveryOrder(DeliveryOrder(
      id: newId,
      orderNumber: '',
      destination: 'Outlet Cheras',
      deliveryDate: DateTime(2026, 10, 14),
      status: OrderStatus.pendingApproval,
      requiresApproval: true,
      createdBy: '',
      createdAt: DateTime.now(),
      items: const [OrderItem(itemId: beras, itemName: 'Beras Wangi 10kg', itemSku: 'WT-0001', quantity: 2, locationId: 'bin-1', locationCode: 'A-01-01')],
    ));

    final queued = await db.syncQueueDao.getPendingItems();
    expect(queued.map((q) => q.operationType), [SyncOps.orderSave, SyncOps.orderStatus]);
    final save = jsonDecode(queued[0].payload) as Map<String, dynamic>;
    final body = save['body'] as Map<String, dynamic>;
    expect(save['kind'], 'Delivery');
    expect(body['number'], matches(RegExp(r'^DO-\d{6}-9F3C0000$')));
    expect(body..remove('number'), {
      'destination': 'Outlet Cheras',
      'deliveryDate': '2026-10-14',
      'requiresApproval': true,
      'notes': null,
      'lines': [{'itemId': beras, 'locationId': 'bin-1', 'quantity': 2}],
    });
    expect((jsonDecode(queued[1].payload) as Map)['status'], 'PendingApproval');
    final shown = (await repo.getDeliveryOrderById(newId))!;
    expect((shown.status, shown.createdBy, shown.destination), (OrderStatus.pendingApproval, 'Arjun Nair', 'Outlet Cheras'));
    expect(kicks, 1);
  });

  test('two status changes made offline go in order, and the history is not doubled once the server has them', () async {
    await repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-1', status: OrderStatus.packed);
    await repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-1', status: OrderStatus.inTransit);

    var o = (await repo.getDeliveryOrderById('do-1'))!;
    expect(o.status, OrderStatus.inTransit);
    expect(o.statusHistory.map((h) => h.status), [OrderStatus.draft, OrderStatus.submitted, OrderStatus.packed, OrderStatus.inTransit]);

    final sent = await db.syncQueueDao.getPendingItems();
    for (final command in sent) {
      await db.syncQueueDao.markSynced(command.id);
    }
    await db.serverMirrorDao.upsertOrder(order('do-1', 'InTransit', history: [
      {'status': 'Draft', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T01:00:00Z'},
      {'status': 'Submitted', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T01:05:00Z'},
      {'status': 'Packed', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T02:00:00Z'},
      {'status': 'InTransit', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T02:10:00Z'},
    ]), [RemoteOrderLinesCompanion.insert(id: 'l1', orderId: 'do-1', itemId: beras, locationId: 'bin-1', quantity: 4)]);
    await db.serverMirrorDao.saveCursor(w, 9);
    await db.serverMirrorDao.markCaughtUp(w, through: sent.last.id);

    o = (await repo.getDeliveryOrderById('do-1'))!;
    expect(o.statusHistory, hasLength(4));
  });

  test('a dispatch the server refused leaves the order as the server has it', () async {
    await db.serverMirrorDao.upsertOrder(order('do-3', 'Packed'), [
      RemoteOrderLinesCompanion.insert(id: 'l3', orderId: 'do-3', itemId: beras, locationId: 'bin-1', quantity: 400),
    ]);
    await repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-3', status: OrderStatus.inTransit);
    expect((await repo.getDeliveryOrderById('do-3'))!.status, OrderStatus.inTransit);
    final command = (await db.syncQueueDao.getPendingItems()).single;

    await db.syncQueueDao.markConflicted(command.id, const ApiException(status: 409, title: 'Not enough stock to dispatch'));

    expect((await repo.getDeliveryOrderById('do-3'))!.status, OrderStatus.packed);
  });

  test('only a supervisor can approve', () async {
    await db.serverMirrorDao.upsertOrder(order('do-2', 'PendingApproval'), [
      RemoteOrderLinesCompanion.insert(id: 'l2', orderId: 'do-2', itemId: beras, locationId: 'bin-1', quantity: 1),
    ]);

    await expectLater(
      repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-2', status: OrderStatus.submitted),
      throwsA(isA<StateError>()),
    );
    expect(await db.syncQueueDao.getPendingItems(), isEmpty);

    session = member(UserRole.supervisor);
    await repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-2', status: OrderStatus.submitted);
    expect((await repo.getDeliveryOrderById('do-2'))!.status, OrderStatus.submitted);
  });

  test('a worker cannot lift approval from an order that needs it', () async {
    await db.serverMirrorDao.upsertOrder(order('do-4', 'Draft').copyWith(requiresApproval: const Value(true)), [
      RemoteOrderLinesCompanion.insert(id: 'l4', orderId: 'do-4', itemId: beras, locationId: 'bin-1', quantity: 1),
    ]);
    final draft = (await repo.getDeliveryOrderById('do-4'))!;

    await expectLater(
      repo.saveDeliveryOrder(draft.copyWith(requiresApproval: false, status: OrderStatus.submitted)),
      throwsA(isA<StateError>()),
    );
    expect(await db.syncQueueDao.getPendingItems(), isEmpty);
  });

  test('a status change names its order and the save it follows', () async {
    await repo.saveDeliveryOrder(DeliveryOrder(
      id: newId,
      orderNumber: 'DO-261012-9F3C0000',
      destination: 'Outlet Cheras',
      deliveryDate: DateTime(2026, 10, 14),
      status: OrderStatus.submitted,
      requiresApproval: false,
      createdBy: '',
      createdAt: DateTime.now(),
      items: const [OrderItem(itemId: beras, itemName: 'Beras Wangi 10kg', itemSku: 'WT-0001', quantity: 2, locationId: 'bin-1', locationCode: 'A-01-01')],
    ));
    await repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-1', status: OrderStatus.packed);

    final queued = await db.syncQueueDao.getPendingItems();
    final afterSave = jsonDecode(queued[1].payload) as Map<String, dynamic>;
    final onItsOwn = jsonDecode(queued[2].payload) as Map<String, dynamic>;
    expect((afterSave['number'], afterSave['afterSave']), ('DO-261012-9F3C0000', queued[0].id));
    expect((onItsOwn['number'], onItsOwn.containsKey('afterSave')), ('DO-SA1-001', false));
  });

  test('a line without a bin is not queued', () async {
    await expectLater(
      repo.saveDeliveryOrder(DeliveryOrder(
        id: newId,
        orderNumber: '',
        destination: 'Outlet',
        deliveryDate: DateTime(2026, 10, 14),
        status: OrderStatus.draft,
        requiresApproval: false,
        createdBy: '',
        createdAt: DateTime.now(),
        items: const [OrderItem(itemId: beras, itemName: 'Beras Wangi 10kg', itemSku: 'WT-0001')],
      )),
      throwsA(isA<StateError>()),
    );
    expect(await db.syncQueueDao.getPendingItems(), isEmpty);
  });

  test('items are found by barcode or SKU, and bins come before docks', () async {
    expect((await repo.findItem('9556001000011'))?.id, beras);
    expect((await repo.findItem('wt-0001'))?.id, beras);
    expect(await repo.findItem('NOPE'), isNull);
    expect((await repo.getPickLocations()).map((l) => l.name), ['A-01-01', 'DOCK-1']);
  });
}
