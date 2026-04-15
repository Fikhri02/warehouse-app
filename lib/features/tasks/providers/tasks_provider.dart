import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';

export 'package:warehouse_app/data/repositories/tasks_repository.dart'
    show tasksRepositoryProvider;

class TasksNotifier extends AsyncNotifier<List<StaffTask>> {
  @override
  Future<List<StaffTask>> build() async {
    return ref.watch(tasksRepositoryProvider).getMyTasks();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<StaffTask>>(
  TasksNotifier.new,
);
