import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/sample/sample_auth_repository.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage storage;
  late SampleAuthRepository repo;

  setUp(() {
    storage = MockSecureStorage();
    repo = SampleAuthRepository(storage);
  });

  group('SampleAuthRepository.login', () {
    test('supervisor email returns supervisor role', () async {
      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      final session = await repo.login('supervisor@warehouse.com', 'any');
      expect(session.role, equals(UserRole.supervisor));
      expect(session.name, equals('Sarah Chen'));
    });

    test('any other email returns worker role', () async {
      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      final session = await repo.login('john@warehouse.com', 'any');
      expect(session.role, equals(UserRole.worker));
    });

    test('login stores session in secure storage', () async {
      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await repo.login('john@warehouse.com', 'pass');

      verify(() => storage.write(key: 'token', value: any(named: 'value'))).called(1);
      verify(() => storage.write(key: 'role', value: 'worker')).called(1);
    });
  });

  group('SampleAuthRepository.getStoredSession', () {
    test('returns null when no token stored', () async {
      when(() => storage.read(key: 'token')).thenAnswer((_) async => null);

      final session = await repo.getStoredSession();
      expect(session, isNull);
    });

    test('returns UserSession when all keys present', () async {
      when(() => storage.read(key: 'token')).thenAnswer((_) async => 'tok');
      when(() => storage.read(key: 'role')).thenAnswer((_) async => 'worker');
      when(() => storage.read(key: 'userId')).thenAnswer((_) async => 'u002');
      when(() => storage.read(key: 'name')).thenAnswer((_) async => 'John');
      when(() => storage.read(key: 'email')).thenAnswer((_) async => 'j@test.com');
      when(() => storage.read(key: 'site')).thenAnswer((_) async => 'WH-A');

      final session = await repo.getStoredSession();
      expect(session, isNotNull);
      expect(session!.role, equals(UserRole.worker));
      expect(session.token, equals('tok'));
    });
  });

  group('SampleAuthRepository.clearSession', () {
    test('calls deleteAll on secure storage', () async {
      when(() => storage.deleteAll()).thenAnswer((_) async {});

      await repo.clearSession();
      verify(() => storage.deleteAll()).called(1);
    });
  });
}
