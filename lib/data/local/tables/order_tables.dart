import 'package:drift/drift.dart';

class LocationEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();
}

class DeliveryOrderEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text()();
  IntColumn get fromLocationId => integer()();
  IntColumn get toLocationId => integer()();
  DateTimeColumn get deliveryDate => dateTime()();
  TextColumn get status => text()();
  BoolColumn get requiresApproval =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class SalesOrderEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text()();
  TextColumn get customerName => text()();
  DateTimeColumn get orderDate => dateTime()();
  TextColumn get status => text()();
  BoolColumn get requiresApproval =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class OrderItemEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer()();
  TextColumn get orderType => text()();
  TextColumn get itemId => text()();
  TextColumn get itemName => text()();
  TextColumn get itemSku => text()();
  IntColumn get quantity => integer()();
}

class OrderStatusHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer()();
  TextColumn get orderType => text()();
  TextColumn get status => text()();
  TextColumn get changedBy => text()();
  DateTimeColumn get changedAt => dateTime()();
}
