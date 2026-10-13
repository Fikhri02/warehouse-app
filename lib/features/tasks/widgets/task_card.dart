import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _two(int n) => n.toString().padLeft(2, '0');

/// "Today 15:00", "Tomorrow 08:05", "Yesterday 17:00", or "20 Oct 17:00".
String dueLabel(DateTime due, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final time = '${_two(due.hour)}:${_two(due.minute)}';
  final days = DateTime(due.year, due.month, due.day).difference(DateTime(today.year, today.month, today.day)).inDays;
  return switch (days) {
    0 => 'Today $time',
    1 => 'Tomorrow $time',
    -1 => 'Yesterday $time',
    _ => '${due.day} ${_months[due.month - 1]} $time',
  };
}

IconData taskIcon(TaskType type) => switch (type) {
      TaskType.stockCount => Icons.inventory_outlined,
      TaskType.stockReceive => Icons.local_shipping_outlined,
      TaskType.other => Icons.assignment_outlined,
    };

/// One task in a list. [showAssignee] adds who it is with (the supervisor's lists).
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap, this.showAssignee = false});

  final StaffTask task;
  final VoidCallback onTap;
  final bool showAssignee;

  Color _statusColor(TaskStatus status) => switch (status) {
        TaskStatus.pending => AppColors.warning,
        TaskStatus.inProgress => AppColors.primary,
        TaskStatus.done => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(task.status);
    final secondary = AppColors.textSecondary(Theme.of(context).brightness);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(taskIcon(task.type), color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.status.label,
                      style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _Meta(Icons.category_outlined, task.type.label, secondary),
                  if (task.locationCode != null) _Meta(Icons.place_outlined, task.locationCode!, secondary),
                  if (task.dueAt != null) _Meta(Icons.schedule, dueLabel(task.dueAt!), secondary),
                  if (showAssignee) _Meta(Icons.person_outline, task.assigneeName ?? 'Unassigned', secondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text, this.color);

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text, style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      );
}
