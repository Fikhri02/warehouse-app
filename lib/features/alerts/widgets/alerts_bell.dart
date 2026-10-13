import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/features/alerts/providers/alerts_provider.dart';

/// The dashboard's alerts button, with how many are unread.
class AlertsBell extends ConsumerWidget {
  const AlertsBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(alertsProvider).valueOrNull?.unreadCount ?? 0;
    return IconButton(
      tooltip: 'Alerts',
      icon: Badge(
        isLabelVisible: unread > 0,
        backgroundColor: AppColors.unread,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: const Icon(Icons.notifications_outlined, color: Colors.white),
      ),
      onPressed: () => context.push(AppRoutes.alerts),
    );
  }
}
