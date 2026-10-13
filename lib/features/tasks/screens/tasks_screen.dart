import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/tasks/providers/active_task_provider.dart';
import 'package:warehouse_app/features/tasks/providers/tasks_provider.dart';
import 'package:warehouse_app/features/tasks/widgets/task_card.dart';
import 'package:warehouse_app/features/tasks/widgets/task_sheet.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key, this.openTaskId});

  /// From an alert: open this task's sheet once the list has loaded.
  final String? openTaskId;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _openedRequested = false;

  void _say(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openSheet(StaffTask task) => showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) => TaskSheet(
          task: task,
          onStart: () => _act(sheetContext, () => ref.read(tasksProvider.notifier).start(task.id), 'Task started'),
          onDone: () => _act(sheetContext, () => ref.read(tasksProvider.notifier).complete(task.id), 'Task done'),
          onGo: () => _go(sheetContext, task),
        ),
      );

  Future<void> _act(BuildContext sheetContext, Future<void> Function() action, String done) async {
    Navigator.pop(sheetContext);
    try {
      await action();
      _say(done);
    } on StateError catch (e) {
      _say(e.message);
    }
  }

  /// Starts a waiting task, remembers it for the "Mark done?" prompt, and goes to where its work happens.
  Future<void> _go(BuildContext sheetContext, StaffTask task) async {
    Navigator.pop(sheetContext);
    try {
      if (task.status == TaskStatus.pending) await ref.read(tasksProvider.notifier).start(task.id);
    } on StateError catch (e) {
      _say(e.message);
      return;
    }
    ref.read(activeTaskProvider.notifier).remember(task);
    if (mounted) context.go(task.type == TaskType.stockCount ? AppRoutes.stockCount : AppRoutes.receiving);
  }

  void _openRequested(List<StaffTask> tasks) {
    final id = widget.openTaskId;
    if (id == null || _openedRequested) return;
    _openedRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final task = tasks.where((t) => t.id == id).firstOrNull;
      if (task == null) {
        _say('No longer available');
      } else {
        _openSheet(task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          leading: BackButton(onPressed: () => context.go(AppRoutes.dashboard)),
          title: const Text('My Tasks'),
        ),
        body: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (tasks) {
            _openRequested(tasks);
            return RefreshIndicator(
              onRefresh: () => ref.read(tasksProvider.notifier).syncAndReload(),
              child: tasks.isEmpty
                  ? ListView(children: [
                      const SizedBox(height: 120),
                      Icon(Icons.task_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Center(
                        child: Text('No tasks assigned',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(brightness))),
                      ),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: tasks.length,
                      itemBuilder: (context, i) => TaskCard(task: tasks[i], onTap: () => _openSheet(tasks[i])),
                    ),
            );
          },
        ),
      ),
    );
  }
}
