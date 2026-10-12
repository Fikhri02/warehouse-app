@Tags(['live'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_receiving_repository.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide CountItem, CountSession, PoLineItem, PurchaseOrder, UserSession;
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final api = Platform.environment['WARETRACK_API'];
final password = Platform.environment['WARETRACK_SEED_PASSWORD'] ?? 'Waretrack#2026';

/// The smallest valid PNG: one transparent pixel.
final png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  test('a worker receives against a purchase order with a signature, and the order shows it', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final client = ApiClient(baseUrl: api!, httpClient: http.Client(), tokens: TokenStore(MemoryKeyValueStore()));
    final auth = ApiAuthRepository(client: client, db: db);
    var session = await auth.login('arjun@waretrack.local', password);
    if (session.warehouseId == null) {
      session = await auth.selectWarehouse(session, session.warehouses.firstWhere((w) => w.code == 'SA1').warehouseId);
    }
    final UserSession current = session;
    final puller = ChangeFeedPuller(client: client, db: db);
    final outbox = SyncService(db: db, sender: CommandSender(client));
    final receiving = ApiReceivingRepository(db: db, session: () => current, onQueued: () {});
    await puller.pull(current.warehouseId!);

    final orders = await receiving.getPurchaseOrders();
    final order = orders.firstWhere((o) => o.lineItems.any((l) => l.alreadyReceived < l.expected));
    final line = order.lineItems.firstWhere((l) => l.alreadyReceived < l.expected);
    final dock = (await receiving.getPutAwayLocations()).first;
    await receiving.submitReceive(
      order.copyWithLines([for (final l in order.lineItems) l.lineId == line.lineId ? l.copyWith(received: l.alreadyReceived + 1) : l]),
      signature: png,
      locationId: dock.id,
    );

    expect(await outbox.flushQueue(), FlushOutcome.done);
    expect(await db.syncQueueDao.watchIssues().first, isEmpty); // the receipt and the signature were both accepted
    await puller.pull(current.warehouseId!);

    final after = (await receiving.getPurchaseOrders()).firstWhere((o) => o.id == order.id);
    expect(after.lineItems.firstWhere((l) => l.lineId == line.lineId).alreadyReceived, line.alreadyReceived + 1);
  }, skip: api == null ? 'Set WARETRACK_API=http://localhost:5050 (with the server running) to run this.' : false);
}
