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
          builder: (_, __) => const WelcomeScreen(),
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

  testWidgets('renders welcome content with get started button',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Move inventory with fewer taps.'), findsOneWidget);
  });

  testWidgets('navigates to login screen when get started is pressed',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('back from login returns to welcome screen', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Move inventory with fewer taps.'), findsOneWidget);
  });
}
