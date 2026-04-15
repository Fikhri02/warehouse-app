import 'package:drift/drift.dart';

class StaffTasks extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get location => text()();
  DateTimeColumn get dueAt => dateTime()();
  TextColumn get status => text()();
  TextColumn get assignedTo => text()();

  @override
  Set<Column> get primaryKey => {id};
}
