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

class AssignTasksScreen extends ConsumerStatefulWidget {
  const AssignTasksScreen({super.key});

  @override
  ConsumerState<AssignTasksScreen> createState() => _AssignTasksScreenState();
}

class _AssignTasksScreenState extends ConsumerState<AssignTasksScreen> {
  /// A picker is open or about to open (the team may still be loading): further taps wait for it.
  bool _picking = false;

  Future<void> _assign(StaffTask task) async {
    if (_picking) return;
    _picking = true;
    try {
      final team = await ref.read(teamProvider.future);
      if (!mounted) return;
      final chosen = await pickAssignee(context, team: team, current: task.assigneeId);
      if (chosen == null || !mounted) return;
      await ref.read(assignTasksProvider.notifier).assign(task.id, chosen);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task assigned')));
    } on StateError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      _picking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(assignTasksProvider);
    // Loads the team while the screen is open, so the picker has it. The task list takes its names from the saved team,
    // so it reloads once a fresh team has arrived.
    ref.listen(teamProvider, (_, next) {
      if (next.hasValue && !next.isLoading) ref.invalidate(assignTasksProvider);
    });
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
                    for (final t in unassigned) TaskCard(task: t, showAssignee: true, onTap: () => _assign(t)),
                  ],
                  if (assigned.isNotEmpty) ...[
                    header('Assigned'),
                    for (final t in assigned) TaskCard(task: t, showAssignee: true, onTap: () => _assign(t)),
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
