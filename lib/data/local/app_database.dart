import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/data/local/tables/user_session_table.dart';
import 'package:warehouse_app/data/local/tables/alert_table.dart';
import 'package:warehouse_app/data/local/tables/staff_task_table.dart';
import 'package:warehouse_app/data/local/tables/count_session_table.dart';
import 'package:warehouse_app/data/local/tables/purchase_order_table.dart';
import 'package:warehouse_app/data/local/tables/sync_queue_table.dart';
import 'package:warehouse_app/data/local/daos/alerts_dao.dart';
import 'package:warehouse_app/data/local/daos/tasks_dao.dart';
import 'package:warehouse_app/data/local/daos/count_session_dao.dart';
import 'package:warehouse_app/data/local/daos/receiving_dao.dart';
import 'package:warehouse_app/data/local/daos/sync_queue_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserSessions,
    Alerts,
    StaffTasks,
    CountSessions,
    CountItems,
    PurchaseOrders,
    PoLineItems,
    SyncQueue,
  ],
  daos: [
    AlertsDao,
    TasksDao,
    CountSessionDao,
    ReceivingDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'warehouse_app'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

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
        },
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
