import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/features/auth/presentation/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

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
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('renders biometric button with label', (tester) async {
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    expect(find.text('Biometric'), findsOneWidget);
  });

  testWidgets('shows error when email is empty on submit', (tester) async {
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email'), findsOneWidget);
  });

  testWidgets('shows error message on failed login', (tester) async {
    when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
    when(() => mockRepo.login(any(), any()))
        .thenThrow(Exception('Invalid credentials'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextFormField).first, 'bad@test.com');
    await tester.enterText(
        find.byType(TextFormField).last, 'wrongpassword');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Invalid credentials'), findsOneWidget);
  });
}
