import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'offline_banner.dart';

class AppScaffold extends ConsumerWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).valueOrNull;
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      drawer: session == null ? null : _AppDrawer(session: session),
      bottomNavigationBar: _BottomBar(currentLocation: location),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String currentLocation;
  const _BottomBar({required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    const items = [
      _BarItem(icon: Icons.home_outlined, label: 'Home', route: AppRoutes.dashboard),
      _BarItem(icon: Icons.notifications_outlined, label: 'Alerts', route: AppRoutes.alerts),
      _BarItem(icon: Icons.person_outline, label: 'Profile', route: AppRoutes.profile),
    ];
    final idx = items.indexWhere((i) => currentLocation.startsWith(i.route));

    return BottomNavigationBar(
      currentIndex: idx < 0 ? 0 : idx,
      onTap: (i) => context.go(items[i].route),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.subtitle,
      items: items
          .map((i) => BottomNavigationBarItem(icon: Icon(i.icon), label: i.label))
          .toList(),
    );
  }
}

class _BarItem {
  final IconData icon;
  final String label;
  final String route;
  const _BarItem({required this.icon, required this.label, required this.route});
}

class _AppDrawer extends ConsumerWidget {
  final UserSession session;
  const _AppDrawer({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSupervisor = session.role == UserRole.supervisor;

    return Drawer(
      child: Column(
        children: [
          Container(
            color: AppColors.primary,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24,
                  child: Text(
                    session.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.title.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(session.name,
                    style: AppTextStyles.title.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isSupervisor ? 'Supervisor' : 'Worker',
                    style: AppTextStyles.micro.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const _DrawerItem(Icons.home_outlined, 'Home', AppRoutes.dashboard),
                const _DrawerItem(Icons.inventory_2_outlined, 'Stock Count', AppRoutes.stockCount),
                const _DrawerItem(Icons.move_to_inbox_outlined, 'Stock Receive', AppRoutes.receiving),
                const _DrawerItem(Icons.notifications_outlined, 'Alerts', AppRoutes.alerts),
                const _DrawerItem(Icons.checklist_outlined, 'My Tasks', AppRoutes.tasks),
                if (isSupervisor) ...[
                  const Divider(),
                  const _DrawerItem(Icons.assignment_outlined, 'Assign Tasks', AppRoutes.assignTasks),
                  const _DrawerItem(Icons.bar_chart_outlined, 'Reports', AppRoutes.reports),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.subtitle),
            title: Text('Logout',
                style: AppTextStyles.body.copyWith(color: AppColors.subtitle)),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _DrawerItem(this.icon, this.label, this.route);

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).matchedLocation;
    final active = current.startsWith(route);

    return ListTile(
      leading: Icon(icon,
          color: active ? AppColors.primary : AppColors.subtitle, size: 20),
      title: Text(label,
          style: AppTextStyles.body.copyWith(
              color: active ? AppColors.primary : AppColors.onBackground,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
      tileColor: active ? AppColors.primary.withValues(alpha: 0.08) : null,
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
