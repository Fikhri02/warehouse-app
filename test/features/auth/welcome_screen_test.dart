import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/motion/sign_in_motion.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/core/widgets/atura_logo.dart';
import 'package:warehouse_app/features/auth/presentation/login_screen.dart';
import 'package:warehouse_app/features/auth/presentation/sign_in_geometry.dart';
import 'package:warehouse_app/features/auth/presentation/welcome_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
  });

  Widget buildSubject({bool reducedMotion = false}) {
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
          pageBuilder: (context, state) => signInPage(context, state, const Material(child: LoginScreen())),
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
          child: child!,
        ),
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

  /// Pumps frame by frame until [finder] shows up, so the first frame of a route can be looked at.
  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 200 && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  testWidgets('Sign in builds itself in: wordmark in place at once, the sheet arrives from below', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start my shift'));
    await pumpUntilFound(tester, find.byType(LoginScreen));
    final title = find.text('Sign in').first;
    final headline = find.text('Ready for\nthe next shift.');
    final firstFrameTitleY = tester.getTopLeft(title).dy;
    expect(tester.getTopLeft(find.descendant(of: find.byType(LoginScreen), matching: find.byType(AturaWordmark))).dx, 24);
    expect(tester.widget<Opacity>(find.ancestor(of: headline, matching: find.byType(Opacity)).first).opacity, 0);

    await tester.pumpAndSettle();
    expect(firstFrameTitleY, greaterThan(tester.getTopLeft(title).dy + 100));
    expect(tester.widget<Opacity>(find.ancestor(of: headline, matching: find.byType(Opacity)).first).opacity, 1);
  });

  group('badge handoff', () {
    final headline = find.text("Morning shift?\nWe've got you.");
    double opacityAbove(WidgetTester tester, Finder finder) =>
        tester.widget<Opacity>(find.ancestor(of: finder, matching: find.byType(Opacity)).first).opacity;

    testWidgets('Start my shift plays the handoff before Sign in opens', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start my shift'));
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 50)); // frame by frame, so a push would have landed
      }
      expect(find.byType(LoginScreen), findsNothing);

      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Start my shift tapped twice opens Sign in once', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start my shift'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Start my shift'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);
      expect(headline, findsOneWidget);
    });

    testWidgets('back from Sign in brings the welcome back whole', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start my shift'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(opacityAbove(tester, headline), 1);
      expect(opacityAbove(tester, find.text('Start my shift')), 1);
      await tester.tap(find.text('Start my shift')); // and the way in works again
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('the status bar turns light once the band floods teal', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      SystemUiOverlayStyle style() => tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(find
              .descendant(of: find.byType(WelcomeScreen), matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>))
              .first)
          .value;
      expect(style(), SystemUiOverlayStyle.dark);

      await tester.tap(find.text('Start my shift'));
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 50)); // past 0.7 of the 800ms handoff
      }
      expect(style(), SystemUiOverlayStyle.light);
    });

    testWidgets('with reduced motion Sign in fades in without sliding', (tester) async {
      await tester.pumpWidget(buildSubject(reducedMotion: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start my shift'));
      await pumpUntilFound(tester, find.byType(LoginScreen));
      final title = find.text('Sign in').first;
      final firstFrameY = tester.getTopLeft(title).dy;
      await tester.pumpAndSettle();
      expect(firstFrameY, closeTo(tester.getTopLeft(title).dy, 1));
    });

    testWidgets('back from Sign in reveals the welcome still flooded, then it unwinds', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start my shift'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      for (var i = 0; i < 100 && find.byType(LoginScreen).evaluate().isNotEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      // The first frame without Sign in: Welcome's flying wordmark still sits where Sign in's was.
      final wordmarks = find.descendant(of: find.byType(WelcomeScreen), matching: find.byType(AturaWordmark));
      expect(tester.getTopLeft(wordmarks.last).dx, closeTo(24, 2));

      await tester.pumpAndSettle();
      expect(opacityAbove(tester, headline), 1);
    });

    testWidgets('with reduced motion Start my shift opens Sign in straight away', (tester) async {
      await tester.pumpWidget(buildSubject(reducedMotion: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start my shift'));
      await tester.pump();
      await tester.pump(kReducedMotionFade);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
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
