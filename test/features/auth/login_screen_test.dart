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
}
