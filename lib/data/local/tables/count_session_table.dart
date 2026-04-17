import 'package:drift/drift.dart';

class CountSessions extends Table {
  TextColumn get id => text()();
  TextColumn get location => text()(); // keep this — legacy free-text
  TextColumn get label => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get submittedAt => dateTime().nullable()();
  TextColumn get locationId => text().nullable()();
  TextColumn get assignedWorkerId => text().nullable()();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get zoneAisle => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CountItems extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get itemCode => text()();
  TextColumn get itemName => text()();
  IntColumn get expectedQty => integer()();
  IntColumn get actualQty => integer()();
  TextColumn get entryMethod => text().withDefault(const Constant('scanned'))();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
