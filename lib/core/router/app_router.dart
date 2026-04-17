import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/models/user_session.dart';
import '../../features/auth/presentation/login_screen.dart';
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
import '../../features/alerts/screens/alerts_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../features/supervisor/screens/assign_tasks_screen.dart';
import '../../features/supervisor/screens/reports_screen.dart';
import '../../features/supervisor/screens/pending_review_screen.dart';
import 'app_route_observer.dart';
import 'app_routes.dart';

/// Bridges Riverpod auth state to GoRouter's refreshListenable.
/// Created once; notifies the router whenever auth state changes.
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription<AsyncValue<UserSession?>> _sub;

  _RouterNotifier(this._ref) {
    _sub = _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    // While loading, don't redirect — let GoRouter stay where it is
    if (authState.isLoading) return null;

    final session = authState.valueOrNull;
    final isLoggedIn = session != null;
    final isLoginRoute = state.matchedLocation == AppRoutes.login;

    if (!isLoggedIn && !isLoginRoute) return AppRoutes.login;
    if (isLoggedIn && isLoginRoute) return AppRoutes.dashboard;

    // Enforce supervisor-only routes
    final supervisorOnly = [
      AppRoutes.assignTasks,
      AppRoutes.reports,
      AppRoutes.pendingReview,
    ];
    if (isLoggedIn &&
        session.role == UserRole.worker &&
        supervisorOnly.contains(state.matchedLocation)) {
      return AppRoutes.dashboard;
    }

    return null;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    observers: [appRouteObserver],
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
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
          GoRoute(
            path: AppRoutes.alerts,
            builder: (_, __) => const AlertsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.stockCount,
        builder: (_, __) => const StartCountScreen(),
      ),
      GoRoute(
        path: AppRoutes.stockCountCreate,
        builder: (_, __) => const CreateCountSessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.stockCountScan,
        builder: (_, __) => const ScanCountScreen(),
        routes: [
          GoRoute(
            path: 'manual-entry',
            builder: (_, state) => CountManualEntryScreen(
              initialCode: state.extra as String?,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.stockCountReview,
        builder: (_, __) => const ReviewCountScreen(),
      ),
      GoRoute(
        path: AppRoutes.receiving,
        builder: (_, __) => const PoListScreen(),
      ),
      GoRoute(
        path: AppRoutes.receivingItems,
        builder: (_, __) => const ReceiveItemsScreen(),
      ),
      GoRoute(
        path: AppRoutes.receivingSummary,
        builder: (_, __) => const ReceiveSummaryScreen(),
        routes: [
          GoRoute(
            path: 'signature',
            builder: (_, __) => const SignaturePadScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.receivingDetails,
        builder: (_, state) => PoDetailsScreen(poId: state.extra as String),
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
    ],
  );
});
