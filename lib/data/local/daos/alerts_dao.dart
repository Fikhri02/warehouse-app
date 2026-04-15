import 'package:drift/drift.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/alert_table.dart';

part 'alerts_dao.g.dart';

@DriftAccessor(tables: [Alerts])
class AlertsDao extends DatabaseAccessor<AppDatabase> with _$AlertsDaoMixin {
  AlertsDao(super.db);

  Future<List<Alert>> getAllAlerts() => select(alerts).get();

  Stream<List<Alert>> watchAllAlerts() => select(alerts).watch();

  Future<void> upsertAlert(AlertsCompanion alert) =>
      into(alerts).insertOnConflictUpdate(alert);

  Future<void> markAllRead() =>
      (update(alerts)..where((a) => a.isRead.equals(false)))
          .write(const AlertsCompanion(isRead: Value(true)));

  Future<void> clearAll() => delete(alerts).go();
}
