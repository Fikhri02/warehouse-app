import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

class TaskCard extends StatelessWidget {
  final StaffTask task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  String _typeLabel(TaskType type) => switch (type) {
        TaskType.stockCount => 'Stock Count',
        TaskType.stockReceive => 'Stock Receive',
      };

  Color _statusColor(TaskStatus status) => switch (status) {
        TaskStatus.pending => AppColors.warning,
        TaskStatus.inProgress => AppColors.primary,
        TaskStatus.done => AppColors.success,
      };

  String _statusLabel(TaskStatus status) => switch (status) {
        TaskStatus.pending => 'Pending',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.done => 'Done',
      };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(task.status);
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        task.type == TaskType.stockCount
                            ? Icons.inventory_outlined
                            : Icons.local_shipping_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(_typeLabel(task.type),
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel(task.status),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(task.location,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.grey)),
                  const Spacer(),
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDue(task.dueAt),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDue(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
