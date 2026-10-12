import 'package:drift/drift.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/server_tables.dart';

part 'server_mirror_dao.g.dart';

@DriftAccessor(tables: [CatalogItems, CatalogBarcodes, WarehouseLocations, RemoteCountSessions, RemoteCountLines, SyncCursors, RemotePurchaseOrders, RemotePoLines])
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
}
