import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_router.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/features/auth/presentation/login_screen.dart';
import 'package:warehouse_app/features/dashboard/presentation/worker_dashboard_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

/// The whole way in through the app's own router: the check-in plays on Sign in before Home takes over.
void main() {
  const worker = UserSession(userId: 'u2', name: 'John Doe', email: 'worker@warehouse.com', site: 'Warehouse A', role: UserRole.worker, token: 't');

  testWidgets('Sign in stays up for the check-in, then Home takes over', (tester) async {
    final repo = MockAuthRepository();
    when(() => repo.getStoredSession()).thenAnswer((_) async => null);
    when(() => repo.login(any(), any())).thenAnswer((_) async => worker);
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(null)),
    ]);
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start my shift')); // pushed over Welcome, the way people arrive
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'worker@warehouse.com');
    await tester.enterText(find.byType(TextFormField).last, 'pw');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(LoginScreen.checkInKey), findsOneWidget);
    expect(find.byType(WorkerDashboardScreen), findsNothing);

    for (var i = 0; i < 300 && find.byType(WorkerDashboardScreen).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 16)); // the check-in, then the greeting
    }
    // Home's greeting is already where Sign in's greeting glided to; the rest of Home arrives in steps.
    final homeGreeting = find.descendant(of: find.byType(WorkerDashboardScreen), matching: find.textContaining(', John'));
    expect(tester.getTopLeft(homeGreeting), const Offset(16, 72));
    expect(cardsOpacity(tester), lessThan(1));

    await tester.pumpAndSettle();
    expect(find.byType(WorkerDashboardScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(cardsOpacity(tester), 1);
  });

  testWidgets('coming back to Home any other way does not replay the arrival', (tester) async {
    final repo = MockAuthRepository();
    when(() => repo.getStoredSession()).thenAnswer((_) async => worker);
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(worker)),
    ]);
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();

    router.go(AppRoutes.syncIssues);
    await tester.pumpAndSettle();
    router.go(AppRoutes.dashboard);
    for (var i = 0; i < 100 && find.byType(WorkerDashboardScreen).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(cardsOpacity(tester), 1);
    await tester.pumpAndSettle();
  });
}

double cardsOpacity(WidgetTester tester) => tester
    .widget<Opacity>(find.ancestor(of: find.text('Quick Actions'), matching: find.byType(Opacity)).first)
    .opacity;
