import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/tasks/widgets/task_card.dart';

/// A task's details and what can be done with it next (spec addendum 3d §2).
class TaskSheet extends StatelessWidget {
  const TaskSheet({super.key, required this.task, required this.onStart, required this.onDone, required this.onGo});

  final StaffTask task;
  final VoidCallback onStart;
  final VoidCallback onDone;

  /// Opens counting or receiving. Not shown for an Other task.
  final VoidCallback onGo;

  @override
  Widget build(BuildContext context) {
    final secondary = AppColors.textSecondary(Theme.of(context).brightness);
    Widget line(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Icon(icon, size: 18, color: secondary),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
          ]),
        );
    Widget button(Widget child) => Padding(padding: const EdgeInsets.only(top: 8), child: SizedBox(width: double.infinity, child: child));

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: AppTextStyles.title),
            const SizedBox(height: 12),
            line(taskIcon(task.type), task.type.label),
            if (task.locationCode != null) line(Icons.place_outlined, task.locationCode!),
            if (task.dueAt != null) line(Icons.schedule, 'Due ${dueLabel(task.dueAt!)}'),
            line(Icons.flag_outlined, task.status.label),
            const SizedBox(height: 8),
            if (task.type != TaskType.other)
              button(OutlinedButton(
                onPressed: onGo,
                child: Text(task.type == TaskType.stockCount ? 'Go to counting' : 'Go to receiving'),
              )),
            if (task.status == TaskStatus.pending) button(ElevatedButton(onPressed: onStart, child: const Text('Start'))),
            if (task.status == TaskStatus.inProgress) button(ElevatedButton(onPressed: onDone, child: const Text('Done'))),
          ],
        ),
      ),
    );
  }
}
