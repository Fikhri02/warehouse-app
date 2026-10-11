import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart';

import '../../support/api_fakes.dart';

const sa1 = '22222222-2222-4222-8222-222222222222';
const kp1 = '33333333-3333-4333-8333-333333333333';

void main() {
  late AppDatabase db;
  late MemoryKeyValueStore keys;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    keys = MemoryKeyValueStore();
  });
  tearDown(() => db.close());

  ApiAuthRepository repoAnswering(Future<http.Response> Function(http.Request) answer, {TokenStore? tokens}) =>
      ApiAuthRepository(client: ApiClient(baseUrl: testBaseUrl, tokens: tokens ?? TokenStore(keys), httpClient: MockClient(answer)), db: db);

  Map<String, dynamic> loginAnswer(List<Map<String, dynamic>> warehouses) =>
      tokensJson('access-1', 'refresh-1', user: userJson(warehouses: warehouses));

  test('signing in with one warehouse chooses it', () async {
    final repo = repoAnswering((_) async => jsonResponse(loginAnswer([membershipJson(sa1, 'SA1', 'Shah Alam DC', 'Worker')])));

    final session = await repo.login('arjun@waretrack.local', 'Waretrack#2026');

    expect(session.warehouseId, sa1);
    expect(session.site, 'Shah Alam DC');
    expect(session.role, UserRole.worker);
    expect(session.needsWarehouse, isFalse);
    expect(keys.values['api.refreshToken'], 'refresh-1');
  });

  test('several_warehouses_wait_for_a_choice_unless_one_was_chosen_before', () async {
    final both = [membershipJson(sa1, 'SA1', 'Shah Alam DC', 'Supervisor'), membershipJson(kp1, 'KP1', 'Klang Port Store', 'Worker')];
    final repo = repoAnswering((_) async => jsonResponse(loginAnswer(both)));

    final first = await repo.login('hafiz@waretrack.local', 'Waretrack#2026');
    expect(first.needsWarehouse, isTrue);

    final chosen = await repo.selectWarehouse(first, kp1);
    expect(chosen.warehouseId, kp1);
    expect(chosen.role, UserRole.worker); // the role in that warehouse

    final again = await repo.login('hafiz@waretrack.local', 'Waretrack#2026');
    expect(again.warehouseId, kp1);
  });

  test('an account with no warehouse is told to ask an administrator', () async {
    final repo = repoAnswering((_) async => jsonResponse(loginAnswer([])));

    await expectLater(
      repo.login('aina@waretrack.local', 'Waretrack#2026'),
      throwsA(isA<AuthFailure>().having((e) => e.message, 'message', contains('Ask an administrator'))),
    );
    expect(keys.values['api.refreshToken'], isNull);
  });

  test('a wrong password says so', () async {
    final repo = repoAnswering((_) async => jsonResponse({'status': 401, 'code': 'invalid-credentials', 'title': 'Invalid credentials'}, 401));

    await expectLater(
      repo.login('arjun@waretrack.local', 'nope'),
      throwsA(isA<AuthFailure>().having((e) => e.message, 'message', 'Wrong email or password.')),
    );
  });

  test('a_stored_session_works_offline', () async {
    final tokens = await signedInTokens(store: keys);
    await tokens.saveUser(userJson(warehouses: [membershipJson(sa1, 'SA1', 'Shah Alam DC', 'Worker')]));
    final repo = repoAnswering((_) async => throw http.ClientException('offline'), tokens: TokenStore(keys));

    final session = await repo.getStoredSession();

    expect(session?.warehouseId, sa1);
  });

  test('a_stored_session_whose_refresh_is_refused_is_gone', () async {
    final tokens = await signedInTokens(store: keys);
    await tokens.saveUser(userJson(warehouses: [membershipJson(sa1, 'SA1', 'Shah Alam DC', 'Worker')]));
    await db.syncQueueDao.enqueue(operationType: 'count.submit', referenceId: 'c1', payload: '{}');
    final repo = repoAnswering((_) async => jsonResponse({'status': 401, 'code': 'invalid-refresh-token'}, 401), tokens: TokenStore(keys));

    expect(await repo.getStoredSession(), isNull);
    expect(keys.values['api.refreshToken'], isNull);
    expect(await db.syncQueueDao.countPending(), 0); // nothing of theirs is left for the next person to send
  });

  test('signing out revokes the refresh token and wipes the server data', () async {
    final paths = <String>[];
    await signedInTokens(store: keys);
    await db.syncQueueDao.enqueue(operationType: 'count.submit', referenceId: 'c1', payload: '{}');
    final repo = repoAnswering((r) async {
      paths.add(r.url.path);
      return http.Response('', 204);
    }, tokens: TokenStore(keys));

    await repo.clearSession();

    expect(paths, ['/api/auth/logout']);
    expect(keys.values['api.refreshToken'], isNull);
    expect(await db.syncQueueDao.countPending(), 0);
  });

  test('a_different_person_signing_in_starts_with_an_empty_phone', () async {
    final tokens = await signedInTokens(store: keys);
    await tokens.saveUser(userJson(id: 'someone-else', warehouses: [membershipJson(sa1, 'SA1', 'Shah Alam DC', 'Worker')]));
    await db.syncQueueDao.enqueue(operationType: 'count.submit', referenceId: 'theirs', payload: '{}');
    final repo = repoAnswering((_) async => jsonResponse(loginAnswer([membershipJson(sa1, 'SA1', 'Shah Alam DC', 'Worker')])), tokens: TokenStore(keys));

    await repo.login('arjun@waretrack.local', 'Waretrack#2026');

    expect(await db.syncQueueDao.countPending(), 0);
  });

  test('the same person signing in again keeps their unsent work', () async {
    final tokens = await signedInTokens(store: keys);
    await tokens.saveUser(userJson(warehouses: [membershipJson(sa1, 'SA1', 'Shah Alam DC', 'Worker')]));
    await db.syncQueueDao.enqueue(operationType: 'count.submit', referenceId: 'mine', payload: '{}');
    final repo = repoAnswering((_) async => jsonResponse(loginAnswer([membershipJson(sa1, 'SA1', 'Shah Alam DC', 'Worker')])), tokens: TokenStore(keys));

    await repo.login('arjun@waretrack.local', 'Waretrack#2026');

    expect(await db.syncQueueDao.countPending(), 1);
  });
}
