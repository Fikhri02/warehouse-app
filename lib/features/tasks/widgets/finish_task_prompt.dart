import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/features/tasks/providers/active_task_provider.dart';
import 'package:warehouse_app/features/tasks/providers/tasks_provider.dart';

/// After a count ([TaskType.stockCount]) or receipt ([TaskType.stockReceive]) is submitted: if the person came from a
/// task of that kind, ask whether it is done.
Future<void> offerToFinishTask(BuildContext context, WidgetRef ref, TaskType type) async {
  final task = ref.read(activeTaskProvider.notifier).take(type);
  if (task == null || !context.mounted) return;
  final done = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text("Mark '${task.title}' done?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Not yet')),
        ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Done')),
      ],
    ),
  );
  if (done != true) return;
  try {
    await ref.read(tasksRepositoryProvider).completeTask(task.id);
    ref.invalidate(tasksProvider);
  } on StateError catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
  }
}
