import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/alerts/providers/alerts_provider.dart';
import 'package:warehouse_app/features/alerts/widgets/alert_card.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: alertsAsync.valueOrNull?.unreadCount == 0
                ? null
                : () => ref.read(alertsProvider.notifier).markAllRead(),
            child: Text(
              'Mark all read',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _FilterTabs(
            current: alertsAsync.valueOrNull?.filter ?? AlertFilter.all,
            onChanged: (f) => ref.read(alertsProvider.notifier).setFilter(f),
          ),
        ),
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          final items = state.filtered;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No alerts',
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
            itemCount: items.length,
            itemBuilder: (context, i) => AlertCard(alert: items[i]),
          );
        },
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final AlertFilter current;
  final ValueChanged<AlertFilter> onChanged;

  const _FilterTabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (AlertFilter.all, 'All'),
      (AlertFilter.stock, 'Stock'),
      (AlertFilter.tasks, 'Tasks'),
    ];
    return Row(
      children: tabs.map((t) {
        final selected = current == t.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(t.$1),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                t.$2,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? Colors.white : Colors.white60,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
