import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';

export 'package:warehouse_app/data/repositories/tasks_repository.dart'
    show tasksRepositoryProvider;

class AssignTasksNotifier extends AsyncNotifier<List<StaffTask>> {
  @override
  Future<List<StaffTask>> build() async {
    return ref.watch(tasksRepositoryProvider).getAssignableTasks();
  }

  Future<void> assignTask(StaffTask task) async {
    await ref.read(tasksRepositoryProvider).assignTask(task);
    ref.invalidateSelf();
  }
}

final assignTasksProvider =
    AsyncNotifierProvider<AssignTasksNotifier, List<StaffTask>>(
  AssignTasksNotifier.new,
);
