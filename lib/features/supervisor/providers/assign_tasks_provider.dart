import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';

export 'package:warehouse_app/data/repositories/tasks_repository.dart'
    show tasksRepositoryProvider;

/// Every task in the warehouse that is not done, for a supervisor to assign.
class AssignTasksNotifier extends AsyncNotifier<List<StaffTask>> {
  @override
  Future<List<StaffTask>> build() async {
    ref.watch(authNotifierProvider.select((auth) => (auth.valueOrNull?.userId, auth.valueOrNull?.warehouseId)));
    ref.watch(pulledProvider);
    return ref.watch(tasksRepositoryProvider).getOpenTasks();
  }

  Future<void> syncAndReload() async {
    await ref.read(syncCoordinatorProvider).syncNow();
    ref.invalidateSelf();
    await future;
  }

  Future<void> assign(String id, String assigneeId) async {
    await ref.read(tasksRepositoryProvider).assignTask(id, assigneeId);
    ref.invalidateSelf();
  }

  Future<void> create(NewTask task) async {
    await ref.read(tasksRepositoryProvider).createTask(task);
    ref.invalidateSelf();
  }
}

final assignTasksProvider =
    AsyncNotifierProvider<AssignTasksNotifier, List<StaffTask>>(
  AssignTasksNotifier.new,
);

/// The warehouse's people for the picker. Loaded each time a screen that needs it opens: from the server when it can
/// be reached, else the list saved last time.
final teamProvider = FutureProvider.autoDispose<List<TeamMember>>((ref) {
  ref.watch(authNotifierProvider.select((auth) => auth.valueOrNull?.warehouseId));
  return ref.watch(tasksRepositoryProvider).getTeam();
});

final taskPlacesProvider = FutureProvider.autoDispose<List<TaskPlace>>((ref) {
  ref.watch(authNotifierProvider.select((auth) => auth.valueOrNull?.warehouseId));
  return ref.watch(tasksRepositoryProvider).getPlaces();
});
