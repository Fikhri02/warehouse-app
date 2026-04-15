import 'package:drift/drift.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationType => text()();
  TextColumn get referenceId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get queuedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
