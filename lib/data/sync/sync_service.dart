import 'dart:convert';

import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart';

import 'command_sender.dart';

enum FlushOutcome { done, offline, sessionExpired, serverTrouble }

/// Sends the outbox oldest first, following the response table in spec §3:
/// - 2xx: done.
/// - 409: kept as conflicted with the server's reason; the next command still goes.
/// - 404 on a task command: conflicted. 404 on alert.read: done.
/// - Any other 4xx: failed.
/// - 5xx, 429, offline or session ended: stop, so later commands keep their order, and retry on the next run.
/// Without a [CommandSender] (Sample mode) there is nothing to send: queued items are simply marked done.
class SyncService {
  SyncService({required AppDatabase db, CommandSender? sender})
      : _db = db,
        _sender = sender;

  final AppDatabase _db;
  final CommandSender? _sender;

  /// Commands that only make sense if an earlier command for the same record went through, and what to say if it didn't.
  static const _dependsOn = {
    SyncOps.receiptSignature: (SyncOps.receiptCreate, 'Signature not sent: its receipt was not accepted.'),
    SyncOps.orderStatus: (SyncOps.orderSave, 'Status not sent: the order was not saved.'),
    SyncOps.taskAssign: (SyncOps.taskCreate, 'Not sent: the task was not created.'),
    SyncOps.taskStart: (SyncOps.taskCreate, 'Not sent: the task was not created.'),
    SyncOps.taskComplete: (SyncOps.taskCreate, 'Not sent: the task was not created.'),
  };
  Future<FlushOutcome>? _running;

  Future<FlushOutcome> flushQueue() => _running ??= _flush().whenComplete(() => _running = null);

  Future<FlushOutcome> _flush() async {
    final dao = _db.syncQueueDao;
    for (final item in await dao.getPendingItems()) {
      final sender = _sender;
      if (sender == null) {
        await dao.markSynced(item.id);
        continue;
      }
      await dao.recordAttempt(item.id);
      final dependency = _dependsOn[item.operationType];
      if (dependency != null) {
        // Sending it would only fail with "not found"; say why instead.
        final parent = await _parentOf(item, dependency.$1);
        if (parent != null && (parent.status == 'conflicted' || parent.status == 'failed')) {
          await dao.markFailed(item.id, ApiException(status: 0, title: dependency.$2));
          continue;
        }
      }
      try {
        await sender.send(item);
        await dao.markSynced(item.id);
      } on ApiException catch (e) {
        if (e.status == 409 || (e.status == 404 && SyncOps.taskCommands.contains(item.operationType))) {
          // A task the server no longer has: things moved on, as with a 409.
          await dao.markConflicted(item.id, e);
        } else if (e.status == 404 && item.operationType == SyncOps.alertRead) {
          await dao.markSynced(item.id); // the alert is gone: nothing left to mark read
        } else if (e.status == 401) {
          return FlushOutcome.sessionExpired;
        } else if (e.status >= 500 || e.status == 429) {
          return FlushOutcome.serverTrouble;
        } else {
          await dao.markFailed(item.id, e);
        }
      } on ApiOfflineException {
        return FlushOutcome.offline;
      } on SessionExpiredException {
        return FlushOutcome.sessionExpired;
      } on UnsupportedError catch (e) {
        await dao.markFailed(item.id, ApiException(status: 0, title: e.message));
      }
    }
    return FlushOutcome.done;
  }

  /// The command [item] depends on. An order's status change depends only on the save it was queued with, so an old
  /// refused edit doesn't hold status changes to an order the server has.
  Future<SyncQueueData?> _parentOf(SyncQueueData item, String parentOp) async {
    final dao = _db.syncQueueDao;
    if (item.operationType != SyncOps.orderStatus) return dao.previousCommand(parentOp, item.referenceId, before: item.id);
    final afterSave = (jsonDecode(item.payload) as Map<String, dynamic>)['afterSave'] as int?;
    return afterSave == null ? null : dao.commandById(afterSave);
  }
}
