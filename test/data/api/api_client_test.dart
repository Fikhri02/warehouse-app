import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';

import '../../support/api_fakes.dart';
import 'dart:io';

void main() {
  test('sends the bearer token and the idempotency key, and reads the JSON answer', () async {
    late http.Request seen;
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((r) async {
        seen = r;
        return jsonResponse({'id': 's1'});
      }),
    );

    final result = await client.post('/warehouses/w1/count-sessions/s1/submit', body: {'label': 'A'}, idempotencyKey: 'key-1');

    expect(result, {'id': 's1'});
    expect(seen.url.toString(), '$testBaseUrl/warehouses/w1/count-sessions/s1/submit');
    expect(seen.headers['Authorization'], 'Bearer access-1');
    expect(seen.headers['Idempotency-Key'], 'key-1');
    expect(jsonDecode(seen.body), {'label': 'A'});
  });

  test('a_401_refreshes_once_and_retries_with_the_same_key', () async {
    final calls = <String>[];
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((r) async {
        calls.add('${r.url.path} ${r.headers['Authorization'] ?? ''} ${r.headers['Idempotency-Key'] ?? ''}'.trim());
        if (r.url.path.endsWith('/auth/refresh')) return jsonResponse(tokensJson('access-2', 'refresh-2'));
        return r.headers['Authorization'] == 'Bearer access-1' ? http.Response('', 401) : jsonResponse({'ok': true});
      }),
    );

    await client.post('/x', idempotencyKey: 'key-1');

    expect(calls, ['/api/x Bearer access-1 key-1', '/api/auth/refresh', '/api/x Bearer access-2 key-1']);
  });

  test('concurrent 401s share one refresh, so a rotated refresh token is never sent twice', () async {
    var refreshes = 0;
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((r) async {
        if (r.url.path.endsWith('/auth/refresh')) {
          refreshes++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return jsonResponse(tokensJson('access-2', 'refresh-2'));
        }
        return r.headers['Authorization'] == 'Bearer access-1' ? http.Response('', 401) : jsonResponse({'ok': true});
      }),
    );

    await Future.wait([client.get('/a'), client.get('/b'), client.get('/c')]);

    expect(refreshes, 1);
  });

  test('a_refused_refresh_clears_the_tokens_and_reports_the_session_ended', () async {
    var expired = 0;
    final tokens = await signedInTokens();
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: tokens,
      httpClient: MockClient((r) async => r.url.path.endsWith('/auth/refresh')
          ? jsonResponse({'status': 401, 'code': 'invalid-refresh-token'}, 401)
          : http.Response('', 401)),
    )..onSessionExpired = () => expired++;

    await expectLater(client.get('/a'), throwsA(isA<SessionExpiredException>()));
    expect(expired, 1);
    expect(await tokens.refreshToken, isNull);
  });

  test('problem details become an ApiException with the code and the field errors', () async {
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((_) async => jsonResponse({
            'status': 422,
            'code': 'validation-failed',
            'title': 'Some fields are invalid',
            'errors': {'lines': ['Each item may appear once per location.']},
          }, 422)),
    );

    final error = await client.post('/x').then<Object?>((_) => null, onError: (Object e) => e);

    expect(error, isA<ApiException>());
    final problem = error! as ApiException;
    expect(problem.status, 422);
    expect(problem.code, 'validation-failed');
    expect(problem.errors['lines'], ['Each item may appear once per location.']);
    expect(problem.message, 'Each item may appear once per location.');
    expect(ApiException.fromJson(problem.toJson()).message, problem.message);
  });

  test('a lost connection is ApiOfflineException', () async {
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((_) async => throw http.ClientException('Connection refused')),
    );

    await expectLater(client.get('/a'), throwsA(isA<ApiOfflineException>()));
  });

  test('after a restart the stored refresh token gets an access token before the first call', () async {
    final keys = MemoryKeyValueStore();
    await signedInTokens(store: keys, access: 'old');
    final paths = <String>[];
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: TokenStore(keys), // a new store: nothing in memory, as after a restart
      httpClient: MockClient((r) async {
        paths.add(r.url.path);
        return r.url.path.endsWith('/auth/refresh') ? jsonResponse(tokensJson('access-2', 'refresh-2')) : jsonResponse({'ok': true});
      }),
    );

    await client.get('/me');

    expect(paths, ['/api/auth/refresh', '/api/me']);
  });

  test('an_answer_that_is_not_json_pauses_instead_of_crashing', () async {
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((_) async => http.Response('<html>Sign in to the Wi-Fi</html>', 200)),
    );

    await expectLater(client.get('/a'), throwsA(isA<ApiException>().having((e) => e.status, 'status', 502)));
  });

  test('a failed secure connection counts as offline', () async {
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((_) async => throw const HandshakeException('bad certificate')),
    );

    await expectLater(client.get('/a'), throwsA(isA<ApiOfflineException>()));
  });

  test('a_file_retried_after_a_401_keeps_its_key_and_bytes', () async {
    final sent = <String>[];
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((r) async {
        if (r.url.path.endsWith('/auth/refresh')) return jsonResponse(tokensJson('access-2', 'refresh-2'));
        expect(r.headers['content-type'], startsWith('multipart/form-data'));
        sent.add('${r.method} ${r.headers['Idempotency-Key']} ${r.bodyBytes.length > 100 && utf8.decode(r.bodyBytes, allowMalformed: true).contains('PNG')}');
        return r.headers['Authorization'] == 'Bearer access-1' ? http.Response('', 401) : jsonResponse({'receiptId': 'r1', 'bytes': 120});
      }),
    );
    final png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, ...List.filled(112, 7)];

    await client.putFile('/warehouses/w1/receipts/r1/signature', field: 'signature', filename: 'signature.png', bytes: png, idempotencyKey: 'key-9');

    expect(sent, ['PUT key-9 true', 'PUT key-9 true']);
  });
}
