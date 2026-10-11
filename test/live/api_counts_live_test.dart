@Tags(['live'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_stock_count_repository.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide CountItem, CountSession, UserSession;
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final api = Platform.environment['WARETRACK_API'];
final password = Platform.environment['WARETRACK_SEED_PASSWORD'] ?? 'Waretrack#2026';

/// One phone: its own database, tokens and outbox.
class Phone {
  Phone._(this.db, this.client, this.auth);

  static Phone create() {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final client = ApiClient(baseUrl: api!, httpClient: http.Client(), tokens: TokenStore(MemoryKeyValueStore()));
    return Phone._(db, client, ApiAuthRepository(client: client, db: db));
  }

  final AppDatabase db;
  final ApiClient client;
  final ApiAuthRepository auth;
  late UserSession session;

  late final counts = ApiStockCountRepository(client: client, db: db, session: () => session, onQueued: () {});
  late final outbox = SyncService(db: db, sender: CommandSender(client));
  late final puller = ChangeFeedPuller(client: client, db: db);

  Future<void> signIn(String email) async {
    session = await auth.login(email, password);
    if (session.warehouseId == null) {
      session = await auth.selectWarehouse(session, session.warehouses.firstWhere((w) => w.code == 'SA1').warehouseId);
    }
    await puller.pull(session.warehouseId!);
  }

  Future<void> sync() async {
    expect(await outbox.flushQueue(), FlushOutcome.done);
    await puller.pull(session.warehouseId!);
  }
}

void main() {
  test("a worker's count reaches the server and a supervisor approves it from a phone", () async {
    final worker = Phone.create();
    final supervisor = Phone.create();
    addTearDown(() async {
      await worker.db.close();
      await supervisor.db.close();
    });

    await worker.signIn('arjun@waretrack.local');
    final item = (await worker.counts.searchItems('WT-0001')).single;
    final bin = (await worker.counts.getLocations()).firstWhere((l) => l.kind == 'Bin');
    final countId = const Uuid().v4();
    await worker.counts.submitSession(CountSession(
      id: countId,
      location: bin.code,
      locationId: bin.id,
      label: 'Phone live test ${DateTime.now().toIso8601String()}',
      startedAt: DateTime.now(),
      status: CountSessionStatus.inProgress,
      items: [CountItem(itemId: item.id, itemCode: item.sku, itemName: item.name, expected: 0, counted: 49)],
    ));
    await worker.sync();
    expect((await worker.db.serverMirrorDao.countSessions(warehouseId: worker.session.warehouseId!)).map((s) => s.id), contains(countId));

    await supervisor.signIn('hafiz@waretrack.local');
    expect((await supervisor.counts.getCountsToReview()).map((c) => c.id), contains(countId));
    final review = await supervisor.counts.getCountReview(countId);
    expect(review.lines.single.counted, 49);
    await supervisor.counts.approveCount(countId);
    await supervisor.sync();

    await worker.sync();
    final mine = (await worker.counts.getRecentCounts()).firstWhere((c) => c.id == countId);
    expect(mine.progress.name, 'approved');
  }, skip: api == null ? 'Set WARETRACK_API=http://localhost:5050 (with the server running) to run this.' : false);
}
