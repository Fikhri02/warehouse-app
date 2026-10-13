import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/supervisor/providers/assign_tasks_provider.dart';
import 'package:warehouse_app/features/tasks/widgets/task_card.dart';

class AssignTasksScreen extends ConsumerWidget {
  const AssignTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(assignTasksProvider);
    final brightness = Theme.of(context).brightness;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go(AppRoutes.dashboard);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
          title: const Text('Assign Tasks'),
        ),
        body: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No unassigned tasks',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final task = tasks[i];
                return TaskCard(
                  task: task,
                  onTap: () => _showAssignDialog(context, ref, task),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref, StaffTask task) {
    final workers = ['u002 (Arjun Nair)', 'u003 (Mei Ling Tan)'];
    String? selected;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Assign to Worker'),
          content: RadioGroup<String>(
            groupValue: selected,
            onChanged: (v) => setState(() => selected = v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: workers.map((w) {
                final id = w.split(' ').first;
                return RadioListTile<String>(
                  value: id,
                  title: Text(w, style: AppTextStyles.bodySmall),
                  activeColor: AppColors.primary,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selected == null
                  ? null
                  : () {
                      ref.read(assignTasksProvider.notifier).assign(task.id, selected!);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task assigned')),
                      );
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }
}
