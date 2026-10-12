import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/data/local/tables/user_session_table.dart';
import 'package:warehouse_app/data/local/tables/alert_table.dart';
import 'package:warehouse_app/data/local/tables/staff_task_table.dart';
import 'package:warehouse_app/data/local/tables/count_session_table.dart';
import 'package:warehouse_app/data/local/tables/order_tables.dart';
import 'package:warehouse_app/data/local/tables/purchase_order_table.dart';
import 'package:warehouse_app/data/local/tables/sync_queue_table.dart';
import 'package:warehouse_app/data/local/tables/server_tables.dart';
import 'package:warehouse_app/data/local/daos/alerts_dao.dart';
import 'package:warehouse_app/data/local/daos/tasks_dao.dart';
import 'package:warehouse_app/data/local/daos/count_session_dao.dart';
import 'package:warehouse_app/data/local/daos/orders_dao.dart';
import 'package:warehouse_app/data/local/daos/receiving_dao.dart';
import 'package:warehouse_app/data/local/daos/sync_queue_dao.dart';
import 'package:warehouse_app/data/local/daos/server_mirror_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserSessions,
    Alerts,
    StaffTasks,
    CountSessions,
    CountItems,
    LocationEntries,
    DeliveryOrderEntries,
    SalesOrderEntries,
    OrderItemEntries,
    OrderStatusHistoryEntries,
    PurchaseOrders,
    PoLineItems,
    SyncQueue,
    CatalogItems,
    CatalogBarcodes,
    WarehouseLocations,
    RemoteCountSessions,
    RemoteCountLines,
    SyncCursors,
    RemotePurchaseOrders,
    RemotePoLines,
    RemoteOrders,
    RemoteOrderLines,
  ],
  daos: [
    AlertsDao,
    TasksDao,
    CountSessionDao,
    OrdersDao,
    ReceivingDao,
    SyncQueueDao,
    ServerMirrorDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'warehouse_app'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await customStatement(
              "ALTER TABLE count_items ADD COLUMN entry_method TEXT NOT NULL DEFAULT 'scanned'",
            );
          }
          if (from < 3) {
            await customStatement(
              'ALTER TABLE count_sessions ADD COLUMN location_id TEXT',
            );
            await customStatement(
              'ALTER TABLE count_sessions ADD COLUMN assigned_worker_id TEXT',
            );
            await customStatement(
              'ALTER TABLE count_sessions ADD COLUMN deadline INTEGER',
            );
            await customStatement(
              'ALTER TABLE count_sessions ADD COLUMN zone_aisle TEXT',
            );
          }
          if (from < 4) {
            await migrator.addColumn(purchaseOrders, purchaseOrders.dueDate);
            await migrator.addColumn(poLineItems, poLineItems.flagReason);
          }
          if (from < 5) {
            await migrator.createTable(locationEntries);
            await migrator.createTable(deliveryOrderEntries);
            await migrator.createTable(salesOrderEntries);
            await migrator.createTable(orderItemEntries);
            await migrator.createTable(orderStatusHistoryEntries);
          }
          if (from < 6) {
            await migrator.createTable(catalogItems);
            await migrator.createTable(catalogBarcodes);
            await migrator.createTable(warehouseLocations);
            await migrator.createTable(remoteCountSessions);
            await migrator.createTable(remoteCountLines);
            await migrator.createTable(syncCursors);
            await migrator.addColumn(countItems, countItems.itemId);
            await migrator.addColumn(syncQueue, syncQueue.idempotencyKey);
            await migrator.addColumn(syncQueue, syncQueue.status);
            await migrator.addColumn(syncQueue, syncQueue.attempts);
            await migrator.addColumn(syncQueue, syncQueue.lastError);
            await migrator.addColumn(syncQueue, syncQueue.warehouseId);
            // Rows the old service already marked done must not be sent again.
            await customStatement("UPDATE sync_queue SET status = 'synced' WHERE synced = 1");
          }
          if (from < 7) {
            await migrator.createTable(remotePurchaseOrders);
            await migrator.createTable(remotePoLines);
            // Existing cursors get mirror version 1, older than kMirrorVersion: the next pull starts from 0 and brings
            // the purchase orders a 3a phone skipped. Below 6, sync_cursors was just created with the column.
            if (from >= 6) {
              await migrator.addColumn(syncCursors, syncCursors.mirrorVersion);
              await migrator.addColumn(syncCursors, syncCursors.caughtUpThrough);
            }
          }
          if (from < 8) {
            // kMirrorVersion 3 makes the next pull start from 0 and bring the orders a 3b phone skipped.
            await migrator.createTable(remoteOrders);
            await migrator.createTable(remoteOrderLines);
          }
        },
      );

  /// Signing out: neither this person's work nor the server's data stays on the phone.
  Future<void> clearServerData() => transaction(() async {
        for (final table in <TableInfo>[
          catalogItems,
          catalogBarcodes,
          warehouseLocations,
          remoteCountSessions,
          remoteCountLines,
          syncCursors,
          syncQueue,
          countItems,
          countSessions,
          remotePurchaseOrders,
          remotePoLines,
          remoteOrders,
          remoteOrderLines,
        ]) {
          await delete(table).go();
        }
      });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
