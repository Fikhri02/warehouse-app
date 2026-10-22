import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/alerts/widgets/alerts_bell.dart';
import 'atura_logo.dart';
import 'offline_banner.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  DateTime? _lastBackPressAt;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authNotifierProvider).valueOrNull;
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = widget.navigationShell.currentIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (currentIndex != 0) {
          widget.navigationShell.goBranch(0);
          return;
        }

        final now = DateTime.now();
        final shouldExit = _lastBackPressAt != null &&
            now.difference(_lastBackPressAt!) <= const Duration(seconds: 2);

        if (shouldExit) {
          SystemNavigator.pop();
          return;
        }

        _lastBackPressAt = now;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
      },
      child: Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: widget.navigationShell),
          ],
        ),
        drawer: session == null ? null : _AppDrawer(session: session),
        bottomNavigationBar: _BottomBar(
          currentLocation: location,
          navigationShell: widget.navigationShell,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String currentLocation;
  final StatefulNavigationShell navigationShell;
  const _BottomBar({
    required this.currentLocation,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    const items = [
      _BarItem(
        icon: _BrandHomeIcon(active: false, size: 24),
        activeIcon: _BrandHomeIcon(active: true, size: 24),
        label: 'Home',
        route: AppRoutes.dashboard,
      ),
      _BarItem(
        icon: Icon(Icons.inventory_2_outlined),
        label: 'Stock Count',
        route: AppRoutes.stockCount,
      ),
      _BarItem(
        icon: Icon(Icons.move_to_inbox_outlined),
        label: 'Stock Receive',
        route: AppRoutes.receiving,
      ),
      _BarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
        route: AppRoutes.profile,
      ),
    ];
    final idx = items.indexWhere((i) => currentLocation.startsWith(i.route));

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      currentIndex: idx < 0 ? navigationShell.currentIndex : idx,
      onTap: (i) => navigationShell.goBranch(
        i,
        initialLocation: i == navigationShell.currentIndex,
      ),
      selectedItemColor: brightness == Brightness.dark
          ? AppColors.darkAccent
          : AppColors.primary,
      unselectedItemColor: AppColors.textSecondary(brightness),
      items: items
          .map((i) => BottomNavigationBarItem(
                icon: i.icon,
                activeIcon: i.activeIcon,
                label: i.label,
              ))
          .toList(),
    );
  }
}

class _BarItem {
  final Widget icon;
  final Widget? activeIcon;
  final String label;
  final String route;
  const _BarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

class _AppDrawer extends ConsumerWidget {
  final UserSession session;
  const _AppDrawer({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSupervisor = session.role == UserRole.supervisor;
    final brightness = Theme.of(context).brightness;

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                const _DrawerItem(
                    Icons.home_outlined, 'Home', AppRoutes.dashboard,
                    useBrandIcon: true),
                const _DrawerItem(Icons.inventory_2_outlined, 'Stock Count',
                    AppRoutes.stockCount),
                const _DrawerItem(Icons.move_to_inbox_outlined, 'Stock Receive',
                    AppRoutes.receiving),
                const _DrawerItem(
                    Icons.notifications_outlined, 'Alerts', AppRoutes.alerts,
                    trailing: UnreadAlertsCount()),
                const _DrawerItem(
                    Icons.checklist_outlined, 'My Tasks', AppRoutes.tasks),
                if (isSupervisor) ...[
                  const Divider(),
                  const _DrawerItem(Icons.assignment_outlined, 'Assign Tasks',
                      AppRoutes.assignTasks),
                  const _DrawerItem(
                      Icons.bar_chart_outlined, 'Reports', AppRoutes.reports),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading:
                Icon(Icons.logout, color: AppColors.textSecondary(brightness)),
            title: Text('Logout',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary(brightness),
                )),
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
  final bool useBrandIcon;
  final Widget? trailing;
  const _DrawerItem(this.icon, this.label, this.route,
      {this.useBrandIcon = false, this.trailing});

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).matchedLocation;
    final active = current.startsWith(route);
    final brightness = Theme.of(context).brightness;
    final activeColor = brightness == Brightness.dark
        ? AppColors.darkAccent
        : AppColors.primary;
    final isTabRoute = route == AppRoutes.dashboard ||
        route == AppRoutes.stockCount ||
        route == AppRoutes.receiving ||
        route == AppRoutes.profile;

    return ListTile(
      leading: useBrandIcon
          ? _BrandHomeIcon(active: active, size: 26)
          : Icon(icon,
              color: active ? activeColor : AppColors.textSecondary(brightness),
              size: 20),
      title: Text(label,
          style: AppTextStyles.body.copyWith(
              color: active ? activeColor : AppColors.textPrimary(brightness),
              fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
      trailing: trailing,
      tileColor: active ? activeColor.withValues(alpha: 0.12) : null,
      onTap: () {
        Navigator.pop(context);
        if (isTabRoute) {
          context.go(route);
        } else {
          context.push(route);
        }
      },
    );
  }
}

class _BrandHomeIcon extends StatelessWidget {
  final bool active;
  final double size;
  const _BrandHomeIcon({required this.active, required this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // The A's slits are too thin to outline at tab size, so inactive is the filled mark in grey.
    final color = active
        ? (isDark ? AppColors.darkAccent : AppColors.primary)
        : (isDark ? AppColors.darkSubtitle : AppColors.subtitle);
    return SizedBox.square(
      dimension: size,
      child: Center(child: AturaMark(width: size, color: color)),
    );
  }
}
