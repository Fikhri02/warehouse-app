import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/supervisor/providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reportsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          final tasks = state.completedTasks;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCell(
                        label: 'Completed',
                        value: '${tasks.length}',
                        icon: Icons.check_circle_outline,
                      ),
                      _StatCell(
                        label: 'Count Tasks',
                        value:
                            '${tasks.where((t) => t.type == TaskType.stockCount).length}',
                        icon: Icons.inventory_outlined,
                      ),
                      _StatCell(
                        label: 'Receive Tasks',
                        value:
                            '${tasks.where((t) => t.type == TaskType.stockReceive).length}',
                        icon: Icons.local_shipping_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Completed Tasks',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (tasks.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No completed tasks',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {
                      final task = tasks[i];
                      return ListTile(
                        leading: Icon(
                          task.type == TaskType.stockCount
                              ? Icons.inventory_outlined
                              : Icons.local_shipping_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          task.type == TaskType.stockCount
                              ? 'Stock Count'
                              : 'Stock Receive',
                          style: AppTextStyles.bodyMedium,
                        ),
                        subtitle: Text(
                          task.location,
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: Text(
                          'Done',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.success),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCell({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.headlineSmall),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
