import 'dart:convert';

import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/repositories/alerts_repository.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

/// The signed-in person's alerts from the phone's copy. A read waiting in the outbox already counts as read.
/// "Mark all read" queues one read per alert on screen, never the server's read-all: that would also mark alerts the
/// chip hides or that arrived while this phone was offline, which the person never saw.
class ApiAlertsRepository implements AlertsRepository {
  ApiAlertsRepository({required AppDatabase db, required UserSession? Function() session, required void Function() onQueued})
      : _db = db,
        _session = session,
        _onQueued = onQueued;

  final AppDatabase _db;
  final UserSession? Function() _session;
  final void Function() _onQueued;

  @override
  Future<List<Alert>> getAlerts() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final dao = _db.serverMirrorDao;
    final caughtUp = await dao.caughtUpThrough(warehouseId);
    final readHere = {
      for (final c in await _db.syncQueueDao.notYetInCopy(SyncOps.alertRead, warehouseId: warehouseId, caughtUpThrough: caughtUp))
        c.referenceId,
    };
    return [
      for (final row in await dao.alerts(warehouseId))
        if (AlertType.fromServer(row.type) case final type?)
          Alert(
            id: row.id,
            type: type,
            title: row.title,
            body: row.body,
            createdAt: row.createdAt,
            isRead: row.readAt != null || readHere.contains(row.id),
            payload: row.payload == null ? const {} : jsonDecode(row.payload!) as Map<String, dynamic>,
          ),
    ];
  }

  @override
  Future<void> markRead(String alertId) async {
    final alert = (await getAlerts()).where((a) => a.id == alertId).firstOrNull;
    if (alert == null || alert.isRead) return;
    await _queueRead(alert);
    _onQueued();
  }

  @override
  Future<void> markAllRead(Iterable<String> alertIds) async {
    final ids = alertIds.toSet();
    final unread = (await getAlerts()).where((a) => !a.isRead && ids.contains(a.id)).toList();
    if (unread.isEmpty) return;
    for (final alert in unread) {
      await _queueRead(alert);
    }
    _onQueued();
  }

  Future<void> _queueRead(Alert alert) => _db.syncQueueDao.enqueue(
        operationType: SyncOps.alertRead,
        referenceId: alert.id,
        warehouseId: _session()?.warehouseId,
        payload: jsonEncode({'title': alert.title}),
      );
}
