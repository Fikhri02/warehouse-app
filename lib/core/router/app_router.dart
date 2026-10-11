import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/models/user_session.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/dashboard/presentation/supervisor_dashboard_screen.dart';
import '../../features/dashboard/presentation/worker_dashboard_screen.dart';
import '../../features/stock_count/presentation/start_count_screen.dart';
import '../../features/stock_count/presentation/create_count_session_screen.dart';
import '../../features/stock_count/presentation/scan_count_screen.dart';
import '../../features/stock_count/presentation/count_manual_entry_screen.dart';
import '../../features/stock_count/presentation/review_count_screen.dart';
import '../../features/receiving/presentation/po_list_screen.dart';
import '../../features/receiving/presentation/po_details_screen.dart';
import '../../features/receiving/presentation/receive_items_screen.dart';
import '../../features/receiving/presentation/receive_summary_screen.dart';
import '../../features/receiving/presentation/signature_pad_screen.dart';
import '../../features/delivery_orders/presentation/delivery_orders_list_screen.dart';
import '../../features/delivery_orders/presentation/delivery_order_create_screen.dart';
import '../../features/delivery_orders/presentation/delivery_order_detail_screen.dart';
import '../../features/sales_orders/presentation/sales_orders_list_screen.dart';
import '../../features/sales_orders/presentation/sales_order_create_screen.dart';
import '../../features/sales_orders/presentation/sales_order_detail_screen.dart';
import '../../features/alerts/screens/alerts_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../features/supervisor/screens/assign_tasks_screen.dart';
import '../../features/supervisor/screens/reports_screen.dart';
import '../../features/supervisor/screens/pending_review_screen.dart';
import '../../features/supervisor/screens/count_review_screen.dart';
import '../../features/auth/presentation/choose_warehouse_screen.dart';
import '../../features/stock_count/presentation/count_item_picker_screen.dart';
import '../../features/stock_count/presentation/count_setup_screen.dart';
import '../config/app_config.dart';
import '../../features/sync/sync_issues_screen.dart';
import 'app_route_observer.dart';
import 'auth_redirect.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _stockCountNavigatorKey = GlobalKey<NavigatorState>();
final _receivingNavigatorKey = GlobalKey<NavigatorState>();
final _profileNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges Riverpod auth state to GoRouter's refreshListenable.
/// Created once; notifies the router whenever auth state changes.
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription<AsyncValue<UserSession?>> _sub;
  late final ProviderSubscription<UserSession?> _lockSub;

  _RouterNotifier(this._ref) {
    _sub = _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
    _lockSub = _ref.listen(lockedSessionProvider, (_, __) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.close();
    _lockSub.close();
    super.dispose();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    return authRedirect(
      auth: _ref.read(authNotifierProvider),
      location: state.matchedLocation,
      locked: _ref.read(lockedSessionProvider),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  final initialSession = ref.read(authNotifierProvider).valueOrNull;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation:
        initialSession == null ? AppRoutes.welcome : AppRoutes.dashboard,
    refreshListenable: notifier,
    observers: [appRouteObserver],
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.chooseWarehouse,
        builder: (_, __) => const ChooseWarehouseScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) {
                  final session = ref.read(authNotifierProvider).valueOrNull;
                  if (session?.role == UserRole.supervisor) {
                    return const SupervisorDashboardScreen();
                  }
                  return const WorkerDashboardScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _stockCountNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.stockCount,
                builder: (_, __) => const StartCountScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, __) => ref.read(useApiProvider) ? const CountSetupScreen() : const CreateCountSessionScreen(),
                  ),
                  GoRoute(
                    path: 'scan',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, __) => const ScanCountScreen(),
                    routes: [
                      GoRoute(
                        path: 'manual-entry',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (_, state) => ref.read(useApiProvider)
                            ? CountItemPickerScreen(initialCode: state.extra as String?)
                            : CountManualEntryScreen(initialCode: state.extra as String?),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'review',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, __) => const ReviewCountScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _receivingNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.receiving,
                builder: (_, __) => const PoListScreen(),
                routes: [
                  GoRoute(
                    path: 'items',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, __) => const ReceiveItemsScreen(),
                  ),
                  GoRoute(
                    path: 'summary',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, __) => const ReceiveSummaryScreen(),
                    routes: [
                      GoRoute(
                        path: 'signature',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (_, __) => const SignaturePadScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'details',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) =>
                        PoDetailsScreen(poId: state.extra as String),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.alerts,
        builder: (_, __) => const AlertsScreen(),
      ),
      GoRoute(
        path: AppRoutes.syncIssues,
        builder: (_, __) => const SyncIssuesScreen(),
      ),
      GoRoute(
        path: AppRoutes.deliveryOrders,
        builder: (_, __) => const DeliveryOrdersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.deliveryOrderNew,
        builder: (_, state) => DeliveryOrderCreateScreen(
          editingOrder: state.extra as dynamic,
        ),
      ),
      GoRoute(
        path: AppRoutes.deliveryOrderDetail,
        builder: (_, state) =>
            DeliveryOrderDetailScreen(id: state.extra as int),
      ),
      GoRoute(
        path: AppRoutes.salesOrders,
        builder: (_, __) => const SalesOrdersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.salesOrderNew,
        builder: (_, state) => SalesOrderCreateScreen(
          editingOrder: state.extra as dynamic,
        ),
      ),
      GoRoute(
        path: AppRoutes.salesOrderDetail,
        builder: (_, state) => SalesOrderDetailScreen(id: state.extra as int),
      ),
      GoRoute(
        path: AppRoutes.tasks,
        builder: (_, __) => const TasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.assignTasks,
        builder: (_, __) => const AssignTasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (_, __) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.pendingReview,
        builder: (_, __) => const PendingReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.pendingReviewDetail,
        builder: (_, state) => CountReviewScreen(sessionId: state.extra as String),
      ),
    ],
  );
});
