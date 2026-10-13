import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/supervisor/providers/assign_tasks_provider.dart';
import 'package:warehouse_app/features/supervisor/widgets/assignee_picker.dart';
import 'package:warehouse_app/features/tasks/widgets/task_card.dart';

class AssignTasksScreen extends ConsumerWidget {
  const AssignTasksScreen({super.key});

  Future<void> _assign(BuildContext context, WidgetRef ref, StaffTask task) async {
    final team = await ref.read(teamProvider.future);
    if (!context.mounted) return;
    final chosen = await pickAssignee(context, team: team, current: task.assigneeId);
    if (chosen == null || !context.mounted) return;
    try {
      await ref.read(assignTasksProvider.notifier).assign(task.id, chosen);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task assigned')));
    } on StateError catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(assignTasksProvider);
    ref.watch(teamProvider); // loads the team while the screen is open, so the picker has it
    final secondary = AppColors.textSecondary(Theme.of(context).brightness);

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(text, style: AppTextStyles.bodySmall.copyWith(color: secondary, fontWeight: FontWeight.w600)),
        );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go(AppRoutes.dashboard);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go(AppRoutes.dashboard)),
          title: const Text('Assign Tasks'),
          actions: [
            IconButton(icon: const Icon(Icons.add), tooltip: 'New task', onPressed: () => context.push(AppRoutes.taskNew)),
          ],
        ),
        body: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (tasks) {
            final unassigned = tasks.where((t) => t.assigneeId == null).toList();
            final assigned = tasks.where((t) => t.assigneeId != null).toList();
            return RefreshIndicator(
              onRefresh: () => ref.read(assignTasksProvider.notifier).syncAndReload(),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: Center(child: Text('No open tasks', style: AppTextStyles.bodyMedium.copyWith(color: secondary))),
                    ),
                  if (unassigned.isNotEmpty) ...[
                    header('Unassigned'),
                    for (final t in unassigned) TaskCard(task: t, showAssignee: true, onTap: () => _assign(context, ref, t)),
                  ],
                  if (assigned.isNotEmpty) ...[
                    header('Assigned'),
                    for (final t in assigned) TaskCard(task: t, showAssignee: true, onTap: () => _assign(context, ref, t)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
