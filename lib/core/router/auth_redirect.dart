import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_session.dart';
import 'app_routes.dart';

const _supervisorOnly = [AppRoutes.assignTasks, AppRoutes.taskNew, AppRoutes.reports, AppRoutes.pendingReview, AppRoutes.pendingReviewDetail];

/// Where to send someone who asked for [location], or null to let them through. [held] keeps a fresh sign-in on the
/// sign-in screen while its check-in plays. Sign in is pushed over Welcome, and the router may report either.
String? authRedirect({
  required AsyncValue<UserSession?> auth,
  required String location,
  UserSession? locked,
  bool held = false,
}) {
  if (auth.isLoading) return null;
  final onEntry = location == AppRoutes.login || location == AppRoutes.welcome;
  if (held && onEntry) return null;
  if (auth.valueOrNull == null && locked != null) return location == AppRoutes.login ? null : AppRoutes.login;
  final session = auth.valueOrNull;
  if (session == null) return onEntry ? null : AppRoutes.welcome;
  if (session.needsWarehouse) return location == AppRoutes.chooseWarehouse ? null : AppRoutes.chooseWarehouse;
  if (onEntry) return AppRoutes.dashboard;
  if (location == AppRoutes.chooseWarehouse && session.warehouses.length < 2) return AppRoutes.dashboard;
  if (session.role == UserRole.worker && _supervisorOnly.contains(location)) return AppRoutes.dashboard;
  return null;
}
