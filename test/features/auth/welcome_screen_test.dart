import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/features/auth/presentation/login_screen.dart';
import 'package:warehouse_app/features/auth/presentation/welcome_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: AppRoutes.welcome,
      routes: [
        GoRoute(
          path: AppRoutes.welcome,
          // A fixed morning, so the badge reads the same on every run.
          builder: (_, __) => WelcomeScreen(clock: () => DateTime(2026, 10, 22, 7, 58)),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const Material(child: LoginScreen()),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  testWidgets('shows the badge with the time, date, shift and photo slot, and one way in', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text("Morning shift?\nWe've got you."), findsOneWidget);
    expect(find.text('7:58'), findsOneWidget);
    expect(find.text('AM'), findsOneWidget);
    expect(find.text('Thursday, 22 October'), findsOneWidget);
    expect(find.text('Morning shift'), findsOneWidget);
    expect(find.text('A0001'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Start my shift'), findsOneWidget);
  });

  testWidgets('Start my shift opens the sign-in screen', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start my shift'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('back from sign-in returns to the welcome screen', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start my shift'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text("Morning shift?\nWe've got you."), findsOneWidget);
  });

  test('the shift follows the time of day', () {
    expect(shiftFor(DateTime(2026, 10, 22, 5, 59)).$1, 'Night shift');
    expect(shiftFor(DateTime(2026, 10, 22, 6)).$1, 'Morning shift');
    expect(shiftFor(DateTime(2026, 10, 22, 13, 59)).$1, 'Morning shift');
    expect(shiftFor(DateTime(2026, 10, 22, 14)).$1, 'Afternoon shift');
    expect(shiftFor(DateTime(2026, 10, 22, 21, 59)).$1, 'Afternoon shift');
    expect(shiftFor(DateTime(2026, 10, 22, 22)).$1, 'Night shift');
  });
}
