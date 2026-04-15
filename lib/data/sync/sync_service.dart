import 'package:warehouse_app/data/local/app_database.dart';

/// SyncService: flushes pending operations from the local SyncQueue.
///
/// In the frontend-first phase, "flushing" means marking items as synced
/// with no actual API call. During backend integration, replace the
/// _processItem method body with real API calls per operation type.
class SyncService {
  final AppDatabase _db;

  SyncService({required AppDatabase db}) : _db = db;

  Future<void> flushQueue() async {
    final pending = await _db.syncQueueDao.getPendingItems();
    for (final item in pending) {
      await _processItem(item);
      await _db.syncQueueDao.markSynced(item.id);
    }
  }

  /// Processes a single sync queue item.
  /// Replace this with real API calls during backend integration.
  Future<void> _processItem(SyncQueueData item) async {
    // ignore: avoid_print
    print('[SyncService] Processing ${item.operationType} for ${item.referenceId}');
  }
}
