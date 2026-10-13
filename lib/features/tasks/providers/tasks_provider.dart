import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';

export 'package:warehouse_app/data/repositories/tasks_repository.dart'
    show tasksRepositoryProvider;

class TasksNotifier extends AsyncNotifier<List<StaffTask>> {
  @override
  Future<List<StaffTask>> build() async {
    // Another warehouse or another person: another list. A finished pull may have brought new tasks.
    ref.watch(authNotifierProvider.select((auth) => (auth.valueOrNull?.userId, auth.valueOrNull?.warehouseId)));
    ref.watch(pulledProvider);
    return ref.watch(tasksRepositoryProvider).getMyTasks();
  }

  /// Pull to refresh: sends anything queued and fetches the latest, then reloads.
  Future<void> syncAndReload() async {
    await ref.read(syncCoordinatorProvider).syncNow();
    ref.invalidateSelf();
    await future;
  }

  Future<void> start(String id) async {
    await ref.read(tasksRepositoryProvider).startTask(id);
    ref.invalidateSelf();
  }

  Future<void> complete(String id) async {
    await ref.read(tasksRepositoryProvider).completeTask(id);
    ref.invalidateSelf();
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<StaffTask>>(
  TasksNotifier.new,
);
