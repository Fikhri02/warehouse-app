import 'package:drift/drift.dart';

/// Bump when the app starts storing a change-feed entity it used to skip. Every phone then reads its feed again from
/// the start, so the rows it skipped before arrive. 1 = 3a (catalogue, locations, counts); 2 = 3b (+ purchase orders).
const kMirrorVersion = 2;

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

  /// The kMirrorVersion this cursor was saved under; an older one means "read again from the start".
  IntColumn get mirrorVersion => integer().withDefault(const Constant(1))();

  /// The last sync_queue id already sent when the latest complete pull began: what those commands did is in the
  /// copy. A command sent after it may not be yet.
  IntColumn get caughtUpThrough => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {warehouseId};
}

@DataClassName('RemotePurchaseOrderRow')
class RemotePurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text()();
  TextColumn get number => text()();
  TextColumn get supplier => text()();
  DateTimeColumn get expectedDate => dateTime().nullable()();
  TextColumn get status => text()(); // Open · Partial · Received · Closed

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RemotePoLineRow')
class RemotePoLines extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseOrderId => text()();
  IntColumn get lineNo => integer()();
  TextColumn get itemId => text()();
  RealColumn get ordered => real()();
  RealColumn get received => real()();

  @override
  Set<Column> get primaryKey => {id};
}
