import 'package:drift/drift.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueData>> getPendingItems() =>
      (select(syncQueue)..where((q) => q.synced.equals(false))).get();

  Future<int> enqueue({
    required String operationType,
    required String referenceId,
    required String payload,
  }) =>
      into(syncQueue).insert(
        SyncQueueCompanion.insert(
          operationType: operationType,
          referenceId: referenceId,
          payload: payload,
        ),
      );

  Future<void> markSynced(int id) =>
      (update(syncQueue)..where((q) => q.id.equals(id))).write(
        SyncQueueCompanion(
          synced: const Value(true),
          syncedAt: Value(DateTime.now()),
        ),
      );

  Future<int> countPending() async {
    final count = countAll(filter: syncQueue.synced.equals(false));
    final query = selectOnly(syncQueue)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
