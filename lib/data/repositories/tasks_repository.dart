import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';

abstract class TasksRepository {
  Future<List<StaffTask>> getTasks();
  Future<List<StaffTask>> getMyTasks();
  Future<List<StaffTask>> getAssignableTasks();
  Future<void> assignTask(StaffTask task);
  Future<List<StaffTask>> getCompletedTasks();
}

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  throw UnimplementedError('tasksRepositoryProvider not overridden');
});
