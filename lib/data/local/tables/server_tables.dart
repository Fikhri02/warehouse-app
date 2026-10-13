import 'package:drift/drift.dart';

/// Bump when the app starts storing a change-feed entity it used to skip. Every phone then reads its feed again from
/// the start, so the rows it skipped before arrive. 1 = 3a (catalogue, locations, counts); 2 = 3b (+ purchase orders).
const kMirrorVersion = 4;

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

/// Delivery and sales orders as the server has them. Kind is Delivery or Sales.
@DataClassName('RemoteOrderRow')
class RemoteOrders extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text()();
  TextColumn get kind => text()();
  TextColumn get number => text()();
  TextColumn get destination => text().nullable()();
  TextColumn get customerName => text().nullable()();
  DateTimeColumn get orderDate => dateTime()();
  TextColumn get status => text()(); // Draft · PendingApproval · Submitted · Packed · InTransit · Shipped
  BoolColumn get requiresApproval => boolean()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdByName => text()();
  DateTimeColumn get createdAt => dateTime()();

  /// JSON: [{status, changedByName, changedAt}], oldest first.
  TextColumn get statusHistory => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RemoteOrderLineRow')
class RemoteOrderLines extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get itemId => text()();
  TextColumn get locationId => text()();
  RealColumn get quantity => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Staff tasks as the server has them. Every task in the warehouse comes to every member, so a reassignment
/// reaches the previous assignee too.
@DataClassName('RemoteTaskRow')
class RemoteTasks extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text()();
  TextColumn get title => text()();
  TextColumn get type => text()(); // StockCount · StockReceive · Other
  TextColumn get locationId => text().nullable()();
  TextColumn get assigneeUserId => text().nullable()();
  TextColumn get status => text()(); // Pending · InProgress · Done
  DateTimeColumn get dueAt => dateTime().nullable()();
  TextColumn get createdByUserId => text()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The signed-in person's alerts. Payload is the server's JSON, as text.
@DataClassName('RemoteAlertRow')
class RemoteAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text().nullable()();
  TextColumn get type => text()(); // LowStock · TaskAssigned · CountToReview · SyncConflict
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get payload => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A warehouse's people as GET /warehouses/{id}/members last listed them, for the assignee picker. Not in the feed.
@DataClassName('WarehouseMemberRow')
class WarehouseMembers extends Table {
  TextColumn get warehouseId => text()();
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  TextColumn get role => text()(); // Worker · Supervisor
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {warehouseId, userId};
}
