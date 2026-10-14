import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/alerts/open_alert.dart';
import 'package:warehouse_app/features/alerts/providers/alerts_provider.dart';
import 'package:warehouse_app/features/alerts/widgets/alert_card.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  /// An alert is opening, or the screen it opened is still showing: further taps are ignored, so a double tap opens
  /// one screen.
  bool _opening = false;

  Future<void> _open(Alert alert) async {
    if (_opening) return;
    _opening = true;
    try {
      await openAlert(context, ref, alert);
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);
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
          actions: [
            TextButton(
              onPressed: (alertsAsync.valueOrNull?.filtered.where((a) => !a.isRead).isEmpty ?? true)
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
            return RefreshIndicator(
              onRefresh: () => ref.read(alertsProvider.notifier).syncAndReload(),
              child: items.isEmpty
                  ? ListView(children: [
                      const SizedBox(height: 120),
                      Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Center(
                        child: Text('No alerts',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(brightness))),
                      ),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      itemBuilder: (context, i) => AlertCard(alert: items[i], onTap: () => _open(items[i])),
                    ),
            );
          },
        ),
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
      (AlertFilter.sync, 'Sync'),
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
