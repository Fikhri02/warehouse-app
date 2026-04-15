import 'package:drift/drift.dart';

class Alerts extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
