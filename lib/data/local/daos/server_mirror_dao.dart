import 'package:drift/drift.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/server_tables.dart';

part 'server_mirror_dao.g.dart';

@DriftAccessor(tables: [CatalogItems, CatalogBarcodes, WarehouseLocations, RemoteCountSessions, RemoteCountLines, SyncCursors, RemotePurchaseOrders, RemotePoLines, RemoteOrders, RemoteOrderLines, RemoteTasks, RemoteAlerts, WarehouseMembers])
class ServerMirrorDao extends DatabaseAccessor<AppDatabase> with _$ServerMirrorDaoMixin {
  ServerMirrorDao(super.db);

  Future<void> upsertItem(CatalogItemsCompanion item) => into(catalogItems).insertOnConflictUpdate(item);

  Future<void> deleteItem(String id) => (delete(catalogItems)..where((t) => t.id.equals(id))).go();

  Future<void> upsertBarcode(CatalogBarcodesCompanion barcode) => into(catalogBarcodes).insertOnConflictUpdate(barcode);

  Future<void> deleteBarcode(String id) => (delete(catalogBarcodes)..where((t) => t.id.equals(id))).go();

  Future<void> upsertLocation(WarehouseLocationsCompanion location) => into(warehouseLocations).insertOnConflictUpdate(location);

  Future<void> deleteLocation(String id) => (delete(warehouseLocations)..where((t) => t.id.equals(id))).go();

  /// A count arrives whole: its lines replace whatever the phone had for it.
  Future<void> upsertCountSession(RemoteCountSessionsCompanion session, List<RemoteCountLinesCompanion> lines) async {
    await into(remoteCountSessions).insertOnConflictUpdate(session);
    await (delete(remoteCountLines)..where((l) => l.sessionId.equals(session.id.value))).go();
    for (final line in lines) {
      await into(remoteCountLines).insert(line);
    }
  }

  Future<void> deleteCountSession(String id) async {
    await (delete(remoteCountLines)..where((l) => l.sessionId.equals(id))).go();
    await (delete(remoteCountSessions)..where((s) => s.id.equals(id))).go();
  }

  /// 0 when this phone has never read the feed, or read it under an older mirror version (see kMirrorVersion).
  Future<int> cursorFor(String warehouseId) async {
    final row = await (select(syncCursors)..where((c) => c.warehouseId.equals(warehouseId))).getSingleOrNull();
    return row == null || row.mirrorVersion < kMirrorVersion ? 0 : row.cursor;
  }

  Future<void> saveCursor(String warehouseId, int cursor) => into(syncCursors).insertOnConflictUpdate(
        SyncCursorsCompanion.insert(warehouseId: warehouseId, cursor: cursor, mirrorVersion: const Value(kMirrorVersion)),
      );

  /// See SyncCursors.caughtUpThrough. 0 before the first complete pull. Kept across a kMirrorVersion bump: the copy is
  /// re-read but not emptied, so what those commands did is still in it (and newly copied kinds have no older commands).
  Future<int> caughtUpThrough(String warehouseId) async {
    final row = await (select(syncCursors)..where((c) => c.warehouseId.equals(warehouseId))).getSingleOrNull();
    return row?.caughtUpThrough ?? 0;
  }

  Future<void> markCaughtUp(String warehouseId, {required int through}) =>
      (update(syncCursors)..where((c) => c.warehouseId.equals(warehouseId))).write(SyncCursorsCompanion(caughtUpThrough: Value(through)));

  Future<CatalogItemRow?> itemByBarcode(String code) {
    final query = select(catalogItems).join([innerJoin(catalogBarcodes, catalogBarcodes.itemId.equalsExp(catalogItems.id))])
      ..where(catalogBarcodes.code.equals(code) & catalogItems.isActive.equals(true))
      ..limit(1);
    return query.map((row) => row.readTable(catalogItems)).getSingleOrNull();
  }

  Future<CatalogItemRow?> itemById(String id) => (select(catalogItems)..where((i) => i.id.equals(id))).getSingleOrNull();

  /// Active items whose SKU or name contains [term] (SQLite LIKE ignores case for ASCII).
  Future<List<CatalogItemRow>> searchItems(String term, {int limit = 50}) {
    final pattern = '%${term.trim()}%';
    return (select(catalogItems)
          ..where((i) => i.isActive.equals(true) & (i.sku.like(pattern) | i.name.like(pattern)))
          ..orderBy([(i) => OrderingTerm.asc(i.sku)])
          ..limit(limit))
        .get();
  }

  Future<List<WarehouseLocationRow>> locationsFor(String warehouseId) => (select(warehouseLocations)
        ..where((l) => l.warehouseId.equals(warehouseId))
        ..orderBy([(l) => OrderingTerm.asc(l.code)]))
      .get();

  Future<WarehouseLocationRow?> locationById(String id) =>
      (select(warehouseLocations)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<List<RemoteCountSessionRow>> countSessions({required String warehouseId, String? createdBy, String? status, int limit = 20}) {
    final query = select(remoteCountSessions)..where((s) => s.warehouseId.equals(warehouseId));
    if (createdBy != null) query.where((s) => s.createdByUserId.equals(createdBy));
    if (status != null) query.where((s) => s.status.equals(status));
    query
      ..orderBy([(s) => OrderingTerm.desc(s.submittedAt)])
      ..limit(limit);
    return query.get();
  }

  Future<List<RemoteCountLineRow>> linesFor(String sessionId) =>
      (select(remoteCountLines)..where((l) => l.sessionId.equals(sessionId))).get();

  /// An order arrives whole: its lines replace whatever the phone had for it.
  Future<void> upsertPurchaseOrder(RemotePurchaseOrdersCompanion order, List<RemotePoLinesCompanion> lines) async {
    await into(remotePurchaseOrders).insertOnConflictUpdate(order);
    await (delete(remotePoLines)..where((l) => l.purchaseOrderId.equals(order.id.value))).go();
    for (final line in lines) {
      await into(remotePoLines).insert(line);
    }
  }

  Future<void> deletePurchaseOrder(String id) async {
    await (delete(remotePoLines)..where((l) => l.purchaseOrderId.equals(id))).go();
    await (delete(remotePurchaseOrders)..where((o) => o.id.equals(id))).go();
  }

  /// Orders that can still be received against, or were received in full; closed ones are done with.
  Future<List<RemotePurchaseOrderRow>> purchaseOrders(String warehouseId) => (select(remotePurchaseOrders)
        ..where((o) => o.warehouseId.equals(warehouseId) & o.status.isNotIn(['Closed']))
        ..orderBy([(o) => OrderingTerm.asc(o.expectedDate), (o) => OrderingTerm.asc(o.number)]))
      .get();

  Future<List<RemotePoLineRow>> poLinesFor(String purchaseOrderId) => (select(remotePoLines)
        ..where((l) => l.purchaseOrderId.equals(purchaseOrderId))
        ..orderBy([(l) => OrderingTerm.asc(l.lineNo)]))
      .get();

  Future<List<String>> barcodesFor(String itemId) async =>
      [for (final b in await (select(catalogBarcodes)..where((b) => b.itemId.equals(itemId))).get()) b.code];

  Future<void> upsertOrder(RemoteOrdersCompanion order, List<RemoteOrderLinesCompanion> lines) async {
    await into(remoteOrders).insertOnConflictUpdate(order);
    await (delete(remoteOrderLines)..where((l) => l.orderId.equals(order.id.value))).go();
    for (final line in lines) {
      await into(remoteOrderLines).insertOnConflictUpdate(line);
    }
  }

  Future<void> deleteOrder(String id) async {
    await (delete(remoteOrderLines)..where((l) => l.orderId.equals(id))).go();
    await (delete(remoteOrders)..where((o) => o.id.equals(id))).go();
  }

  /// [kind] is Delivery or Sales. Newest first.
  Future<List<RemoteOrderRow>> orders(String warehouseId, {required String kind}) => (select(remoteOrders)
        ..where((o) => o.warehouseId.equals(warehouseId) & o.kind.equals(kind))
        ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
      .get();

  Future<List<RemoteOrderLineRow>> orderLinesFor(String orderId) =>
      (select(remoteOrderLines)..where((l) => l.orderId.equals(orderId))).get();

  Future<void> upsertTask(RemoteTasksCompanion task) => into(remoteTasks).insertOnConflictUpdate(task);

  Future<void> deleteTask(String id) => (delete(remoteTasks)..where((t) => t.id.equals(id))).go();

  Future<List<RemoteTaskRow>> tasks(String warehouseId) =>
      (select(remoteTasks)..where((t) => t.warehouseId.equals(warehouseId))).get();

  Future<void> upsertAlert(RemoteAlertsCompanion alert) => into(remoteAlerts).insertOnConflictUpdate(alert);

  Future<void> deleteAlert(String id) => (delete(remoteAlerts)..where((a) => a.id.equals(id))).go();

  /// This warehouse's alerts and those for no warehouse in particular, newest first.
  Future<List<RemoteAlertRow>> alerts(String warehouseId) => (select(remoteAlerts)
        ..where((a) => a.warehouseId.equals(warehouseId) | a.warehouseId.isNull())
        ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
      .get();

  /// The warehouse's people as the server listed them just now: the old list goes.
  Future<void> replaceMembers(String warehouseId, List<WarehouseMembersCompanion> members) => transaction(() async {
        await (delete(warehouseMembers)..where((m) => m.warehouseId.equals(warehouseId))).go();
        for (final m in members) {
          await into(warehouseMembers).insert(m);
        }
      });

  Future<List<WarehouseMemberRow>> members(String warehouseId) => (select(warehouseMembers)
        ..where((m) => m.warehouseId.equals(warehouseId))
        ..orderBy([(m) => OrderingTerm.asc(m.displayName)]))
      .get();
}
