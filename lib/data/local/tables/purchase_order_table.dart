import 'package:drift/drift.dart';

class PurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get poNumber => text()();
  TextColumn get supplier => text()();
  TextColumn get status => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get expectedDate => dateTime()();
  DateTimeColumn get receivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PoLineItems extends Table {
  TextColumn get id => text()();
  TextColumn get poId => text()();
  TextColumn get itemCode => text()();
  TextColumn get itemName => text()();
  IntColumn get expectedQty => integer()();
  IntColumn get receivedQty => integer().withDefault(const Constant(0))();
  BoolColumn get flagged => boolean().withDefault(const Constant(false))();
  TextColumn get flagReason => text().nullable()();
  TextColumn get status => text()();

  @override
  Set<Column> get primaryKey => {id};
}
