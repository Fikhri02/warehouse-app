import 'package:drift/drift.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationType => text()();
  TextColumn get referenceId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get queuedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  /// Sent as Idempotency-Key, unchanged on every retry of this command.
  TextColumn get idempotencyKey => text().nullable()();

  /// pending · synced · conflicted (the server answered 409) · failed (any other refusal) · dismissed
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// The server's problem details for a conflicted or failed command, as JSON.
  TextColumn get lastError => text().nullable()();
  TextColumn get warehouseId => text().nullable()();
}
