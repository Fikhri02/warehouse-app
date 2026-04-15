import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';

class ReportsState {
  final List<StaffTask> completedTasks;
  const ReportsState({required this.completedTasks});
}

class ReportsNotifier extends AsyncNotifier<ReportsState> {
  @override
  Future<ReportsState> build() async {
    final completed =
        await ref.watch(tasksRepositoryProvider).getCompletedTasks();
    return ReportsState(completedTasks: completed);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final reportsProvider =
    AsyncNotifierProvider<ReportsNotifier, ReportsState>(
  ReportsNotifier.new,
);
