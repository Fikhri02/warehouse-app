import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart';

import 'command_sender.dart';

enum FlushOutcome { done, offline, sessionExpired, serverTrouble }

/// Sends the outbox oldest first, following the response table in spec §3:
/// - 2xx: done.
/// - 409: kept as conflicted with the server's reason; the next command still goes.
/// - Any other 4xx: failed.
/// - 5xx, 429, offline or session ended: stop, so later commands keep their order, and retry on the next run.
/// Without a [CommandSender] (Sample mode) there is nothing to send: queued items are simply marked done.
class SyncService {
  SyncService({required AppDatabase db, CommandSender? sender})
      : _db = db,
        _sender = sender;

  final AppDatabase _db;
  final CommandSender? _sender;
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
      try {
        await sender.send(item);
        await dao.markSynced(item.id);
      } on ApiException catch (e) {
        if (e.status == 409) {
          await dao.markConflicted(item.id, e);
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
}
