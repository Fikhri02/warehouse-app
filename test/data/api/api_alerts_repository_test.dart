import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_alerts_repository.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/sync/command_sender.dart';

const w = '22222222-2222-4222-8222-222222222222';

RemoteAlertsCompanion alert(String id, String type, int hour, {Object? payload, bool read = false}) => RemoteAlertsCompanion.insert(
      id: id,
      warehouseId: const Value(w),
      type: type,
      title: 'Alert $id',
      body: 'Body $id',
      payload: Value(payload == null ? null : jsonEncode(payload)),
      createdAt: DateTime.utc(2026, 10, 13, hour),
      readAt: Value(read ? DateTime.utc(2026, 10, 13, hour, 30) : null),
    );

void main() {
  late AppDatabase db;
  late ApiAlertsRepository repo;
  late int kicks;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    kicks = 0;
    const session = UserSession(
        userId: 'u1', name: 'Arjun Nair', email: 'a@w', site: 'SA1', role: UserRole.worker, token: 't', warehouseId: w);
    repo = ApiAlertsRepository(db: db, session: () => session, onQueued: () => kicks++);
    final dao = db.serverMirrorDao;
    await dao.upsertAlert(alert('task', 'TaskAssigned', 6, payload: {'taskId': 't1'}));
    await dao.upsertAlert(alert('old', 'LowStock', 5, read: true));
    await dao.upsertAlert(alert('future', 'Birthday', 7));
    await dao.upsertAlert(alert('conflict', 'SyncConflict', 4));
  });
  tearDown(() => db.close());

  test('alerts come newest first with what they point at; types this app does not know are left out', () async {
    final alerts = await repo.getAlerts();

    expect(alerts.map((a) => (a.id, a.type, a.isRead)), [
      ('task', AlertType.taskAssigned, false),
      ('old', AlertType.lowStock, true),
      ('conflict', AlertType.syncConflict, false),
    ]);
    expect(alerts.first.taskId, 't1');
  });

  test('reading an alert offline shows it read at once and queues one read', () async {
    await repo.markRead('task');
    await repo.markRead('task');
    await repo.markRead('old'); // already read: nothing to send

    expect((await repo.getAlerts()).first.isRead, isTrue);
    final queued = await db.syncQueueDao.getPendingItems();
    expect(queued.map((c) => (c.operationType, c.referenceId)), [(SyncOps.alertRead, 'task')]);
    expect(kicks, 1);
  });

  test('mark all read marks only the alerts on screen, so one that arrives later stays unread', () async {
    await repo.markAllRead(['task', 'conflict']);
    await db.serverMirrorDao.upsertAlert(alert('later', 'LowStock', 8));

    final queued = await db.syncQueueDao.getPendingItems();
    expect(queued.map((c) => c.referenceId).toSet(), {'task', 'conflict'});
    expect(kicks, 1);
    final alerts = await repo.getAlerts();
    expect(alerts.firstWhere((a) => a.id == 'later').isRead, isFalse);
    expect(alerts.where((a) => !a.isRead).map((a) => a.id), ['later']);
  });

  test('mark all read leaves alone the alerts the chip was hiding', () async {
    await repo.markAllRead(['conflict', 'old']); // the Sync chip shows these two; 'old' is already read

    final queued = await db.syncQueueDao.getPendingItems();
    expect(queued.map((c) => c.referenceId), ['conflict']);
    expect((await repo.getAlerts()).firstWhere((a) => a.id == 'task').isRead, isFalse);
  });
}
