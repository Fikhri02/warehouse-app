import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/router/app_routes.dart';

/// The task a person went to counting or receiving from, so the app can offer to finish it once the count or receipt
/// is in (spec addendum 3d, option C). Kept in memory only: closing the app forgets it.
class ActiveTaskNotifier extends Notifier<StaffTask?> {
  @override
  StaffTask? build() => null;

  void remember(StaffTask task) => state = task;

  void forget() => state = null;

  /// The remembered task if it is of [type]; forgotten either way, so it is offered at most once.
  StaffTask? take(TaskType type) {
    final task = state;
    state = null;
    return task?.type == type ? task : null;
  }
}

final activeTaskProvider = NotifierProvider<ActiveTaskNotifier, StaffTask?>(ActiveTaskNotifier.new);

/// Where a task's work happens. Going anywhere else forgets the task (wired in app_router.dart).
bool keepsActiveTask(String path) =>
    path.startsWith(AppRoutes.stockCount) || path.startsWith(AppRoutes.receiving) || path.startsWith(AppRoutes.tasks);
