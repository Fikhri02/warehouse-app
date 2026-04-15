import 'package:drift/drift.dart';

class UserSessions extends Table {
  TextColumn get userId => text()();
  TextColumn get token => text()();
  TextColumn get role => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get site => text()();
  DateTimeColumn get storedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}
