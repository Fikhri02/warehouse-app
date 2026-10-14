import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/features/alerts/providers/alerts_provider.dart';

/// Tapping an alert (spec addendum 3d §2): marks it read and opens what it is about. A task that is done, gone or now
/// someone else's, or a count already reviewed, says "No longer available" and stays here. Low stock only marks read:
/// its body says it all. Completes when the screen it opened is closed again, so the caller can ignore taps until then.
Future<void> openAlert(BuildContext context, WidgetRef ref, Alert alert) async {
  await ref.read(alertsProvider.notifier).markRead(alert.id);
  if (!context.mounted) return;
  switch (alert.type) {
    case AlertType.taskAssigned:
      final id = alert.taskId;
      final task = id == null ? null : await ref.read(tasksRepositoryProvider).getTask(id);
      if (!context.mounted) return;
      final me = ref.read(authNotifierProvider).valueOrNull?.userId;
      if (task == null || task.status == TaskStatus.done || task.assigneeId != me) {
        _gone(context);
      } else {
        context.go(AppRoutes.tasks, extra: id);
      }
    case AlertType.countToReview:
      final id = alert.sessionId;
      final waiting = id == null ? const <CountSummary>[] : await ref.read(stockCountRepositoryProvider).getCountsToReview();
      if (!context.mounted) return;
      if (waiting.any((c) => c.id == id)) {
        await context.push(AppRoutes.pendingReviewDetail, extra: id); // held until they come back
      } else {
        _gone(context);
      }
    case AlertType.syncConflict:
      await context.push(AppRoutes.syncIssues);
    case AlertType.lowStock:
      break;
  }
}

void _gone(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No longer available')));
