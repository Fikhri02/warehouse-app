import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  ProviderContainer makeContainer() => ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

  const workerSession = UserSession(
    userId: 'u002',
    name: 'John',
    email: 'j@test.com',
    site: 'WH-A',
    role: UserRole.worker,
    token: 'tok',
  );

  group('AuthNotifier.build', () {
    test('returns stored session on startup', () async {
      when(() => mockRepo.getStoredSession())
          .thenAnswer((_) async => workerSession);
      final container = makeContainer();
      addTearDown(container.dispose);
      final state = await container.read(authNotifierProvider.future);
      expect(state, equals(workerSession));
    });

    test('returns null when no stored session', () async {
      when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
      final container = makeContainer();
      addTearDown(container.dispose);
      final state = await container.read(authNotifierProvider.future);
      expect(state, isNull);
    });
  });

  group('AuthNotifier.login', () {
    test('sets session after successful login', () async {
      when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => workerSession);
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(authNotifierProvider.notifier).login('j@test.com', 'pass');
      final state = await container.read(authNotifierProvider.future);
      expect(state, equals(workerSession));
    });

    test('sets AsyncError on failed login', () async {
      when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
      when(() => mockRepo.login(any(), any()))
          .thenThrow(Exception('Invalid credentials'));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).login('bad@test.com', 'wrong');
      final state = container.read(authNotifierProvider);
      expect(state, isA<AsyncError>());
    });
  });

  group('AuthNotifier.logout', () {
    test('clears session after logout', () async {
      when(() => mockRepo.getStoredSession())
          .thenAnswer((_) async => workerSession);
      when(() => mockRepo.clearSession()).thenAnswer((_) async {});
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(authNotifierProvider.notifier).logout();
      final state = await container.read(authNotifierProvider.future);
      expect(state, isNull);
    });
  });
}
