@Tags(['live'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_orders_repository.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final api = Platform.environment['WARETRACK_API'];
final password = Platform.environment['WARETRACK_SEED_PASSWORD'] ?? 'Waretrack#2026';

/// One person's phone: its own copy, outbox and orders.
class Phone {
  Phone._(this.db, this.session, this.puller, this.outbox, this.orders);

  final AppDatabase db;
  final UserSession session;
  final ChangeFeedPuller puller;
  final SyncService outbox;
  final ApiOrdersRepository orders;

  static Future<Phone> signIn(String login) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final client = ApiClient(baseUrl: api!, httpClient: http.Client(), tokens: TokenStore(MemoryKeyValueStore()));
    final auth = ApiAuthRepository(client: client, db: db);
    var session = await auth.login('$login@waretrack.local', password);
    if (session.warehouseId == null) {
      session = await auth.selectWarehouse(session, session.warehouses.firstWhere((w) => w.code == 'SA1').warehouseId);
    }
    final UserSession current = session;
    final phone = Phone._(db, current, ChangeFeedPuller(client: client, db: db), SyncService(db: db, sender: CommandSender(client)),
        ApiOrdersRepository(db: db, session: () => current, onQueued: () {}));
    await phone.sync();
    return phone;
  }

  Future<void> sync() async {
    expect(await outbox.flushQueue(), FlushOutcome.done);
    expect(await db.syncQueueDao.watchIssues().first, isEmpty, reason: 'every command was accepted');
    await puller.pull(session.warehouseId!);
  }
}

void main() {
  test('a worker raises a delivery, a supervisor approves it, and it is packed, dispatched and shipped', () async {
    final worker = await Phone.signIn('arjun');
    final lead = await Phone.signIn('hafiz');
    final item = (await worker.orders.findItem('WT-0001'))!;
    final bin = (await worker.orders.getPickLocations()).firstWhere((l) => l.name == 'A-01-01');
    final id = const Uuid().v4();

    await worker.orders.saveDeliveryOrder(DeliveryOrder(
      id: id,
      orderNumber: '',
      destination: 'Outlet Damansara',
      deliveryDate: DateTime.now(),
      status: OrderStatus.pendingApproval,
      requiresApproval: true,
      createdBy: '',
      createdAt: DateTime.now(),
      items: [OrderItem(itemId: item.id, itemName: item.name, itemSku: item.sku, quantity: 1, locationId: bin.id, locationCode: bin.name)],
    ));
    await worker.sync();

    await lead.sync();
    expect((await lead.orders.getDeliveryOrderById(id))!.status, OrderStatus.pendingApproval);
    await lead.orders.updateOrderStatus(kind: OrderKind.delivery, id: id, status: OrderStatus.submitted);
    await lead.sync();

    await worker.sync();
    for (final next in [OrderStatus.packed, OrderStatus.inTransit, OrderStatus.shipped]) {
      await worker.orders.updateOrderStatus(kind: OrderKind.delivery, id: id, status: next);
    }
    await worker.sync();

    final shipped = (await worker.orders.getDeliveryOrderById(id))!;
    expect(shipped.status, OrderStatus.shipped);
    expect(shipped.statusHistory.map((h) => h.status), [
      OrderStatus.draft, OrderStatus.pendingApproval, OrderStatus.submitted, OrderStatus.packed, OrderStatus.inTransit, OrderStatus.shipped,
    ]);
    expect(shipped.statusHistory.map((h) => h.changedBy).toSet(), {'Arjun Nair', 'Hafiz Rahman'});
  }, skip: api == null ? 'Set WARETRACK_API=http://localhost:5050 (with the server running) to run this.' : false);
}
