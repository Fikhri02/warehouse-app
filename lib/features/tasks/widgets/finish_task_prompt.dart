import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/features/tasks/providers/active_task_provider.dart';
import 'package:warehouse_app/features/tasks/providers/tasks_provider.dart';

/// After a count ([TaskType.stockCount]) or receipt ([TaskType.stockReceive]) is submitted: if the person came from a
/// task of that kind, and it is still theirs and not done, ask whether it is done. Never throws: the count or receipt
/// is already saved, and a task that could not be finished here can be finished from My Tasks.
Future<void> offerToFinishTask(BuildContext context, WidgetRef ref, TaskType type) async {
  final remembered = ref.read(activeTaskProvider.notifier).take(type);
  if (remembered == null) return;
  final task = await _current(ref, remembered.id); // it may have moved on meanwhile
  final me = ref.read(authNotifierProvider).valueOrNull?.userId;
  if (task == null || task.status == TaskStatus.done || task.assigneeId != me || !context.mounted) return;
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
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't mark the task done — you can finish it from My Tasks")),
      );
    }
  }
}

Future<StaffTask?> _current(WidgetRef ref, String id) async {
  try {
    return await ref.read(tasksRepositoryProvider).getTask(id);
  } on Object {
    return null;
  }
}
