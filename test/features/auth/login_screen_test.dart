import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/biometrics.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/features/auth/presentation/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeBiometrics implements BiometricAuth {
  @override
  Future<bool> canCheck() async => true;

  @override
  Future<bool> authenticate(String reason) async => true;
}

class DeclinedBiometrics implements BiometricAuth {
  @override
  Future<bool> canCheck() async => true;

  @override
  Future<bool> authenticate(String reason) async => false;
}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  Widget buildSubject() => ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const LoginScreen(),
        ),
      );

  testWidgets('renders email and password fields', (tester) async {
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('no fingerprint button until biometric login is on', (tester) async {
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    expect(find.text('Use fingerprint'), findsNothing);
  });

  testWidgets('a declined fingerprint leaves the button to try again', (tester) async {
    const locked = UserSession(userId: 'u1', name: 'Arjun Nair', email: 'arjun@waretrack.local', site: 'Shah Alam DC', role: UserRole.worker, token: 't');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(null)),
        lockedSessionProvider.overrideWith((_) => locked),
        biometricAuthProvider.overrideWithValue(DeclinedBiometrics()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Use fingerprint'), findsOneWidget);
  });

  testWidgets('nothing is focused on first load, so the form starts lowered', (tester) async {
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    for (final field in tester.widgetList<EditableText>(find.byType(EditableText))) {
      expect(field.focusNode.hasFocus, isFalse);
    }
  });

  testWidgets('focusing a field raises the form, a tap outside lowers it', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556); // iPhone-sized, so the form has room to rise
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    double formTop() => tester.getTopLeft(find.byType(Form)).dy;
    final atRest = formTop();

    await tester.tap(find.byType(TextFormField).first);
    await tester.pumpAndSettle();
    expect(formTop(), lessThan(atRest - 100));

    await tester.tapAt(const Offset(20, 120)); // an empty spot on the raised form
    await tester.pumpAndSettle();
    expect(formTop(), closeTo(atRest, 1));
  });

  testWidgets('the password can be shown and hidden', (tester) async {
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    EditableText password() => tester.widget<EditableText>(find.descendant(of: find.byType(TextFormField).last, matching: find.byType(EditableText)));
    expect(password().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(password().obscureText, isFalse);
  });

  testWidgets('shows error when email is empty on submit', (tester) async {
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email'), findsOneWidget);
  });

  testWidgets('shows error message on failed login', (tester) async {
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    when(() => mockRepo.login(any(), any()))
        .thenThrow(Exception('Invalid credentials'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'bad@test.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Invalid credentials'), findsOneWidget);
  });

  testWidgets('a locked session opens with a fingerprint', (tester) async {
    const locked = UserSession(userId: 'u1', name: 'Arjun Nair', email: 'arjun@waretrack.local', site: 'Shah Alam DC', role: UserRole.worker, token: 't');
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
      authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(null)),
      lockedSessionProvider.overrideWith((_) => locked),
      biometricAuthProvider.overrideWithValue(FakeBiometrics()),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
    ));
    await tester.pumpAndSettle(); // the prompt opens on its own

    expect(container.read(authNotifierProvider).valueOrNull?.userId, 'u1');
    expect(container.read(lockedSessionProvider), isNull);
  });

  group('check-in', () {
    const worker = UserSession(userId: 'u2', name: 'John Doe', email: 'worker@warehouse.com', site: 'Warehouse A', role: UserRole.worker, token: 't');

    ProviderContainer containerWith({List<Override> extra = const []}) {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(null)),
        ...extra,
      ]);
      addTearDown(container.dispose);
      return container;
    }

    Widget subject(ProviderContainer container, {bool reducedMotion = false}) => UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
              child: child!,
            ),
            home: const LoginScreen(),
          ),
        );

    Future<void> fillIn(WidgetTester tester) async {
      await tester.enterText(find.byType(TextFormField).first, 'worker@warehouse.com');
      await tester.enterText(find.byType(TextFormField).last, 'pw');
    }

    testWidgets('a successful sign-in holds on Sign in, shows the check, then lets go', (tester) async {
      when(() => mockRepo.login(any(), any())).thenAnswer((_) async => worker);
      final container = containerWith();
      await tester.pumpWidget(subject(container));
      await tester.pumpAndSettle();
      await fillIn(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pump(); // the sign-in resolves
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byKey(LoginScreen.checkInKey), findsOneWidget);
      expect(container.read(entryHeldProvider), isTrue);

      await tester.pumpAndSettle();
      expect(container.read(entryHeldProvider), isFalse);
      expect(container.read(authNotifierProvider).valueOrNull?.userId, 'u2');
    });

    testWidgets('a failed sign-in lets go at once and keeps the button', (tester) async {
      when(() => mockRepo.login(any(), any())).thenThrow(Exception('Invalid credentials'));
      final container = containerWith();
      await tester.pumpWidget(subject(container));
      await tester.pumpAndSettle();
      await fillIn(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pump();
      expect(container.read(entryHeldProvider), isFalse);

      await tester.pumpAndSettle();
      expect(find.textContaining('Invalid credentials'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
      expect(find.byKey(LoginScreen.checkInKey), findsNothing);
    });

    testWidgets('Sign in tapped twice signs in once', (tester) async {
      when(() => mockRepo.login(any(), any())).thenAnswer((_) async => worker);
      final container = containerWith();
      await tester.pumpWidget(subject(container));
      await tester.pumpAndSettle();
      await fillIn(tester);

      final button = find.widgetWithText(ElevatedButton, 'Sign in');
      await tester.tap(button);
      await tester.tap(button, warnIfMissed: false);
      await tester.pumpAndSettle();
      verify(() => mockRepo.login(any(), any())).called(1);
    });

    testWidgets('a locked session unlocked by fingerprint plays the same check-in', (tester) async {
      const locked = UserSession(userId: 'u1', name: 'Arjun Nair', email: 'arjun@waretrack.local', site: 'Shah Alam DC', role: UserRole.worker, token: 't');
      final container = containerWith(extra: [
        lockedSessionProvider.overrideWith((_) => locked),
        biometricAuthProvider.overrideWithValue(FakeBiometrics()),
      ]);
      await tester.pumpWidget(subject(container));
      await tester.pump(); // the prompt opens on its own and succeeds
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byKey(LoginScreen.checkInKey), findsOneWidget);
      expect(container.read(entryHeldProvider), isTrue);

      await tester.pumpAndSettle();
      expect(container.read(entryHeldProvider), isFalse);
      expect(container.read(authNotifierProvider).valueOrNull?.userId, 'u1');
    });

    testWidgets('signing in from a focused field drops the keyboard and keeps the sheet raised', (tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      when(() => mockRepo.login(any(), any())).thenAnswer((_) async => worker);
      final container = containerWith();
      await tester.pumpWidget(subject(container));
      await tester.pumpAndSettle();
      double formTop() => tester.getTopLeft(find.byType(Form)).dy;
      final atRest = formTop();

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();
      await fillIn(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      for (final field in tester.widgetList<EditableText>(find.byType(EditableText))) {
        expect(field.focusNode.hasFocus, isFalse);
      }
      expect(formTop(), lessThan(atRest - 100));
      await tester.pumpAndSettle();
    });

    testWidgets('if the session is gone by the end of the check-in, Sign in comes back usable', (tester) async {
      when(() => mockRepo.login(any(), any())).thenAnswer((_) async => worker);
      when(() => mockRepo.clearSession()).thenAnswer((_) async {});
      final container = containerWith();
      await tester.pumpWidget(subject(container));
      await tester.pumpAndSettle();
      await fillIn(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await container.read(authNotifierProvider.notifier).logout(); // e.g. the session expired mid check-in
      await tester.pumpAndSettle();

      expect(find.byKey(LoginScreen.checkInKey), findsNothing);
      expect(container.read(entryHeldProvider), isFalse);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pumpAndSettle();
      verify(() => mockRepo.login(any(), any())).called(2);
    });

    testWidgets('the fingerprint button stays put while its check-in plays', (tester) async {
      const locked = UserSession(userId: 'u1', name: 'Arjun Nair', email: 'arjun@waretrack.local', site: 'Shah Alam DC', role: UserRole.worker, token: 't');
      final container = containerWith(extra: [
        lockedSessionProvider.overrideWith((_) => locked),
        biometricAuthProvider.overrideWithValue(FakeBiometrics()),
      ]);
      await tester.pumpWidget(subject(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byKey(LoginScreen.checkInKey), findsOneWidget);
      expect(find.text('Use fingerprint'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('with reduced motion nothing is held', (tester) async {
      when(() => mockRepo.login(any(), any())).thenAnswer((_) async => worker);
      final container = containerWith();
      final seen = <bool>[];
      container.listen(entryHeldProvider, (_, next) => seen.add(next));
      await tester.pumpWidget(subject(container, reducedMotion: true));
      await tester.pumpAndSettle();
      await fillIn(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(seen, isNot(contains(true)));
      expect(find.byKey(LoginScreen.checkInKey), findsNothing);
      expect(container.read(authNotifierProvider).valueOrNull?.userId, 'u2');
    });
  });
}
