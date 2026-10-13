import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/tasks/providers/tasks_provider.dart';
import 'package:warehouse_app/features/tasks/widgets/task_card.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  void _openTask(BuildContext context, StaffTask task) {
    switch (task.type) {
      case TaskType.stockCount:
        context.go(AppRoutes.stockCount);
      case TaskType.stockReceive:
        context.go(AppRoutes.receiving);
      case TaskType.other:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
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
          title: const Text('My Tasks'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(tasksProvider.notifier).refresh(),
            ),
          ],
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
                    Icon(Icons.task_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No tasks assigned',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary(brightness),
                        )),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(tasksProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tasks.length,
                itemBuilder: (context, i) => TaskCard(
                  task: tasks[i],
                  onTap: () => _openTask(context, tasks[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
