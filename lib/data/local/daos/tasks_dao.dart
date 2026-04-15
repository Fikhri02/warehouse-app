import 'package:drift/drift.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/staff_task_table.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [StaffTasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  Future<List<StaffTask>> getAllTasks() => select(staffTasks).get();

  Future<List<StaffTask>> getTasksForWorker(String workerId) =>
      (select(staffTasks)..where((t) => t.assignedTo.equals(workerId))).get();

  Future<void> upsertTask(StaffTasksCompanion task) =>
      into(staffTasks).insertOnConflictUpdate(task);

  Future<void> updateStatus(String taskId, String status) =>
      (update(staffTasks)..where((t) => t.id.equals(taskId)))
          .write(StaffTasksCompanion(status: Value(status)));
}
