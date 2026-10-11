import 'package:drift/drift.dart';

// Read-only copies of the server's data, filled from the change feed (spec §3). Row classes end in "Row" so
// they never clash with the app's own models (CatalogItem in core/models/order.dart, Location, …).

@DataClassName('CatalogItemRow')
class CatalogItems extends Table {
  TextColumn get id => text()();
  TextColumn get sku => text()();
  TextColumn get name => text()();
  TextColumn get uom => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CatalogBarcodeRow')
class CatalogBarcodes extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get code => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WarehouseLocationRow')
class WarehouseLocations extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text()();
  TextColumn get code => text()();
  TextColumn get type => text()(); // Bin · Zone · Dock

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RemoteCountSessionRow')
class RemoteCountSessions extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text()();
  TextColumn get createdByUserId => text()();
  TextColumn get label => text().nullable()();
  TextColumn get status => text()(); // Submitted · Approved · Rejected
  DateTimeColumn get submittedAt => dateTime()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();
  TextColumn get rejectReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RemoteCountLineRow')
class RemoteCountLines extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get itemId => text()();
  TextColumn get locationId => text()();
  RealColumn get counted => real()();
  RealColumn get systemAtSubmit => real()();
  RealColumn get adjustment => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// How far this phone has read each warehouse's change feed.
@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get warehouseId => text()();
  IntColumn get cursor => integer()();

  @override
  Set<Column> get primaryKey => {warehouseId};
}
