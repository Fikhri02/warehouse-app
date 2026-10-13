@Tags(['live'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_alerts_repository.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_tasks_repository.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final api = Platform.environment['WARETRACK_API'];
final password = Platform.environment['WARETRACK_SEED_PASSWORD'] ?? 'Waretrack#2026';

/// One person's phone: its own copy, outbox, tasks and alerts.
class Phone {
  Phone._(this.db, this.session, this.puller, this.outbox, this.tasks, this.alerts);

  final AppDatabase db;
  final UserSession session;
  final ChangeFeedPuller puller;
  final SyncService outbox;
  final ApiTasksRepository tasks;
  final ApiAlertsRepository alerts;

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
    final phone = Phone._(
      db,
      current,
      ChangeFeedPuller(client: client, db: db),
      SyncService(db: db, sender: CommandSender(client)),
      ApiTasksRepository(client: client, db: db, session: () => current, onQueued: () {}),
      ApiAlertsRepository(db: db, session: () => current, onQueued: () {}),
    );
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
  test('a supervisor creates and assigns a task; the worker starts and finishes it and reads the alert', () async {
    final lead = await Phone.signIn('hafiz');
    final worker = await Phone.signIn('arjun');
    final arjun = (await lead.tasks.getTeam()).firstWhere((m) => m.name == 'Arjun Nair');
    final bin = (await lead.tasks.getPlaces()).firstWhere((p) => p.code == 'A-01-01');
    final id = const Uuid().v4();
    final title = 'Live count ${id.substring(0, 8)}';

    await lead.tasks.createTask(NewTask(
      id: id,
      title: title,
      type: TaskType.stockCount,
      locationId: bin.id,
      assigneeId: arjun.id,
      dueAt: DateTime.now().add(const Duration(hours: 2)),
    ));
    await lead.sync();

    await worker.sync();
    final mine = (await worker.tasks.getMyTasks()).firstWhere((t) => t.id == id);
    expect((mine.title, mine.locationCode, mine.status), (title, 'A-01-01', TaskStatus.pending));
    final alert = (await worker.alerts.getAlerts()).firstWhere((a) => a.taskId == id);
    expect((alert.type, alert.isRead), (AlertType.taskAssigned, false));

    await worker.tasks.startTask(id);
    await worker.tasks.completeTask(id);
    await worker.alerts.markRead(alert.id);
    await worker.sync();

    expect((await worker.tasks.getMyTasks()).where((t) => t.id == id), isEmpty);
    expect((await worker.alerts.getAlerts()).firstWhere((a) => a.id == alert.id).isRead, isTrue);

    await lead.sync();
    final done = (await lead.tasks.getCompletedTasks()).firstWhere((t) => t.id == id);
    expect(done.assigneeName, 'Arjun Nair');
    expect(done.completedAt, isNotNull);
  }, skip: api == null ? 'Set WARETRACK_API=http://localhost:5050 (with the server running) to run this.' : false);
}
