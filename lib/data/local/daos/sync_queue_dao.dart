import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

/// The outbox (spec §3): commands wait here, oldest first, until the server has answered them.
@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueData>> getPendingItems() =>
      (select(syncQueue)..where((q) => q.status.equals('pending'))..orderBy([(q) => OrderingTerm.asc(q.id)])).get();

  /// Queues a command with its own Idempotency-Key, kept for every retry.
  Future<int> enqueue({
    required String operationType,
    required String referenceId,
    required String payload,
    String? idempotencyKey,
    String? warehouseId,
  }) =>
      into(syncQueue).insert(
        SyncQueueCompanion.insert(
          operationType: operationType,
          referenceId: referenceId,
          payload: payload,
          idempotencyKey: Value(idempotencyKey ?? const Uuid().v4()),
          warehouseId: Value(warehouseId),
        ),
      );

  Future<void> markSynced(int id) => (update(syncQueue)..where((q) => q.id.equals(id))).write(
        SyncQueueCompanion(status: const Value('synced'), synced: const Value(true), syncedAt: Value(DateTime.now())),
      );

  /// The server answered 409: things changed. Kept with the reason; the queue moves on.
  Future<void> markConflicted(int id, ApiException error) => _close(id, 'conflicted', error);

  /// Any other refusal: sending the same request again cannot succeed.
  Future<void> markFailed(int id, ApiException error) => _close(id, 'failed', error);

  Future<void> _close(int id, String status, ApiException error) => (update(syncQueue)..where((q) => q.id.equals(id))).write(
        SyncQueueCompanion(status: Value(status), lastError: Value(jsonEncode(error.toJson()))),
      );

  Future<void> recordAttempt(int id) =>
      customUpdate('UPDATE sync_queue SET attempts = attempts + 1 WHERE id = ?', variables: [Variable.withInt(id)], updates: {syncQueue});

  /// The person has read the reason.
  Future<void> dismiss(int id) =>
      (update(syncQueue)..where((q) => q.id.equals(id))).write(const SyncQueueCompanion(status: Value('dismissed')));

  /// Commands of one type that have not gone through: waiting, or refused and not dismissed. Newest first.
  Future<List<SyncQueueData>> itemsFor(String operationType, {String? warehouseId}) {
    final query = select(syncQueue)
      ..where((q) => q.operationType.equals(operationType) & q.status.isIn(['pending', 'conflicted', 'failed']))
      ..orderBy([(q) => OrderingTerm.desc(q.id)]);
    if (warehouseId != null) query.where((q) => q.warehouseId.equals(warehouseId));
    return query.get();
  }

  /// Commands whose effect the phone's copy of the server does not show yet: not sent, or sent after the latest
  /// complete pull began ([caughtUpThrough], see SyncCursors).
  Future<List<SyncQueueData>> notYetInCopy(String operationType, {required String warehouseId, required int caughtUpThrough}) =>
      (select(syncQueue)
            ..where((q) =>
                q.operationType.equals(operationType) &
                q.warehouseId.equals(warehouseId) &
                (q.status.equals('pending') | (q.status.equals('synced') & q.id.isBiggerThanValue(caughtUpThrough)))))
          .get();

  /// The newest command the server has taken; 0 if none. Commands go oldest first, so every synced id below it went too.
  Future<int> lastSyncedId() async {
    final newest = syncQueue.id.max();
    final row = await (selectOnly(syncQueue)
          ..addColumns([newest])
          ..where(syncQueue.status.equals('synced')))
        .getSingle();
    return row.read(newest) ?? 0;
  }

  Future<int> countPending() async {
    final count = countAll(filter: syncQueue.status.equals('pending'));
    final query = selectOnly(syncQueue)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Stream<int> watchPendingCount() {
    final count = countAll(filter: syncQueue.status.equals('pending'));
    return (selectOnly(syncQueue)..addColumns([count])).watchSingle().map((row) => row.read(count) ?? 0);
  }

  Stream<List<SyncQueueData>> watchIssues() => (select(syncQueue)
        ..where((q) => q.status.isIn(['conflicted', 'failed']))
        ..orderBy([(q) => OrderingTerm.desc(q.id)]))
      .watch();

  /// The newest [operationType] command for [referenceId] queued before command [before].
  Future<SyncQueueData?> previousCommand(String operationType, String referenceId, {required int before}) => (select(syncQueue)
        ..where((q) => q.operationType.equals(operationType) & q.referenceId.equals(referenceId) & q.id.isSmallerThanValue(before))
        ..orderBy([(q) => OrderingTerm.desc(q.id)])
        ..limit(1))
      .getSingleOrNull();

}
