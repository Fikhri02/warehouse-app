# WareTrack App 3a — Server Foundation and Stock Counts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect the Flutter warehouse app to the WareTrack server and prove it end to end on stock counts:
- sign in and choose a warehouse;
- copy the server's catalogue, locations and counts to the phone;
- count against server items, even offline;
- send the count once it is back online;
- let a supervisor approve or reject counts from the phone.

**Architecture:**
- **Mode at build time.** `--dart-define=WARETRACK_API=https://host/api` selects the server; without it the app runs on the Sample repositories exactly as today.
- **API client.** An `ApiClient` (package `http`) adds the bearer token. It refreshes once on 401, sharing one refresh across concurrent calls, and turns problem details into `ApiException`.
- **Reads from a local copy.** The phone's reads come from Drift tables that mirror the server, filled from the change feed (`/warehouses/{w}/sync/changes`).
- **Writes through the outbox.** Every write is queued in the existing `SyncQueue` with a stored `Idempotency-Key`. Queued commands are sent in order, then the app pulls what changed.
- **Server answers (spec §3 table):**
  - 2xx → done;
  - 409 → kept as "not accepted" with the reason, and the queue moves on;
  - other 4xx → failed;
  - 5xx or offline → stop and retry later, keeping the order.
- **One screen talks to the server directly:** the supervisor's count review, which needs live stock figures.

**Tech Stack:** Flutter 3.38.6 / Dart 3.10.7, flutter_riverpod 2.6, go_router 14, drift 2.21 (+ build_runner), flutter_secure_storage, local_auth, mocktail. New: `http`, `uuid`.

**Server:** `~/projects/Personal/DotNet/waretrack-server` @ `api-foundation` `a8e3220`. Endpoints used:
- `POST /auth/login|refresh|logout`;
- `GET /warehouses/{w}/sync/changes`;
- `GET /catalog/barcodes/{code}`;
- `POST /warehouses/{w}/count-sessions/{id}/submit|approve|reject`;
- `GET /warehouses/{w}/count-reviews/{id}`.

**Spec:** `/Users/irfanfikhribiniszahar/projects/Personal/AI/memory-core-fresh/brainstorming/active/warehouse-app-backend.md`, "Spec — WareTrack backend" §3 (auth, change feed, commands, response table) and §6 (Flutter app changes). Plan 3 decisions are recorded under that file's Plan 3 task (2026-10-11):
- **Split:** 3a = foundation + counts, 3b = receiving, orders, tasks and alerts, 3c = push.
- **Adapt the app to the server:** GUID IDs; count deadline, assignee and zone dropped in server mode.
- **Keep Sample mode,** chosen at build time.

## Global Constraints

- **Repository:** `~/projects/Personal/Flutter/warehouse_app`. Work in a worktree at `.worktrees/api-integration` on branch `api-integration`, created from the commit that holds Irfan's UI work on `feature/order-management`. Never `main`. Never touch the main checkout's working tree.
- **Commits:** conventional subjects (`feat(sync): …`), no trailers.
- **Tools:**
  - Flutter: `/Users/irfanfikhribiniszahar/Developer/flutter/bin/flutter` (alias `F` in commands below).
  - After any Drift table change, run `$F pub run build_runner build --delete-conflicting-outputs` and commit the regenerated `*.g.dart`.
- **Sample mode keeps working.**
  - `$F test` stays green, except any failures already recorded in Task 1 Step 1.
  - Nothing calls the network unless `useApiProvider` is true.
- **Every server write goes through `SyncQueue`.** Each command carries an `idempotencyKey` stored once and reused on every retry. Commands are sent oldest first.
- **Reads come from the Drift copy, with two exceptions:** the supervisor's count review detail, and the online barcode fallback.
- **Count quantities stay whole numbers in 3a.** Decimal entry arrives with receiving in 3b, where KG and L units matter. The server takes the numbers as decimals.
- **Server mode drops what the server doesn't store:** count deadline, assigned worker and zone/aisle. The Sample-mode screens keep them.
- **Flutter patterns from memory:**
  - `ref.watch` in `build`, `ref.read` in callbacks;
  - `context.push` for screens with a back stack, `context.go` for switching sections;
  - `.withValues(alpha:)`;
  - `activeThumbColor`.
- **UI wording** is plain English, with no emojis.
- **Change-feed entities 3a does not store** (purchase orders, orders, tasks, alerts) are skipped, and the cursor still advances. 3b's schema migration must reset `sync_cursors` so those entities are pulled from the start.

## Review Focus

1. **A count submitted with no connection.** It is saved, shows as "Waiting to send", and goes to the server on reconnect with the same `Idempotency-Key`. The server runs it once. Pinned in Task 4 (`an_offline_flush_keeps_the_command_and_resends_it_with_the_same_key`).
2. **The server refuses a queued command** (409 `count-stale`, `session-already-reviewed`). The command is marked "not accepted" with the server's reason, and the next queued command still goes. The reason shows under Profile → Sync and in the recent counts. Pinned in Task 4 (`a_refused_command_is_kept_with_its_reason_and_the_next_one_still_goes`).
3. **The refresh token is refused** (account deactivated, session revoked). The person returns to sign-in, and the phone keeps none of their data. Pinned in Task 1 (`a_refused_refresh_clears_the_tokens_and_reports_the_session_ended`) and Task 3 (`a_stored_session_whose_refresh_is_refused_is_gone`).
4. **Accounts with several warehouses** must choose one. An account with one warehouse goes straight in. An account with none is told to ask an administrator. Pinned in Task 3 (`several_warehouses_wait_for_a_choice_unless_one_was_chosen_before`).
5. **The same item counted twice in one session** (two entries) is sent as one line with the total, because the server refuses duplicate lines. Pinned in Task 5 (`a_count_listing_an_item_twice_sends_one_line_with_the_total`).

---

## File Structure

```
pubspec.yaml                                        + http, uuid
dart_test.yaml                                      tag: live
lib/core/config/app_config.dart                     WARETRACK_API, useApiProvider
lib/core/biometrics.dart                            BiometricAuth (Task 7)
lib/core/models/user_session.dart                   + warehouseId, warehouses, WarehouseMembership
lib/core/models/count_records.dart                  CatalogItemRef, CountLocation, CountSummary, CountReview(+Line)
lib/core/models/count_session.dart                  CountItem + itemId
lib/core/providers/auth_provider.dart               selectWarehouse, unlock (Task 7), lockedSessionProvider
lib/core/router/auth_redirect.dart                  pure redirect rules
lib/core/router/app_routes.dart, app_router.dart    choose-warehouse, sync, pending-review detail; API-mode count screens
lib/data/api/  key_value_store.dart, token_store.dart, api_exception.dart, api_client.dart, api_providers.dart,
               api_auth_repository.dart, api_stock_count_repository.dart
lib/data/local/tables/server_tables.dart            Drift copy of the server's data
lib/data/local/tables/sync_queue_table.dart         + idempotencyKey, status, attempts, lastError, warehouseId
lib/data/local/tables/count_session_table.dart      CountItems + itemId
lib/data/local/daos/server_mirror_dao.dart          upserts, lookups, cursors
lib/data/local/daos/sync_queue_dao.dart             outbox states
lib/data/local/app_database.dart                    schema 6, clearServerData
lib/data/sync/ change_feed_puller.dart, command_sender.dart, sync_service.dart, sync_coordinator.dart, sync_provider.dart
lib/data/repositories/auth_repository.dart          + selectWarehouse
lib/data/repositories/stock_count_repository.dart   server-shaped interface
lib/data/sample/ sample_auth_repository.dart, sample_stock_count_repository.dart
lib/features/auth/presentation/choose_warehouse_screen.dart, login_screen.dart (Task 7)
lib/features/sync/sync_issues_screen.dart
lib/features/profile/ screens/profile_screen.dart, providers/profile_provider.dart
lib/features/stock_count/ presentation/count_setup_screen.dart, count_item_picker_screen.dart,
                          scan_count_screen.dart, review_count_screen.dart, start_count_screen.dart,
                          providers/stock_count_provider.dart, create_count_session_notifier.dart
lib/features/supervisor/ providers/pending_review_provider.dart, screens/pending_review_screen.dart, screens/count_review_screen.dart
lib/main.dart
test/support/api_fakes.dart + tests per task; test/live/api_counts_live_test.dart
```

---

### Task 1: The API client

**Files:**
- Create: `lib/core/config/app_config.dart`, `lib/data/api/key_value_store.dart`, `lib/data/api/token_store.dart`, `lib/data/api/api_exception.dart`, `lib/data/api/api_client.dart`, `test/support/api_fakes.dart`
- Modify: `pubspec.yaml` (`http`, `uuid`)
- Test: `test/data/api/api_client_test.dart`

**Interfaces:**
- Produces:
  - `AppConfig.apiBaseUrl`, `AppConfig.useApi`, and `useApiProvider` (`Provider<bool>`, overridable in tests).
  - `KeyValueStore` (read, write, delete), with `SecureKeyValueStore(FlutterSecureStorage)` and `MemoryKeyValueStore`.
  - `AuthTokens.fromJson`.
  - `TokenStore(KeyValueStore)`:
    - `accessToken`, `accessTokenFresh`, `refreshToken` (Future);
    - `save(AuthTokens)`, `readUser`/`saveUser`, `readWarehouseId`/`saveWarehouseId`;
    - `deviceId()`, `clear()`.
  - `ApiException(status, code, title, detail, errors)`, with `.message`, `fromResponse`, `fromJson`/`toJson`.
  - `ApiOfflineException` and `SessionExpiredException`.
  - `ApiClient(baseUrl, httpClient, tokens)`:
    - `get(path, {query})` and `post(path, {body, idempotencyKey, authenticated})` → `Future<dynamic>` (decoded JSON or null);
    - `refresh()`, `onSessionExpired`, `tokens`.
  - Test support: `tokensJson`, `jsonResponse`, `signedInTokens()`.

- [ ] **Step 1: Create the worktree and record the baseline**

```bash
cd ~/projects/Personal/Flutter/warehouse_app
grep -qx '.worktrees/' .git/info/exclude || echo '.worktrees/' >> .git/info/exclude
git worktree add .worktrees/api-integration -b api-integration feature/order-management
cd .worktrees/api-integration
F=/Users/irfanfikhribiniszahar/Developer/flutter/bin/flutter
$F pub get && $F test 2>&1 | tail -3
mkdir -p docs/superpowers/plans && cp ~/projects/Personal/DotNet/waretrack-server/docs/superpowers/plans/2026-10-11-waretrack-app-3a-foundation-counts.md docs/superpowers/plans/
git add docs/superpowers/plans && git commit -m "docs: add the app 3a server foundation and counts plan"
```
Expected: the worktree is on `api-integration` at the commit holding the UI work. Record the baseline test result in the ledger. On 2026-10-11 the uncommitted UI work failed 2 welcome-screen tests; any failure seen here is pre-existing and not this plan's.

- [ ] **Step 2: Add the packages**

Run: `$F pub add http uuid && grep -nE "^  (http|uuid):" pubspec.yaml`
Expected: both appear under `dependencies` with caret versions (http ^1.x, uuid ^4.x).

- [ ] **Step 3: Write the failing tests**

`test/support/api_fakes.dart`:
```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';

const testBaseUrl = 'https://wt.test/api';

Map<String, dynamic> userJson({
  String id = '11111111-1111-4111-8111-111111111111',
  String name = 'Arjun Nair',
  List<Map<String, dynamic>> warehouses = const [],
}) =>
    {'id': id, 'email': 'arjun@waretrack.local', 'displayName': name, 'isAdmin': false, 'warehouses': warehouses};

Map<String, dynamic> membershipJson(String id, String code, String name, String role) =>
    {'warehouseId': id, 'warehouseCode': code, 'warehouseName': name, 'role': role};

Map<String, dynamic> tokensJson(String access, String refresh, {Map<String, dynamic>? user}) => {
      'accessToken': access,
      'accessTokenExpiresAt': DateTime.now().add(const Duration(minutes: 15)).toUtc().toIso8601String(),
      'refreshToken': refresh,
      'refreshTokenExpiresAt': DateTime.now().add(const Duration(days: 30)).toUtc().toIso8601String(),
      'user': user ?? userJson(),
    };

http.Response jsonResponse(Object? body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

/// A token store as it is right after signing in: fresh access token in memory, refresh token stored.
Future<TokenStore> signedInTokens({KeyValueStore? store, String access = 'access-1', String refresh = 'refresh-1'}) async {
  final tokens = TokenStore(store ?? MemoryKeyValueStore());
  await tokens.save(AuthTokens.fromJson(tokensJson(access, refresh)));
  return tokens;
}
```

`test/data/api/api_client_test.dart`:
```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';

import '../../support/api_fakes.dart';

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
}
```

- [ ] **Step 4: Run them to verify they fail**

Run: `$F test test/data/api/api_client_test.dart`
Expected: FAIL — compile errors: `api_client.dart`, `token_store.dart` and the rest don't exist.

- [ ] **Step 5: Implement**

`lib/core/config/app_config.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the app gets its data. Built with `--dart-define=WARETRACK_API=https://host/api` it talks to the
/// WareTrack server; without it, it runs on the Sample repositories (demos, UI work), as before.
class AppConfig {
  AppConfig._();

  static const apiBaseUrl = String.fromEnvironment('WARETRACK_API');
  static bool get useApi => apiBaseUrl.isNotEmpty;
}

/// Read this rather than [AppConfig.useApi], so tests can switch modes.
final useApiProvider = Provider<bool>((_) => AppConfig.useApi);
```

`lib/data/api/key_value_store.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The few values the app keeps between launches: refresh token, signed-in user, chosen warehouse, device id.
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureKeyValueStore implements KeyValueStore {
  SecureKeyValueStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// For tests: forgets everything when the object goes.
class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
```

`lib/data/api/token_store.dart`:
```dart
import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'key_value_store.dart';

/// What /auth/login and /auth/refresh hand back.
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.accessTokenExpiresAt, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        accessTokenExpiresAt: DateTime.parse(json['accessTokenExpiresAt'] as String),
        refreshToken: json['refreshToken'] as String,
      );

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
}

/// The refresh token, the signed-in user and the chosen warehouse survive restarts in secure storage.
/// The access token lives only in memory: after a restart the refresh token fetches a new one.
class TokenStore {
  TokenStore(this._store);

  static const _refreshKey = 'api.refreshToken';
  static const _userKey = 'api.user';
  static const _warehouseKey = 'api.warehouseId';
  static const _deviceKey = 'api.deviceId';

  final KeyValueStore _store;
  String? _accessToken;
  DateTime? _accessExpiresAt;

  String? get accessToken => _accessToken;

  /// True while the access token has more than 30 seconds left.
  bool get accessTokenFresh =>
      _accessToken != null && _accessExpiresAt!.isAfter(DateTime.now().add(const Duration(seconds: 30)));

  Future<String?> get refreshToken => _store.read(_refreshKey);

  Future<void> save(AuthTokens tokens) async {
    _accessToken = tokens.accessToken;
    _accessExpiresAt = tokens.accessTokenExpiresAt;
    await _store.write(_refreshKey, tokens.refreshToken);
  }

  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _store.read(_userKey);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveUser(Map<String, dynamic> user) => _store.write(_userKey, jsonEncode(user));

  Future<String?> readWarehouseId() => _store.read(_warehouseKey);

  Future<void> saveWarehouseId(String warehouseId) => _store.write(_warehouseKey, warehouseId);

  /// One id per installation, sent at sign-in so the server can tell this phone's sessions apart.
  Future<String> deviceId() async {
    final existing = await _store.read(_deviceKey);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await _store.write(_deviceKey, id);
    return id;
  }

  /// Signing out keeps only the device id.
  Future<void> clear() async {
    _accessToken = null;
    _accessExpiresAt = null;
    await _store.delete(_refreshKey);
    await _store.delete(_userKey);
    await _store.delete(_warehouseKey);
  }
}
```

`lib/data/api/api_exception.dart`:
```dart
import 'dart:convert';

/// The server answered with an RFC 9457 problem. [code] is its stable error code, such as `count-stale`.
class ApiException implements Exception {
  const ApiException({required this.status, this.code, this.title, this.detail, this.errors = const {}});

  factory ApiException.fromResponse(int status, String body) {
    var json = <String, dynamic>{};
    try {
      final decoded = body.isEmpty ? null : jsonDecode(body);
      if (decoded is Map<String, dynamic>) json = decoded;
    } on FormatException {
      // Not JSON (a proxy's error page, a rate limiter): the status says enough.
    }
    return ApiException.fromJson({...json, 'status': status});
  }

  factory ApiException.fromJson(Map<String, dynamic> json) {
    final errors = <String, List<String>>{};
    final raw = json['errors'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is List) errors['$key'] = [for (final v in value) '$v'];
      });
    }
    return ApiException(
      status: (json['status'] as num?)?.toInt() ?? 0,
      code: json['code'] as String?,
      title: json['title'] as String?,
      detail: json['detail'] as String?,
      errors: errors,
    );
  }

  final int status;
  final String? code;
  final String? title;
  final String? detail;
  final Map<String, List<String>> errors;

  /// What to tell a person: the server's own sentence, else the first field error, else the title.
  String get message {
    if (detail != null) return detail!;
    for (final messages in errors.values) {
      if (messages.isNotEmpty) return messages.first;
    }
    return title ?? 'WareTrack refused this (HTTP $status).';
  }

  Map<String, dynamic> toJson() => {'status': status, 'code': code, 'title': title, 'detail': detail, 'errors': errors};

  @override
  String toString() => message;
}

/// WareTrack could not be reached (no network, DNS, timeout). The same command can be retried later.
class ApiOfflineException implements Exception {
  const ApiOfflineException([this.cause]);

  final Object? cause;

  @override
  String toString() => "Couldn't reach WareTrack. Check your connection and try again.";
}

/// The refresh token was refused: the person has to sign in again.
class SessionExpiredException implements Exception {
  const SessionExpiredException();

  @override
  String toString() => 'Your session has ended. Sign in again.';
}
```

`lib/data/api/api_client.dart`:
```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'token_store.dart';

/// JSON over HTTP to the WareTrack API. Every call carries the bearer token. An expired token, or a 401,
/// triggers one shared refresh: the server revokes the whole token family if a rotated refresh token is
/// used twice. Problem details become [ApiException]; a lost connection becomes [ApiOfflineException].
class ApiClient {
  ApiClient({
    required String baseUrl,
    required http.Client httpClient,
    required TokenStore tokens,
    this.timeout = const Duration(seconds: 20),
  })  : _base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
        _http = httpClient,
        _tokens = tokens;

  final String _base;
  final http.Client _http;
  final TokenStore _tokens;
  final Duration timeout;
  Future<void>? _refreshing;

  /// Called when the refresh token is refused, so the app can return to sign-in.
  void Function()? onSessionExpired;

  TokenStore get tokens => _tokens;

  Future<dynamic> get(String path, {Map<String, String>? query}) => _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body, String? idempotencyKey, bool authenticated = true}) =>
      _send('POST', path, body: body, idempotencyKey: idempotencyKey, authenticated: authenticated);

  /// Exchanges the stored refresh token for new tokens. Concurrent callers share one request.
  Future<void> refresh() => _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    String? idempotencyKey,
    bool authenticated = true,
  }) async {
    if (authenticated && !_tokens.accessTokenFresh) await refresh();
    var response = await _raw(method, path, query, body, idempotencyKey, authenticated);
    if (authenticated && response.statusCode == 401) {
      await refresh();
      // The same Idempotency-Key: the server runs the command once, or replays its stored answer.
      response = await _raw(method, path, query, body, idempotencyKey, authenticated);
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isEmpty ? null : jsonDecode(response.body);
    }
    throw ApiException.fromResponse(response.statusCode, response.body);
  }

  Future<void> _refresh() async {
    final refreshToken = await _tokens.refreshToken;
    if (refreshToken == null) throw const SessionExpiredException();
    final response = await _raw('POST', '/auth/refresh', null, {'refreshToken': refreshToken}, null, false);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      await _tokens.save(AuthTokens.fromJson(json));
      await _tokens.saveUser(json['user'] as Map<String, dynamic>);
      return;
    }
    if (response.statusCode == 400 || response.statusCode == 401) {
      await _tokens.clear();
      onSessionExpired?.call();
      throw const SessionExpiredException();
    }
    throw ApiException.fromResponse(response.statusCode, response.body); // 429 or 5xx: keep the tokens, try later
  }

  Future<http.Response> _raw(
    String method,
    String path,
    Map<String, String>? query,
    Object? body,
    String? idempotencyKey,
    bool authenticated,
  ) async {
    final uri = Uri.parse('$_base$path').replace(queryParameters: query);
    final request = http.Request(method, uri)..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    if (idempotencyKey != null) request.headers['Idempotency-Key'] = idempotencyKey;
    final token = _tokens.accessToken;
    if (authenticated && token != null) request.headers['Authorization'] = 'Bearer $token';
    try {
      final streamed = await _http.send(request).timeout(timeout);
      return await http.Response.fromStream(streamed).timeout(timeout);
    } on SocketException catch (e) {
      throw ApiOfflineException(e);
    } on TimeoutException catch (e) {
      throw ApiOfflineException(e);
    } on http.ClientException catch (e) {
      throw ApiOfflineException(e);
    }
  }
}
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `$F test test/data/api && $F analyze lib test`
Expected: 7 PASS. `analyze` shows no new issues in the files this task touched.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(api): add the WareTrack API client with shared token refresh"
```

---

### Task 2: The phone's copy of the server, filled from the change feed

**Files:**
- Create: `lib/data/local/tables/server_tables.dart`, `lib/data/local/daos/server_mirror_dao.dart`, `lib/data/sync/change_feed_puller.dart`
- Modify: `lib/data/local/tables/sync_queue_table.dart`, `lib/data/local/tables/count_session_table.dart`, `lib/data/local/app_database.dart` (+ regenerated `*.g.dart`)
- Test: `test/data/sync/change_feed_puller_test.dart`

**Interfaces:**
- Consumes: `ApiClient`, `ApiOfflineException` (Task 1).
- Produces:
  - Drift rows: `CatalogItemRow`, `CatalogBarcodeRow`, `WarehouseLocationRow`, `RemoteCountSessionRow`, `RemoteCountLineRow`, `SyncCursorRow`.
  - `CountItems.itemId` (nullable text).
  - `SyncQueue` columns: `idempotencyKey`, `status` (default `pending`), `attempts`, `lastError`, `warehouseId`.
  - `db.serverMirrorDao`:
    - upserts and deletes for each entity, plus `upsertCountSession(session, lines)`;
    - `cursorFor(w)`, `saveCursor(w, n)`;
    - `itemByBarcode(code)`, `itemById(id)`, `searchItems(term)`;
    - `locationsFor(w)`, `locationById(id)`;
    - `countSessions({warehouseId, createdBy?, status?, limit})`, `linesFor(sessionId)`.
  - `db.clearServerData()`.
  - `ChangeFeedPuller(client:, db:).pull(warehouseId) → Future<int>` (rows applied).

- [ ] **Step 1: Write the failing tests**

`test/data/sync/change_feed_puller_test.dart`:
```dart
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/change_feed_puller.dart';

import '../../support/api_fakes.dart';

const w = '22222222-2222-4222-8222-222222222222';
const item = 'aaaaaaaa-0000-4000-8000-000000000001';
const bin = 'bbbbbbbb-0000-4000-8000-000000000001';
const count = 'cccccccc-0000-4000-8000-000000000001';

Map<String, dynamic> change(String entity, String id, int seq, [Map<String, dynamic>? data]) =>
    {'entity': entity, 'id': id, 'seq': seq, 'deleted': data == null, 'data': data};

Map<String, dynamic> page(List<Map<String, dynamic>> changes, {required int next, bool more = false}) =>
    {'nextCursor': next, 'hasMore': more, 'changes': changes};

void main() {
  late AppDatabase db;
  late List<String> cursorsAsked;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cursorsAsked = [];
  });
  tearDown(() => db.close());

  Future<ChangeFeedPuller> pullerServing(List<Object> answers) async => ChangeFeedPuller(
        db: db,
        client: ApiClient(
          baseUrl: testBaseUrl,
          tokens: await signedInTokens(),
          httpClient: MockClient((r) async {
            cursorsAsked.add(r.url.queryParameters['cursor']!);
            final answer = answers.removeAt(0);
            if (answer is Exception) throw answer;
            return http.Response(jsonEncode(answer), 200);
          }),
        ),
      );

  test('applies items, barcodes, locations and counts page by page, and remembers the cursor', () async {
    final puller = await pullerServing([
      page([
        change('item', item, 1, {'id': item, 'sku': 'WT-0001', 'name': 'Beras Wangi 10kg', 'uom': 'BAG', 'lowStockThreshold': 10, 'isActive': true}),
        change('itemBarcode', 'bc-1', 2, {'id': 'bc-1', 'itemId': item, 'code': '9556001000011'}),
        change('location', bin, 3, {'id': bin, 'warehouseId': w, 'code': 'A-01-01', 'type': 'Bin'}),
      ], next: 3, more: true),
      page([
        change('countSession', count, 4, {
          'id': count, 'warehouseId': w, 'createdByUserId': 'u1', 'label': 'Aisle A', 'status': 'Submitted',
          'submittedAt': '2026-10-11T00:12:00Z', 'reviewedByUserId': null, 'reviewedAt': null, 'rejectReason': null,
          'lines': [{'id': 'l1', 'itemId': item, 'locationId': bin, 'counted': 8, 'systemAtSubmit': 10, 'adjustment': null}],
        }),
        change('purchaseOrder', 'po-1', 5, {'id': 'po-1'}), // stored from 3b on
      ], next: 5),
    ]);

    final applied = await puller.pull(w);

    expect(applied, 5);
    expect(cursorsAsked, ['0', '3']);
    expect(await db.serverMirrorDao.cursorFor(w), 5);
    expect((await db.serverMirrorDao.itemByBarcode('9556001000011'))?.sku, 'WT-0001');
    expect((await db.serverMirrorDao.locationsFor(w)).single.code, 'A-01-01');
    final session = (await db.serverMirrorDao.countSessions(warehouseId: w)).single;
    expect(session.status, 'Submitted');
    expect((await db.serverMirrorDao.linesFor(count)).single.counted, 8);
  });

  test('deleted rows leave the copy, and the next pull starts from the stored cursor', () async {
    await (await pullerServing([
      page([change('location', bin, 7, {'id': bin, 'warehouseId': w, 'code': 'A-01-01', 'type': 'Bin'})], next: 7),
    ])).pull(w);

    await (await pullerServing([page([change('location', bin, 9)], next: 9)])).pull(w);

    expect(cursorsAsked, ['0', '7']);
    expect(await db.serverMirrorDao.locationsFor(w), isEmpty);
  });

  test('a page that cannot be fetched keeps everything applied before it', () async {
    final puller = await pullerServing([
      page([change('item', item, 1, {'id': item, 'sku': 'WT-0001', 'name': 'Beras', 'uom': 'BAG', 'lowStockThreshold': null, 'isActive': true})], next: 1, more: true),
      const ApiOfflineException(),
    ]);

    await expectLater(puller.pull(w), throwsA(isA<ApiOfflineException>()));

    expect(await db.serverMirrorDao.cursorFor(w), 1);
    expect((await db.serverMirrorDao.itemById(item))?.name, 'Beras');
  });

  test('item search matches SKU or name and leaves out inactive items', () async {
    await (await pullerServing([
      page([
        change('item', item, 1, {'id': item, 'sku': 'WT-0001', 'name': 'Beras Wangi 10kg', 'uom': 'BAG', 'lowStockThreshold': null, 'isActive': true}),
        change('item', 'old', 2, {'id': 'old', 'sku': 'WT-0099', 'name': 'Beras Lama', 'uom': 'BAG', 'lowStockThreshold': null, 'isActive': false}),
      ], next: 2),
    ])).pull(w);

    expect((await db.serverMirrorDao.searchItems('beras')).map((i) => i.sku), ['WT-0001']);
    expect((await db.serverMirrorDao.searchItems('wt-0001')).single.name, 'Beras Wangi 10kg');
  });

  test('signing out clears the copy, the cursor and the queue', () async {
    await (await pullerServing([
      page([change('location', bin, 7, {'id': bin, 'warehouseId': w, 'code': 'A-01-01', 'type': 'Bin'})], next: 7),
    ])).pull(w);
    await db.syncQueueDao.enqueue(operationType: 'count.submit', referenceId: count, payload: '{}');

    await db.clearServerData();

    expect(await db.serverMirrorDao.locationsFor(w), isEmpty);
    expect(await db.serverMirrorDao.cursorFor(w), 0);
    expect(await db.syncQueueDao.countPending(), 0);
  });
}
```

- [ ] **Step 2: Run them to verify they fail**

Run: `$F test test/data/sync/change_feed_puller_test.dart`
Expected: FAIL — compile errors: `change_feed_puller.dart` doesn't exist, and neither do `serverMirrorDao` and `clearServerData`.

- [ ] **Step 3: Add the tables and columns**

`lib/data/local/tables/server_tables.dart`:
```dart
import 'package:drift/drift.dart';

// Read-only copies of the server's data, filled from the change feed (spec §3). Row classes end in "Row" so
// they never clash with the app's own models (CatalogItem in core/models/order.dart, Location, …).

@DataClassName('CatalogItemRow')
class CatalogItems extends Table {
  TextColumn get id => text()();
  TextColumn get sku => text()();
  TextColumn get name => text()();
  TextColumn get uom => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CatalogBarcodeRow')
class CatalogBarcodes extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get code => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WarehouseLocationRow')
class WarehouseLocations extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text()();
  TextColumn get code => text()();
  TextColumn get type => text()(); // Bin · Zone · Dock

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RemoteCountSessionRow')
class RemoteCountSessions extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text()();
  TextColumn get createdByUserId => text()();
  TextColumn get label => text().nullable()();
  TextColumn get status => text()(); // Submitted · Approved · Rejected
  DateTimeColumn get submittedAt => dateTime()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();
  TextColumn get rejectReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RemoteCountLineRow')
class RemoteCountLines extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get itemId => text()();
  TextColumn get locationId => text()();
  RealColumn get counted => real()();
  RealColumn get systemAtSubmit => real()();
  RealColumn get adjustment => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// How far this phone has read each warehouse's change feed.
@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get warehouseId => text()();
  IntColumn get cursor => integer()();

  @override
  Set<Column> get primaryKey => {warehouseId};
}
```

In `lib/data/local/tables/sync_queue_table.dart`, add these columns after `syncedAt`:
```dart
  /// Sent as Idempotency-Key, unchanged on every retry of this command.
  TextColumn get idempotencyKey => text().nullable()();

  /// pending · synced · conflicted (the server answered 409) · failed (any other refusal) · dismissed
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// The server's problem details for a conflicted or failed command, as JSON.
  TextColumn get lastError => text().nullable()();
  TextColumn get warehouseId => text().nullable()();
```

In `lib/data/local/tables/count_session_table.dart`, add this to `CountItems` after `itemName`:
```dart
  /// The server's item id. Null in Sample mode, where itemCode is all there is.
  TextColumn get itemId => text().nullable()();
```

- [ ] **Step 4: The DAO, the migration and the puller**

`lib/data/local/daos/server_mirror_dao.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/server_tables.dart';

part 'server_mirror_dao.g.dart';

@DriftAccessor(tables: [CatalogItems, CatalogBarcodes, WarehouseLocations, RemoteCountSessions, RemoteCountLines, SyncCursors])
class ServerMirrorDao extends DatabaseAccessor<AppDatabase> with _$ServerMirrorDaoMixin {
  ServerMirrorDao(super.db);

  Future<void> upsertItem(CatalogItemsCompanion item) => into(catalogItems).insertOnConflictUpdate(item);

  Future<void> deleteItem(String id) => (delete(catalogItems)..where((t) => t.id.equals(id))).go();

  Future<void> upsertBarcode(CatalogBarcodesCompanion barcode) => into(catalogBarcodes).insertOnConflictUpdate(barcode);

  Future<void> deleteBarcode(String id) => (delete(catalogBarcodes)..where((t) => t.id.equals(id))).go();

  Future<void> upsertLocation(WarehouseLocationsCompanion location) => into(warehouseLocations).insertOnConflictUpdate(location);

  Future<void> deleteLocation(String id) => (delete(warehouseLocations)..where((t) => t.id.equals(id))).go();

  /// A count arrives whole: its lines replace whatever the phone had for it.
  Future<void> upsertCountSession(RemoteCountSessionsCompanion session, List<RemoteCountLinesCompanion> lines) async {
    await into(remoteCountSessions).insertOnConflictUpdate(session);
    await (delete(remoteCountLines)..where((l) => l.sessionId.equals(session.id.value))).go();
    for (final line in lines) {
      await into(remoteCountLines).insert(line);
    }
  }

  Future<void> deleteCountSession(String id) async {
    await (delete(remoteCountLines)..where((l) => l.sessionId.equals(id))).go();
    await (delete(remoteCountSessions)..where((s) => s.id.equals(id))).go();
  }

  Future<int> cursorFor(String warehouseId) async {
    final row = await (select(syncCursors)..where((c) => c.warehouseId.equals(warehouseId))).getSingleOrNull();
    return row?.cursor ?? 0;
  }

  Future<void> saveCursor(String warehouseId, int cursor) =>
      into(syncCursors).insertOnConflictUpdate(SyncCursorsCompanion.insert(warehouseId: warehouseId, cursor: cursor));

  Future<CatalogItemRow?> itemByBarcode(String code) {
    final query = select(catalogItems).join([innerJoin(catalogBarcodes, catalogBarcodes.itemId.equalsExp(catalogItems.id))])
      ..where(catalogBarcodes.code.equals(code) & catalogItems.isActive.equals(true))
      ..limit(1);
    return query.map((row) => row.readTable(catalogItems)).getSingleOrNull();
  }

  Future<CatalogItemRow?> itemById(String id) => (select(catalogItems)..where((i) => i.id.equals(id))).getSingleOrNull();

  /// Active items whose SKU or name contains [term] (SQLite LIKE ignores case for ASCII).
  Future<List<CatalogItemRow>> searchItems(String term, {int limit = 50}) {
    final pattern = '%${term.trim()}%';
    return (select(catalogItems)
          ..where((i) => i.isActive.equals(true) & (i.sku.like(pattern) | i.name.like(pattern)))
          ..orderBy([(i) => OrderingTerm.asc(i.sku)])
          ..limit(limit))
        .get();
  }

  Future<List<WarehouseLocationRow>> locationsFor(String warehouseId) => (select(warehouseLocations)
        ..where((l) => l.warehouseId.equals(warehouseId))
        ..orderBy([(l) => OrderingTerm.asc(l.code)]))
      .get();

  Future<WarehouseLocationRow?> locationById(String id) =>
      (select(warehouseLocations)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<List<RemoteCountSessionRow>> countSessions({required String warehouseId, String? createdBy, String? status, int limit = 20}) {
    final query = select(remoteCountSessions)..where((s) => s.warehouseId.equals(warehouseId));
    if (createdBy != null) query.where((s) => s.createdByUserId.equals(createdBy));
    if (status != null) query.where((s) => s.status.equals(status));
    query
      ..orderBy([(s) => OrderingTerm.desc(s.submittedAt)])
      ..limit(limit);
    return query.get();
  }

  Future<List<RemoteCountLineRow>> linesFor(String sessionId) =>
      (select(remoteCountLines)..where((l) => l.sessionId.equals(sessionId))).get();
}
```

In `lib/data/local/app_database.dart`:
- add imports for `tables/server_tables.dart` and `daos/server_mirror_dao.dart`;
- add `CatalogItems, CatalogBarcodes, WarehouseLocations, RemoteCountSessions, RemoteCountLines, SyncCursors` to `tables:` and `ServerMirrorDao` to `daos:`;
- set `schemaVersion => 6`;
- add the step below inside `onUpgrade`, after `if (from < 5) { … }`;
- add the method below to the class.

The `onUpgrade` step:
```dart
          if (from < 6) {
            await migrator.createTable(catalogItems);
            await migrator.createTable(catalogBarcodes);
            await migrator.createTable(warehouseLocations);
            await migrator.createTable(remoteCountSessions);
            await migrator.createTable(remoteCountLines);
            await migrator.createTable(syncCursors);
            await migrator.addColumn(countItems, countItems.itemId);
            await migrator.addColumn(syncQueue, syncQueue.idempotencyKey);
            await migrator.addColumn(syncQueue, syncQueue.status);
            await migrator.addColumn(syncQueue, syncQueue.attempts);
            await migrator.addColumn(syncQueue, syncQueue.lastError);
            await migrator.addColumn(syncQueue, syncQueue.warehouseId);
            // Rows the old service already marked done must not be sent again.
            await customStatement("UPDATE sync_queue SET status = 'synced' WHERE synced = 1");
          }
```
The new method:
```dart
  /// Signing out: neither this person's work nor the server's data stays on the phone.
  Future<void> clearServerData() => transaction(() async {
        for (final table in <TableInfo>[
          catalogItems,
          catalogBarcodes,
          warehouseLocations,
          remoteCountSessions,
          remoteCountLines,
          syncCursors,
          syncQueue,
          countItems,
          countSessions,
        ]) {
          await delete(table).go();
        }
      });
```

`lib/data/sync/change_feed_puller.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/local/app_database.dart';

/// Brings the phone's copy up to date: reads `/warehouses/{w}/sync/changes` from the stored cursor until the server
/// says there is no more. Each page is applied, with its cursor, in one transaction, so an interrupted pull resumes
/// where it stopped.
class ChangeFeedPuller {
  ChangeFeedPuller({required ApiClient client, required AppDatabase db})
      : _client = client,
        _db = db;

  final ApiClient _client;
  final AppDatabase _db;

  Future<int> pull(String warehouseId) async {
    var applied = 0;
    var cursor = await _db.serverMirrorDao.cursorFor(warehouseId);
    while (true) {
      final page = await _client.get(
        '/warehouses/$warehouseId/sync/changes',
        query: {'cursor': '$cursor', 'limit': '500'},
      ) as Map<String, dynamic>;
      final changes = (page['changes'] as List).cast<Map<String, dynamic>>();
      final next = (page['nextCursor'] as num).toInt();
      await _db.transaction(() async {
        for (final change in changes) {
          await _apply(change);
        }
        await _db.serverMirrorDao.saveCursor(warehouseId, next);
      });
      applied += changes.length;
      cursor = next;
      if (page['hasMore'] != true) return applied;
    }
  }

  Future<void> _apply(Map<String, dynamic> change) async {
    final dao = _db.serverMirrorDao;
    final id = change['id'] as String;
    final data = change['deleted'] == true ? null : change['data'] as Map<String, dynamic>?;
    switch (change['entity']) {
      case 'item':
        if (data == null) return dao.deleteItem(id);
        return dao.upsertItem(CatalogItemsCompanion.insert(
          id: id,
          sku: data['sku'] as String,
          name: data['name'] as String,
          uom: data['uom'] as String,
          isActive: data['isActive'] as bool,
        ));
      case 'itemBarcode':
        if (data == null) return dao.deleteBarcode(id);
        return dao.upsertBarcode(CatalogBarcodesCompanion.insert(id: id, itemId: data['itemId'] as String, code: data['code'] as String));
      case 'location':
        if (data == null) return dao.deleteLocation(id);
        return dao.upsertLocation(WarehouseLocationsCompanion.insert(
          id: id,
          warehouseId: data['warehouseId'] as String,
          code: data['code'] as String,
          type: data['type'] as String,
        ));
      case 'countSession':
        if (data == null) return dao.deleteCountSession(id);
        return dao.upsertCountSession(
          RemoteCountSessionsCompanion.insert(
            id: id,
            warehouseId: data['warehouseId'] as String,
            createdByUserId: data['createdByUserId'] as String,
            label: Value(data['label'] as String?),
            status: data['status'] as String,
            submittedAt: DateTime.parse(data['submittedAt'] as String),
            reviewedAt: Value(data['reviewedAt'] == null ? null : DateTime.parse(data['reviewedAt'] as String)),
            rejectReason: Value(data['rejectReason'] as String?),
          ),
          [
            for (final line in (data['lines'] as List).cast<Map<String, dynamic>>())
              RemoteCountLinesCompanion.insert(
                id: line['id'] as String,
                sessionId: id,
                itemId: line['itemId'] as String,
                locationId: line['locationId'] as String,
                counted: (line['counted'] as num).toDouble(),
                systemAtSubmit: (line['systemAtSubmit'] as num).toDouble(),
                adjustment: Value((line['adjustment'] as num?)?.toDouble()),
              ),
          ],
        );
      default:
        // Purchase orders, orders, tasks and alerts are stored from 3b. Its migration resets sync_cursors so they are
        // pulled from the start.
        return;
    }
  }
}
```

- [ ] **Step 5: Regenerate, then run the tests**

```bash
$F pub run build_runner build --delete-conflicting-outputs
$F test test/data && $F analyze lib test
```
Expected: the 5 puller tests PASS; the existing `sync_queue_dao_test` and `sync_service_test` still PASS; analyze clean.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(sync): keep a local copy of the server's catalogue, locations and counts from the change feed"
```

---

### Task 3: Signing in to a warehouse

**Files:**
- Create: `lib/data/api/api_providers.dart`, `lib/data/api/api_auth_repository.dart`, `lib/core/router/auth_redirect.dart`, `lib/features/auth/presentation/choose_warehouse_screen.dart`
- Modify: `lib/core/models/user_session.dart`, `lib/data/repositories/auth_repository.dart`, `lib/data/sample/sample_auth_repository.dart`, `lib/core/providers/auth_provider.dart`, `lib/core/router/app_routes.dart`, `lib/core/router/app_router.dart`, `lib/features/profile/screens/profile_screen.dart`, `lib/main.dart`
- Test: `test/data/api/api_auth_repository_test.dart`, `test/core/router/auth_redirect_test.dart`

**Interfaces:**
- Consumes: `ApiClient`, `TokenStore`, `ApiException`, `ApiOfflineException` and `SessionExpiredException` (Task 1); `AppDatabase.clearServerData` (Task 2).
- Produces:
  - `WarehouseMembership(warehouseId, code, name, role)`.
  - `UserSession` gains `warehouseId` (String?), `warehouses` (List) and `needsWarehouse`.
  - `AuthRepository.selectWarehouse(session, warehouseId) → Future<UserSession>`.
  - `AuthFailure(message)`.
  - `ApiAuthRepository(client:, db:)`.
  - `apiClientProvider`.
  - `AuthNotifier.selectWarehouse(id)`.
  - `authRedirect({auth, location}) → String?`.
  - Route constants `AppRoutes.chooseWarehouse`, `AppRoutes.syncIssues` and `AppRoutes.pendingReviewDetail`; `ChooseWarehouseScreen`.

- [ ] **Step 1: Write the failing tests**

`test/data/api/api_auth_repository_test.dart`:
```dart
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
    final repo = repoAnswering((_) async => jsonResponse({'status': 401, 'code': 'invalid-refresh-token'}, 401), tokens: TokenStore(keys));

    expect(await repo.getStoredSession(), isNull);
    expect(keys.values['api.refreshToken'], isNull);
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
}
```

`test/core/router/auth_redirect_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/router/auth_redirect.dart';

const sa1 = WarehouseMembership(warehouseId: 'sa1', code: 'SA1', name: 'Shah Alam DC', role: UserRole.supervisor);
const kp1 = WarehouseMembership(warehouseId: 'kp1', code: 'KP1', name: 'Klang Port Store', role: UserRole.worker);

UserSession session({String? warehouseId, List<WarehouseMembership> warehouses = const [], UserRole role = UserRole.worker}) => UserSession(
      userId: 'u1',
      name: 'Hafiz Rahman',
      email: 'hafiz@waretrack.local',
      site: '',
      role: role,
      token: 't',
      warehouseId: warehouseId,
      warehouses: warehouses,
    );

void main() {
  test('nobody signed in goes to welcome, except on the sign-in screens', () {
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.dashboard), AppRoutes.welcome);
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.login), isNull);
  });

  test('a person with several warehouses chooses one before anything else', () {
    final waiting = AsyncData<UserSession?>(session(warehouses: [sa1, kp1]));
    expect(authRedirect(auth: waiting, location: AppRoutes.dashboard), AppRoutes.chooseWarehouse);
    expect(authRedirect(auth: waiting, location: AppRoutes.chooseWarehouse), isNull);
  });

  test('switching is allowed with several warehouses, not with one', () {
    expect(authRedirect(auth: AsyncData(session(warehouseId: 'sa1', warehouses: [sa1, kp1])), location: AppRoutes.chooseWarehouse), isNull);
    expect(authRedirect(auth: AsyncData(session(warehouseId: 'sa1', warehouses: [sa1])), location: AppRoutes.chooseWarehouse), AppRoutes.dashboard);
  });

  test('workers stay out of supervisor screens', () {
    final worker = AsyncData<UserSession?>(session(warehouseId: 'kp1', warehouses: [kp1]));
    expect(authRedirect(auth: worker, location: AppRoutes.pendingReview), AppRoutes.dashboard);
    expect(authRedirect(auth: worker, location: AppRoutes.pendingReviewDetail), AppRoutes.dashboard);
  });

  test('Sample-mode sessions (no warehouses) go straight in', () {
    expect(authRedirect(auth: AsyncData(session()), location: AppRoutes.login), AppRoutes.dashboard);
  });
}
```

- [ ] **Step 2: Run them to verify they fail**

Run: `$F test test/data/api/api_auth_repository_test.dart test/core/router/auth_redirect_test.dart`
Expected: FAIL — compile errors: `ApiAuthRepository`, `WarehouseMembership` and `authRedirect` don't exist.

- [ ] **Step 3: The session model and the repository contract**

In `lib/core/models/user_session.dart`:
- add above `UserSession`:
```dart
/// A warehouse the person may use, and their role there (spec §2: Worker or Supervisor per warehouse).
class WarehouseMembership {
  const WarehouseMembership({required this.warehouseId, required this.code, required this.name, required this.role});

  final String warehouseId;
  final String code;
  final String name;
  final UserRole role;
}
```
- add the fields `final String? warehouseId;` and `final List<WarehouseMembership> warehouses;` with constructor params `this.warehouseId, this.warehouses = const []`;
- add to `copyWith`: `String? warehouseId, List<WarehouseMembership>? warehouses`, passing `warehouseId: warehouseId ?? this.warehouseId, warehouses: warehouses ?? this.warehouses`;
- add the getter:
```dart
  /// Signed in to the server with several warehouses and none chosen yet.
  bool get needsWarehouse => warehouseId == null && warehouses.isNotEmpty;
```
- make `==` also compare `other.warehouseId == warehouseId`, and `hashCode` → `Object.hash(userId, token, warehouseId)`. Choosing a warehouse must notify the router.

In `lib/data/repositories/auth_repository.dart`:
- add to `AuthRepository`:
```dart
  /// The session as it is in [warehouseId]: its name and the person's role there.
  Future<UserSession> selectWarehouse(UserSession session, String warehouseId);
```
- add below the class:
```dart
/// A sign-in the person can do something about. [message] is shown as is.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
```

In `lib/data/sample/sample_auth_repository.dart` add:
```dart
  @override
  Future<UserSession> selectWarehouse(UserSession session, String warehouseId) async => session; // one site in Sample mode
```

- [ ] **Step 4: The API repository**

`lib/data/api/api_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Overridden in main.dart when the app is built with WARETRACK_API.
final apiClientProvider = Provider<ApiClient>((_) => throw UnimplementedError('apiClientProvider needs WARETRACK_API'));
```

`lib/data/api/api_auth_repository.dart`:
```dart
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';

import 'api_client.dart';
import 'api_exception.dart';
import 'token_store.dart';

/// Phone sign-in against the server (spec §3 Auth): tokens in [TokenStore], one chosen warehouse at a time.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required ApiClient client, required AppDatabase db})
      : _client = client,
        _db = db;

  final ApiClient _client;
  final AppDatabase _db;

  TokenStore get _tokens => _client.tokens;

  @override
  Future<UserSession> login(String email, String password) async {
    final Map<String, dynamic> json;
    try {
      json = await _client.post(
        '/auth/login',
        authenticated: false,
        body: {'email': email, 'password': password, 'deviceId': await _tokens.deviceId()},
      ) as Map<String, dynamic>;
    } on ApiException catch (e) {
      throw AuthFailure(e.status == 401 ? 'Wrong email or password.' : e.message);
    } on ApiOfflineException {
      throw const AuthFailure("Couldn't reach WareTrack. Check your connection and try again.");
    }
    final user = json['user'] as Map<String, dynamic>;
    final session = _sessionFrom(user, json['accessToken'] as String, await _tokens.readWarehouseId());
    if (session.warehouses.isEmpty) {
      throw const AuthFailure("Your account isn't part of any warehouse yet. Ask an administrator to add you to one.");
    }
    await _tokens.save(AuthTokens.fromJson(json));
    await _tokens.saveUser(user);
    if (session.warehouseId != null) await _tokens.saveWarehouseId(session.warehouseId!);
    return session;
  }

  @override
  Future<UserSession?> getStoredSession() async {
    if (await _tokens.refreshToken == null) return null;
    try {
      await _client.refresh(); // a fresh access token and up-to-date warehouses when online
    } on SessionExpiredException {
      return null;
    } on ApiOfflineException {
      // Keep working offline with what was stored.
    } on ApiException {
      // Server trouble: the same.
    }
    final user = await _tokens.readUser();
    if (user == null) {
      await _tokens.clear();
      return null;
    }
    final session = _sessionFrom(user, _tokens.accessToken ?? '', await _tokens.readWarehouseId());
    if (session.warehouses.isEmpty) {
      await clearSession(); // every warehouse was taken away meanwhile
      return null;
    }
    return session;
  }

  @override
  Future<UserSession> selectWarehouse(UserSession session, String warehouseId) async {
    final membership = session.warehouses.where((w) => w.warehouseId == warehouseId);
    if (membership.isEmpty) throw StateError('Not a member of $warehouseId');
    await _tokens.saveWarehouseId(warehouseId);
    return session.copyWith(warehouseId: warehouseId, site: membership.first.name, role: membership.first.role);
  }

  @override
  Future<void> storeSession(UserSession session) async {
    if (session.warehouseId != null) await _tokens.saveWarehouseId(session.warehouseId!);
  }

  @override
  Future<void> clearSession() async {
    final refreshToken = await _tokens.refreshToken;
    if (refreshToken != null) {
      try {
        await _client.post('/auth/logout', authenticated: false, body: {'refreshToken': refreshToken});
      } on Exception {
        // Signed out on this phone either way; the token expires on its own.
      }
    }
    await _tokens.clear();
    await _db.clearServerData();
  }

  UserSession _sessionFrom(Map<String, dynamic> user, String accessToken, String? preferredWarehouseId) {
    final warehouses = [
      for (final m in (user['warehouses'] as List).cast<Map<String, dynamic>>())
        WarehouseMembership(
          warehouseId: m['warehouseId'] as String,
          code: m['warehouseCode'] as String,
          name: m['warehouseName'] as String,
          role: m['role'] == 'Supervisor' ? UserRole.supervisor : UserRole.worker,
        ),
    ];
    WarehouseMembership? chosen;
    if (warehouses.length == 1) {
      chosen = warehouses.first;
    } else {
      for (final w in warehouses) {
        if (w.warehouseId == preferredWarehouseId) chosen = w;
      }
    }
    return UserSession(
      userId: user['id'] as String,
      name: user['displayName'] as String,
      email: user['email'] as String,
      site: chosen?.name ?? '',
      role: chosen?.role ?? UserRole.worker,
      token: accessToken,
      warehouseId: chosen?.warehouseId,
      warehouses: warehouses,
    );
  }
}
```

- [ ] **Step 5: Choosing a warehouse in the app**

In `lib/core/providers/auth_provider.dart`, add to `AuthNotifier`:
```dart
  /// Chooses (or switches to) one of the person's warehouses.
  Future<void> selectWarehouse(String warehouseId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(await ref.read(authRepositoryProvider).selectWarehouse(current, warehouseId));
  }
```

In `lib/core/router/app_routes.dart`, add:
```dart
  static const chooseWarehouse = '/choose-warehouse';
  static const syncIssues = '/sync';
  static const pendingReviewDetail = '/pending-review/detail';
```

`lib/core/router/auth_redirect.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_session.dart';
import 'app_routes.dart';

const _supervisorOnly = [AppRoutes.assignTasks, AppRoutes.reports, AppRoutes.pendingReview, AppRoutes.pendingReviewDetail];

/// Where to send someone who asked for [location], or null to let them through.
String? authRedirect({required AsyncValue<UserSession?> auth, required String location}) {
  if (auth.isLoading) return null;
  final session = auth.valueOrNull;
  final onEntry = location == AppRoutes.login || location == AppRoutes.welcome;
  if (session == null) return onEntry ? null : AppRoutes.welcome;
  if (session.needsWarehouse) return location == AppRoutes.chooseWarehouse ? null : AppRoutes.chooseWarehouse;
  if (onEntry) return AppRoutes.dashboard;
  if (location == AppRoutes.chooseWarehouse && session.warehouses.length < 2) return AppRoutes.dashboard;
  if (session.role == UserRole.worker && _supervisorOnly.contains(location)) return AppRoutes.dashboard;
  return null;
}
```

In `lib/core/router/app_router.dart`:
- replace the body of `_RouterNotifier.redirect` with `return authRedirect(auth: _ref.read(authNotifierProvider), location: state.matchedLocation);`;
- add `import 'auth_redirect.dart';` and `import '../../features/auth/presentation/choose_warehouse_screen.dart';`;
- after the `AppRoutes.login` route, add:
```dart
      GoRoute(
        path: AppRoutes.chooseWarehouse,
        builder: (_, __) => const ChooseWarehouseScreen(),
      ),
```

`lib/features/auth/presentation/choose_warehouse_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

/// For people who work in more than one warehouse: the phone syncs one at a time.
class ChooseWarehouseScreen extends ConsumerWidget {
  const ChooseWarehouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).valueOrNull;
    if (session == null) return const SizedBox.shrink();
    final brightness = Theme.of(context).brightness;
    final switching = session.warehouseId != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: switching,
        title: const Text('Choose warehouse'),
        actions: [
          if (!switching)
            TextButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Sign out'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'You work in more than one warehouse. Counts and tasks on this phone belong to the one you choose.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
            ),
          ),
          for (final w in session.warehouses)
            ListTile(
              leading: const Icon(Icons.warehouse_outlined, color: AppColors.primary),
              title: Text(w.name, style: AppTextStyles.bodyMedium),
              subtitle: Text('${w.code} · ${w.role == UserRole.supervisor ? 'Supervisor' : 'Worker'}'),
              trailing: w.warehouseId == session.warehouseId ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).selectWarehouse(w.warehouseId);
                if (context.mounted) context.go(AppRoutes.dashboard);
              },
            ),
        ],
      ),
    );
  }
}
```

In `lib/features/profile/screens/profile_screen.dart`:
- add `import 'package:go_router/go_router.dart';` and `import 'package:warehouse_app/core/router/app_routes.dart';`;
- insert this before the `SwitchListTile` whose `value:` is `settings.biometricEnabled`:
```dart
          if (session.warehouses.length > 1)
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
              title: Text('Switch warehouse', style: AppTextStyles.bodyMedium),
              subtitle: Text(session.site),
              onTap: () => context.push(AppRoutes.chooseWarehouse),
            ),
```

- [ ] **Step 6: Choose the mode in `main.dart`**

Replace `lib/main.dart` with:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse_app/core/config/app_config.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_router.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_providers.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/data/repositories/receiving_repository.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/data/sample/sample_alerts_repository.dart';
import 'package:warehouse_app/data/sample/sample_auth_repository.dart';
import 'package:warehouse_app/data/sample/sample_receiving_repository.dart';
import 'package:warehouse_app/data/sample/sample_stock_count_repository.dart';
import 'package:warehouse_app/data/sample/sample_tasks_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/profile/providers/profile_provider.dart';
import 'package:warehouse_app/features/stock_count/providers/stock_count_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  final database = AppDatabase();
  // Built with --dart-define=WARETRACK_API=https://host/api: the server. Otherwise: Sample data, as before.
  final ApiClient? client = AppConfig.useApi
      ? ApiClient(baseUrl: AppConfig.apiBaseUrl, httpClient: http.Client(), tokens: TokenStore(SecureKeyValueStore(storage)))
      : null;
  final AuthRepository authRepository = client != null ? ApiAuthRepository(client: client, db: database) : SampleAuthRepository(storage);
  final initialSession = await authRepository.getStoredSession();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        if (client != null) apiClientProvider.overrideWithValue(client),
        alertsRepositoryProvider.overrideWith((_) => SampleAlertsRepository()),
        authBootstrapStateProvider.overrideWith((_) => AuthBootstrapState.hydrated(initialSession)),
        authRepositoryProvider.overrideWith((_) => authRepository),
        ordersRepositoryProvider.overrideWith((_) => SampleOrdersRepository()),
        receivingRepositoryProvider.overrideWith((_) => SampleReceivingRepository()),
        stockCountRepositoryProvider.overrideWith((_) => SampleStockCountRepository()),
        tasksRepositoryProvider.overrideWith((_) => SampleTasksRepository()),
      ],
      child: const WarehouseApp(),
    ),
  );
}

class WarehouseApp extends ConsumerStatefulWidget {
  const WarehouseApp({super.key});

  @override
  ConsumerState<WarehouseApp> createState() => _WarehouseAppState();
}

class _WarehouseAppState extends ConsumerState<WarehouseApp> {
  @override
  void initState() {
    super.initState();
    if (ref.read(useApiProvider)) {
      // The server refused the refresh token (revoked, deactivated): back to sign-in with nothing left behind.
      ref.read(apiClientProvider).onSessionExpired = () => ref.read(authNotifierProvider.notifier).logout();
    }
    Future.microtask(
      () => ref.read(stockCountNotifierProvider.notifier).tryResumeSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Activate sync watcher — reads provider to start the listener
    ref.watch(syncWatcherProvider);

    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(profileSettingsProvider);
    return MaterialApp.router(
      title: 'WareTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 7: Run every check**

Run: `$F test && $F analyze lib test`
Expected:
- the 7 repository tests and the 5 redirect tests PASS;
- the existing auth, login and user-session tests still PASS;
- analyze is clean.

Also confirm the app builds in both modes:
`$F build apk --debug` and `$F build apk --debug --dart-define=WARETRACK_API=http://10.0.2.2:5050`
Expected: both build. If no Android SDK is present, run `$F build ios --debug --no-codesign` instead and record which one ran.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat(auth): sign in to the WareTrack server and choose a warehouse"
```

---

### Task 4: The outbox — sending queued commands in order

**Files:**
- Create: `lib/data/sync/command_sender.dart`, `lib/data/sync/sync_coordinator.dart`, `lib/features/sync/sync_issues_screen.dart`
- Modify: `lib/data/local/daos/sync_queue_dao.dart`, `lib/data/sync/sync_service.dart`, `lib/data/sync/sync_provider.dart`, `lib/core/router/app_router.dart`, `lib/features/profile/screens/profile_screen.dart`
- Test: `test/data/sync/sync_service_test.dart` (extend), `test/data/local/sync_queue_dao_test.dart` (extend)

**Interfaces:**
- Consumes: `ApiClient`, the exceptions (Task 1); the `SyncQueue` columns (Task 2); `ChangeFeedPuller` (Task 2); `authNotifierProvider` with `warehouseId` (Task 3); `useApiProvider`, `apiClientProvider`.
- Produces:
  - `SyncOps.countSubmit`, `SyncOps.countApprove` and `SyncOps.countReject`.
  - `SyncQueueDao`:
    - `enqueue(…, {String? idempotencyKey, String? warehouseId})`;
    - `markConflicted` and `markFailed` (both `(id, ApiException)`), `recordAttempt`, `dismiss`;
    - `itemsFor(op, {warehouseId})`, `watchPendingCount()`, `watchIssues()`.
  - `CommandSender(client).send(item)`.
  - `SyncService(db:, sender?)` with `flushQueue() → Future<FlushOutcome>`, where `FlushOutcome` is `done`, `offline`, `sessionExpired` or `serverTrouble`.
  - `SyncCoordinator.syncNow()`.
  - `syncCoordinatorProvider`, `pendingChangesProvider` and `syncIssuesProvider`.
  - `SyncIssue(id, title, message)` and `SyncIssuesScreen`.

- [ ] **Step 1: Write the failing tests**

Append to `test/data/sync/sync_service_test.dart`. Add these imports: `package:http/http.dart` as `http`, `package:http/testing.dart`, `package:warehouse_app/data/api/api_client.dart`, `package:warehouse_app/data/api/api_exception.dart`, `package:warehouse_app/data/sync/command_sender.dart`, `dart:convert`, and `'../../support/api_fakes.dart'`.
```dart
  group('with the server', () {
    Future<SyncService> serviceAnswering(Future<http.Response> Function(http.Request) answer) async => SyncService(
          db: db,
          sender: CommandSender(ApiClient(baseUrl: testBaseUrl, tokens: await signedInTokens(), httpClient: MockClient(answer))),
        );

    Future<void> queueCount(String id, {String warehouse = 'w1'}) =>
        db.syncQueueDao.enqueue(operationType: SyncOps.countSubmit, referenceId: id, warehouseId: warehouse, payload: jsonEncode({'label': id, 'lines': []}));

    test('an_offline_flush_keeps_the_command_and_resends_it_with_the_same_key', () async {
      await queueCount('c1');
      final keys = <String>[];
      var online = false;
      final service = await serviceAnswering((r) async {
        keys.add(r.headers['Idempotency-Key']!);
        if (!online) throw http.ClientException('offline');
        return jsonResponse({'id': 'c1'});
      });

      expect(await service.flushQueue(), FlushOutcome.offline);
      expect(await db.syncQueueDao.countPending(), 1);

      online = true;
      expect(await service.flushQueue(), FlushOutcome.done);
      expect(await db.syncQueueDao.countPending(), 0);
      expect(keys.toSet(), hasLength(1)); // the server replays or finishes the first attempt instead of counting twice
    });

    test('a_refused_command_is_kept_with_its_reason_and_the_next_one_still_goes', () async {
      await queueCount('c1');
      await queueCount('c2');
      final sent = <String>[];
      final service = await serviceAnswering((r) async {
        sent.add(r.url.pathSegments[4]);
        return r.url.path.contains('/c1/')
            ? jsonResponse({'status': 409, 'code': 'session-already-reviewed', 'title': 'Count already reviewed', 'detail': 'This count was already approved.'}, 409)
            : jsonResponse({'id': 'c2'});
      });

      expect(await service.flushQueue(), FlushOutcome.done);

      expect(sent, ['c1', 'c2']);
      final issues = await db.syncQueueDao.watchIssues().first;
      expect(issues.single.referenceId, 'c1');
      expect(issues.single.status, 'conflicted');
      expect(ApiException.fromJson(jsonDecode(issues.single.lastError!) as Map<String, dynamic>).message, 'This count was already approved.');
    });

    test('server trouble stops the flush so later commands keep their order', () async {
      await queueCount('c1');
      await queueCount('c2');
      final sent = <String>[];
      final service = await serviceAnswering((r) async {
        sent.add(r.url.pathSegments[4]);
        return http.Response('', 503);
      });

      expect(await service.flushQueue(), FlushOutcome.serverTrouble);

      expect(sent, ['c1']);
      expect(await db.syncQueueDao.countPending(), 2);
    });

    test('an invalid command is marked failed and not sent again', () async {
      await queueCount('c1');
      var calls = 0;
      final service = await serviceAnswering((_) async {
        calls++;
        return jsonResponse({'status': 422, 'code': 'validation-failed', 'errors': {'lines.itemId': ['Unknown item.']}}, 422);
      });

      await service.flushQueue();
      await service.flushQueue();

      expect(calls, 1);
      expect((await db.syncQueueDao.watchIssues().first).single.status, 'failed');
    });
  });
```

Append to `test/data/local/sync_queue_dao_test.dart`:
```dart
  test('a dismissed issue no longer shows, and each command keeps one key', () async {
    await dao.enqueue(operationType: 'count.submit', referenceId: 'c1', payload: '{}');
    final item = (await dao.getPendingItems()).single;
    expect(item.idempotencyKey, matches(RegExp(r'^[0-9a-f-]{36}$')));

    await dao.markFailed(item.id, const ApiException(status: 422, title: 'Invalid'));
    expect((await dao.watchIssues().first).single.id, item.id);

    await dao.dismiss(item.id);
    expect(await dao.watchIssues().first, isEmpty);
  });
```
Add `import 'package:warehouse_app/data/api/api_exception.dart';`. Use the file's existing `dao` variable; if it is named differently, use that name.

- [ ] **Step 2: Run them to verify they fail**

Run: `$F test test/data/sync/sync_service_test.dart test/data/local/sync_queue_dao_test.dart`
Expected: FAIL — compile errors: `CommandSender`, `FlushOutcome`, `SyncOps`, `markFailed`, `watchIssues` and `dismiss` don't exist.

- [ ] **Step 3: The queue's states**

Replace `lib/data/local/daos/sync_queue_dao.dart` with:
```dart
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

/// The outbox (spec §3): commands wait here, oldest first, until the server has answered them.
@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueData>> getPendingItems() =>
      (select(syncQueue)..where((q) => q.status.equals('pending'))..orderBy([(q) => OrderingTerm.asc(q.id)])).get();

  /// Queues a command with its own Idempotency-Key, kept for every retry.
  Future<int> enqueue({
    required String operationType,
    required String referenceId,
    required String payload,
    String? idempotencyKey,
    String? warehouseId,
  }) =>
      into(syncQueue).insert(
        SyncQueueCompanion.insert(
          operationType: operationType,
          referenceId: referenceId,
          payload: payload,
          idempotencyKey: Value(idempotencyKey ?? const Uuid().v4()),
          warehouseId: Value(warehouseId),
        ),
      );

  Future<void> markSynced(int id) => (update(syncQueue)..where((q) => q.id.equals(id))).write(
        SyncQueueCompanion(status: const Value('synced'), synced: const Value(true), syncedAt: Value(DateTime.now())),
      );

  /// The server answered 409: things changed. Kept with the reason; the queue moves on.
  Future<void> markConflicted(int id, ApiException error) => _close(id, 'conflicted', error);

  /// Any other refusal: sending the same request again cannot succeed.
  Future<void> markFailed(int id, ApiException error) => _close(id, 'failed', error);

  Future<void> _close(int id, String status, ApiException error) => (update(syncQueue)..where((q) => q.id.equals(id))).write(
        SyncQueueCompanion(status: Value(status), lastError: Value(jsonEncode(error.toJson()))),
      );

  Future<void> recordAttempt(int id) =>
      customUpdate('UPDATE sync_queue SET attempts = attempts + 1 WHERE id = ?', variables: [Variable.withInt(id)], updates: {syncQueue});

  /// The person has read the reason.
  Future<void> dismiss(int id) =>
      (update(syncQueue)..where((q) => q.id.equals(id))).write(const SyncQueueCompanion(status: Value('dismissed')));

  /// Commands of one type that have not gone through: waiting, or refused and not dismissed. Newest first.
  Future<List<SyncQueueData>> itemsFor(String operationType, {String? warehouseId}) {
    final query = select(syncQueue)
      ..where((q) => q.operationType.equals(operationType) & q.status.isIn(['pending', 'conflicted', 'failed']))
      ..orderBy([(q) => OrderingTerm.desc(q.id)]);
    if (warehouseId != null) query.where((q) => q.warehouseId.equals(warehouseId));
    return query.get();
  }

  Future<int> countPending() async {
    final count = countAll(filter: syncQueue.status.equals('pending'));
    final query = selectOnly(syncQueue)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Stream<int> watchPendingCount() {
    final count = countAll(filter: syncQueue.status.equals('pending'));
    return (selectOnly(syncQueue)..addColumns([count])).watchSingle().map((row) => row.read(count) ?? 0);
  }

  Stream<List<SyncQueueData>> watchIssues() => (select(syncQueue)
        ..where((q) => q.status.isIn(['conflicted', 'failed']))
        ..orderBy([(q) => OrderingTerm.desc(q.id)]))
      .watch();
}
```

- [ ] **Step 4: Sending, flushing and coordinating**

`lib/data/sync/command_sender.dart`:
```dart
import 'dart:convert';

import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/local/app_database.dart';

/// The commands the phone queues. 3b adds receiving, orders, tasks and alerts.
class SyncOps {
  SyncOps._();

  static const countSubmit = 'count.submit';
  static const countApprove = 'count.approve';
  static const countReject = 'count.reject';
}

/// Sends one queued command to its endpoint (spec §3 Commands) with the command's own Idempotency-Key.
class CommandSender {
  CommandSender(this._client);

  final ApiClient _client;

  Future<void> send(SyncQueueData item) async {
    final session = '/warehouses/${item.warehouseId}/count-sessions/${item.referenceId}';
    final key = item.idempotencyKey;
    switch (item.operationType) {
      case SyncOps.countSubmit:
        await _client.post('$session/submit', body: jsonDecode(item.payload), idempotencyKey: key);
      case SyncOps.countApprove:
        await _client.post('$session/approve', idempotencyKey: key);
      case SyncOps.countReject:
        await _client.post('$session/reject', body: jsonDecode(item.payload), idempotencyKey: key);
      default:
        throw UnsupportedError('Nothing sends "${item.operationType}" to the server.');
    }
  }
}
```

Replace `lib/data/sync/sync_service.dart` with:
```dart
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart';

import 'command_sender.dart';

enum FlushOutcome { done, offline, sessionExpired, serverTrouble }

/// Sends the outbox oldest first, following the response table in spec §3:
/// - 2xx: done.
/// - 409: kept as conflicted with the server's reason; the next command still goes.
/// - Any other 4xx: failed.
/// - 5xx, 429, offline or session ended: stop, so later commands keep their order, and retry on the next run.
/// Without a [CommandSender] (Sample mode) there is nothing to send: queued items are simply marked done.
class SyncService {
  SyncService({required AppDatabase db, CommandSender? sender})
      : _db = db,
        _sender = sender;

  final AppDatabase _db;
  final CommandSender? _sender;
  Future<FlushOutcome>? _running;

  Future<FlushOutcome> flushQueue() => _running ??= _flush().whenComplete(() => _running = null);

  Future<FlushOutcome> _flush() async {
    final dao = _db.syncQueueDao;
    for (final item in await dao.getPendingItems()) {
      final sender = _sender;
      if (sender == null) {
        await dao.markSynced(item.id);
        continue;
      }
      await dao.recordAttempt(item.id);
      try {
        await sender.send(item);
        await dao.markSynced(item.id);
      } on ApiException catch (e) {
        if (e.status == 409) {
          await dao.markConflicted(item.id, e);
        } else if (e.status == 401) {
          return FlushOutcome.sessionExpired;
        } else if (e.status >= 500 || e.status == 429) {
          return FlushOutcome.serverTrouble;
        } else {
          await dao.markFailed(item.id, e);
        }
      } on ApiOfflineException {
        return FlushOutcome.offline;
      } on SessionExpiredException {
        return FlushOutcome.sessionExpired;
      } on UnsupportedError catch (e) {
        await dao.markFailed(item.id, ApiException(status: 0, title: e.message));
      }
    }
    return FlushOutcome.done;
  }
}
```

`lib/data/sync/sync_coordinator.dart`:
```dart
import 'package:warehouse_app/data/api/api_exception.dart';

import 'change_feed_puller.dart';
import 'sync_service.dart';

/// Sends the outbox, then pulls what changed. Runs one at a time; asking during a run asks for one more run
/// afterwards, so nothing queued meanwhile waits for the next trigger.
class SyncCoordinator {
  SyncCoordinator({required SyncService outbox, required ChangeFeedPuller? puller, required String? Function() warehouseId})
      : _outbox = outbox,
        _puller = puller,
        _warehouseId = warehouseId;

  final SyncService _outbox;
  final ChangeFeedPuller? _puller;
  final String? Function() _warehouseId;
  Future<void>? _running;
  bool _again = false;

  Future<void> syncNow() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      await _runOnce();
    } while (_again);
  }

  Future<void> _runOnce() async {
    final outcome = await _outbox.flushQueue();
    final warehouseId = _warehouseId();
    final puller = _puller;
    if (puller == null || warehouseId == null) return;
    if (outcome == FlushOutcome.offline || outcome == FlushOutcome.sessionExpired) return;
    try {
      await puller.pull(warehouseId);
    } on ApiOfflineException {
      // Next reconnect.
    } on ApiException {
      // Server trouble: next run.
    } on SessionExpiredException {
      // The client has already sent the person back to sign-in.
    }
  }
}
```

Replace `lib/data/sync/sync_provider.dart` with:
```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/config/app_config.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/providers/connectivity_provider.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/api/api_providers.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_coordinator.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SyncService(db: db, sender: ref.watch(useApiProvider) ? CommandSender(ref.watch(apiClientProvider)) : null);
});

final changeFeedPullerProvider = Provider<ChangeFeedPuller?>((ref) {
  if (!ref.watch(useApiProvider)) return null;
  return ChangeFeedPuller(client: ref.watch(apiClientProvider), db: ref.watch(appDatabaseProvider));
});

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) => SyncCoordinator(
      outbox: ref.watch(syncServiceProvider),
      puller: ref.watch(changeFeedPullerProvider),
      warehouseId: () => ref.read(authNotifierProvider).valueOrNull?.warehouseId,
    ));

/// Syncs when the phone comes back online and whenever a warehouse is chosen (sign-in, restart, switch).
/// Attach this provider in WarehouseApp.build() to activate it.
final syncWatcherProvider = Provider<void>((ref) {
  ref.listen<bool>(isOnlineProvider, (previous, next) {
    if (previous == false && next) unawaited(ref.read(syncCoordinatorProvider).syncNow());
  });
  ref.listen<String?>(
    authNotifierProvider.select((auth) => auth.valueOrNull?.warehouseId),
    (previous, next) {
      if (next != null && next != previous) unawaited(ref.read(syncCoordinatorProvider).syncNow());
    },
    fireImmediately: true,
  );
});

final pendingChangesProvider = StreamProvider<int>((ref) => ref.watch(appDatabaseProvider).syncQueueDao.watchPendingCount());

/// A command the server did not accept, with its reason.
class SyncIssue {
  const SyncIssue({required this.id, required this.title, required this.message});

  final int id;
  final String title;
  final String message;
}

final syncIssuesProvider = StreamProvider<List<SyncIssue>>((ref) {
  return ref.watch(appDatabaseProvider).syncQueueDao.watchIssues().map((items) => [
        for (final item in items)
          SyncIssue(
            id: item.id,
            title: switch (item.operationType) {
              SyncOps.countSubmit => 'Count not accepted',
              SyncOps.countApprove => 'Approval not accepted',
              SyncOps.countReject => 'Rejection not accepted',
              _ => 'Change not accepted',
            },
            message: item.lastError == null
                ? 'WareTrack refused this change.'
                : ApiException.fromJson(jsonDecode(item.lastError!) as Map<String, dynamic>).message,
          ),
      ]);
});
```

- [ ] **Step 5: Show it in the app**

`lib/features/sync/sync_issues_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';

/// What is waiting to be sent, and what the server did not accept and why.
class SyncIssuesScreen extends ConsumerWidget {
  const SyncIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingChangesProvider).valueOrNull ?? 0;
    final issues = ref.watch(syncIssuesProvider).valueOrNull ?? const <SyncIssue>[];
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            pending == 0
                ? 'Everything on this phone has been sent.'
                : '$pending ${pending == 1 ? 'change is' : 'changes are'} waiting to be sent.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => ref.read(syncCoordinatorProvider).syncNow(),
            icon: const Icon(Icons.sync),
            label: const Text('Send now'),
          ),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Not accepted', style: AppTextStyles.title),
            const SizedBox(height: 8),
            for (final issue in issues)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: AppColors.error),
                  title: Text(issue.title, style: AppTextStyles.bodyMedium),
                  subtitle: Text(issue.message, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(brightness))),
                  trailing: TextButton(
                    onPressed: () => ref.read(appDatabaseProvider).syncQueueDao.dismiss(issue.id),
                    child: const Text('Dismiss'),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
```

In `lib/core/router/app_router.dart`, import the screen and add after the `AppRoutes.alerts` route:
```dart
      GoRoute(
        path: AppRoutes.syncIssues,
        builder: (_, __) => const SyncIssuesScreen(),
      ),
```

In `lib/features/profile/screens/profile_screen.dart`:
- import `package:warehouse_app/data/sync/sync_provider.dart`;
- insert `const _SyncTile(),` before the `if (session.warehouses.length > 1)` tile added in Task 3;
- replace `onPressed: () => ref.read(authNotifierProvider.notifier).logout(),` with `onPressed: () => _signOut(context, ref),`;
- add at the end of the file:
```dart
class _SyncTile extends ConsumerWidget {
  const _SyncTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingChangesProvider).valueOrNull ?? 0;
    final issues = ref.watch(syncIssuesProvider).valueOrNull?.length ?? 0;
    final subtitle = issues > 0
        ? '$issues ${issues == 1 ? 'change was' : 'changes were'} not accepted'
        : pending > 0
            ? '$pending ${pending == 1 ? 'change' : 'changes'} waiting to send'
            : 'Everything sent';
    return ListTile(
      leading: Icon(Icons.sync, color: issues > 0 ? AppColors.error : AppColors.primary),
      title: Text('Sync', style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle),
      onTap: () => context.push(AppRoutes.syncIssues),
    );
  }
}

/// Unsent changes belong to this person: signing out deletes them, so say so first.
Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final pending = ref.read(pendingChangesProvider).valueOrNull ?? 0;
  if (pending > 0) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out with unsent changes?'),
        content: Text(
          "$pending ${pending == 1 ? "change hasn't" : "changes haven't"} been sent yet. Signing out deletes "
          "${pending == 1 ? 'it' : 'them'} from this phone.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirmed != true) return;
  }
  await ref.read(authNotifierProvider.notifier).logout();
}
```

- [ ] **Step 6: Regenerate and run every check**

```bash
$F pub run build_runner build --delete-conflicting-outputs
$F test && $F analyze lib test
```
Expected: the 4 new sync-service tests and the new DAO test PASS; the original two sync-service tests still PASS (Sample mode, no sender); analyze clean.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(sync): send queued commands in order and show what the server did not accept"
```

---

### Task 5: Counting against the server

**Files:**
- Create: `lib/core/models/count_records.dart`, `lib/data/api/api_stock_count_repository.dart`, `lib/features/stock_count/presentation/count_setup_screen.dart`, `lib/features/stock_count/presentation/count_item_picker_screen.dart`
- Modify:
  - `lib/core/models/count_session.dart` (`CountItem.itemId`);
  - `lib/data/repositories/stock_count_repository.dart`, `lib/data/sample/sample_stock_count_repository.dart`;
  - `lib/features/stock_count/providers/stock_count_provider.dart`, `lib/features/stock_count/providers/create_count_session_notifier.dart`;
  - `lib/features/stock_count/presentation/scan_count_screen.dart`, `review_count_screen.dart`, `start_count_screen.dart`;
  - `lib/core/router/app_router.dart`, `lib/main.dart`.
- Test: `test/data/api/api_stock_count_repository_test.dart`, `test/features/stock_count/stock_count_provider_test.dart` (extend), `test/features/stock_count/count_setup_screen_test.dart`

**Interfaces:**
- Consumes: `serverMirrorDao` (Task 2); `SyncQueueDao.enqueue`/`itemsFor` and `SyncOps` (Task 4); `UserSession.warehouseId`/`userId` (Task 3); `syncCoordinatorProvider`.
- Produces:
  - `CatalogItemRef(id, sku, name)` and `CountLocation(id, code, kind)`.
  - `CountSummary(id, title, lineCount, progress, submittedAt?, note?)`, with `CountProgress` = `sending`, `notAccepted`, `waitingReview`, `approved` or `rejected`.
  - `formatQty(double)`.
  - `StockCountRepository` methods:
    - `lookupItemByBarcode(code) → CatalogItemRef?`, `searchItems(term)`;
    - `getLocations()`, `getRecentCounts()`, `submitSession(session)`;
    - the supervisor methods added in Task 6.
  - `ApiStockCountRepository(client:, db:, session:, onQueued:)`.
  - `recentCountsProvider` and `countLocationsProvider`.
  - `StockCountNotifier.startSession({location, label, locationId})`: GUID ids, items keep `itemId`.

- [ ] **Step 1: Write the failing tests**

`test/data/api/api_stock_count_repository_test.dart`:
```dart
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/api/api_stock_count_repository.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

import '../../support/api_fakes.dart';

const w = '22222222-2222-4222-8222-222222222222';
const me = '11111111-1111-4111-8111-111111111111';
const beras = 'aaaaaaaa-0000-4000-8000-000000000001';
const bin = 'bbbbbbbb-0000-4000-8000-000000000001';

UserSession worker() => const UserSession(
      userId: me,
      name: 'Arjun Nair',
      email: 'arjun@waretrack.local',
      site: 'Shah Alam DC',
      role: UserRole.worker,
      token: 't',
      warehouseId: w,
      warehouses: [WarehouseMembership(warehouseId: w, code: 'SA1', name: 'Shah Alam DC', role: UserRole.worker)],
    );

void main() {
  late AppDatabase db;
  late int kicks;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    kicks = 0;
    await db.serverMirrorDao.upsertItem(CatalogItemsCompanion.insert(id: beras, sku: 'WT-0001', name: 'Beras Wangi 10kg', uom: 'BAG', isActive: true));
    await db.serverMirrorDao.upsertBarcode(CatalogBarcodesCompanion.insert(id: 'bc1', itemId: beras, code: '9556001000011'));
    await db.serverMirrorDao.upsertLocation(WarehouseLocationsCompanion.insert(id: bin, warehouseId: w, code: 'A-01-01', type: 'Bin'));
  });
  tearDown(() => db.close());

  Future<ApiStockCountRepository> repo([Future<http.Response> Function(http.Request)? answer]) async => ApiStockCountRepository(
        client: ApiClient(baseUrl: testBaseUrl, tokens: await signedInTokens(), httpClient: MockClient(answer ?? (_) async => http.Response('', 404))),
        db: db,
        session: worker,
        onQueued: () => kicks++,
      );

  test('barcode lookup uses the phone copy first, then asks the server for codes it has not seen', () async {
    final asked = <String>[];
    final counts = await repo((r) async {
      asked.add(r.url.path);
      return jsonResponse({
        'barcode': '9556001000028',
        'item': {'id': 'new-item', 'sku': 'WT-0002', 'name': 'Gula Pasir 1kg', 'uom': 'PKT', 'lowStockThreshold': null, 'isActive': true},
      });
    });

    expect((await counts.lookupItemByBarcode('9556001000011'))?.sku, 'WT-0001');
    expect(asked, isEmpty);
    expect((await counts.lookupItemByBarcode('9556001000028'))?.name, 'Gula Pasir 1kg');
    expect(asked, ['/api/catalog/barcodes/9556001000028']);
  });

  test('a_count_listing_an_item_twice_sends_one_line_with_the_total', () async {
    final counts = await repo();
    final session = CountSession(
      id: 'c0ffee00-0000-4000-8000-000000000001',
      location: 'A-01-01',
      locationId: bin,
      label: null,
      startedAt: DateTime(2026, 10, 11),
      status: CountSessionStatus.inProgress,
      items: [
        CountItem(itemId: beras, itemCode: 'WT-0001', itemName: 'Beras Wangi 10kg', expected: 0, counted: 5),
        CountItem(itemId: beras, itemCode: 'WT-0001', itemName: 'Beras Wangi 10kg', expected: 0, counted: 3),
      ],
    );

    await counts.submitSession(session);

    final queued = (await db.syncQueueDao.getPendingItems()).single;
    expect(queued.operationType, SyncOps.countSubmit);
    expect(queued.referenceId, session.id);
    expect(queued.warehouseId, w);
    expect(jsonDecode(queued.payload), {
      'label': 'A-01-01', // no label given: the location names it for the reviewer
      'lines': [{'itemId': beras, 'locationId': bin, 'counted': 8}],
    });
    expect(kicks, 1);
  });

  test('recent counts show what is waiting, what was refused and what the supervisor decided', () async {
    final counts = await repo();
    await db.syncQueueDao.enqueue(operationType: SyncOps.countSubmit, referenceId: 'queued', warehouseId: w, payload: jsonEncode({'label': 'Cold room', 'lines': [{}, {}]}));
    await db.syncQueueDao.enqueue(operationType: SyncOps.countSubmit, referenceId: 'refused', warehouseId: w, payload: jsonEncode({'label': 'Dock', 'lines': [{}]}));
    final refused = (await db.syncQueueDao.getPendingItems()).last;
    await db.syncQueueDao.markFailed(refused.id, const ApiException(status: 422, errors: {'lines.itemId': ['Unknown item.']}));
    await db.serverMirrorDao.upsertCountSession(
      RemoteCountSessionsCompanion.insert(id: 'done', warehouseId: w, createdByUserId: me, status: 'Rejected', submittedAt: DateTime(2026, 10, 10), rejectReason: const Value('Count the back row too')),
      [],
    );

    final recent = await counts.getRecentCounts();

    expect(recent.map((c) => c.progress), [CountProgress.notAccepted, CountProgress.sending, CountProgress.rejected]);
    expect(recent[0].note, 'Unknown item.');
    expect(recent[1].lineCount, 2);
    expect(recent[2].note, 'Count the back row too');
  });
}
```
Add `import 'package:drift/drift.dart' show Value;` to the imports above.

Append to `test/features/stock_count/stock_count_provider_test.dart` (inside `main`):
```dart
  test('new sessions get server-style ids and keep where they count', () async {
    await container.read(stockCountNotifierProvider.notifier).startSession(location: 'A-01-01', label: null, locationId: 'bin-1');

    final session = container.read(stockCountNotifierProvider)!;
    expect(session.id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    expect(session.locationId, 'bin-1');
  });

  test('counted items keep their catalogue id through a restart', () async {
    final notifier = container.read(stockCountNotifierProvider.notifier);
    await notifier.startSession(location: 'A-01-01', label: null, locationId: 'bin-1');
    await notifier.addItem(CountItem(itemId: 'item-1', itemCode: 'WT-0001', itemName: 'Beras', expected: 0, counted: 4));
    final id = container.read(stockCountNotifierProvider)!.id;

    final reloaded = await notifier.loadSessionById(id);

    expect(reloaded!.items.single.itemId, 'item-1');
  });
```

`test/features/stock_count/count_setup_screen_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/local/app_database.dart' as db;
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/features/stock_count/presentation/count_setup_screen.dart';
import 'package:warehouse_app/features/stock_count/providers/stock_count_provider.dart';

class MockStockCountRepository extends Mock implements StockCountRepository {}

void main() {
  testWidgets('a count starts once a location is chosen', (tester) async {
    final repo = MockStockCountRepository();
    when(() => repo.getLocations()).thenAnswer((_) async => const [
          CountLocation(id: 'bin-1', code: 'A-01-01', kind: 'Bin'),
          CountLocation(id: 'zone-1', code: 'COLD', kind: 'Zone'),
        ]);
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(overrides: [
      stockCountRepositoryProvider.overrideWithValue(repo),
      db.appDatabaseProvider.overrideWithValue(database),
    ]);
    addTearDown(container.dispose);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const CountSetupScreen()),
      GoRoute(path: '/stock-count/scan', builder: (_, __) => const Text('Scanning')),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Counting'));
    await tester.pumpAndSettle();
    expect(find.text('Choose where you are counting.'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COLD · Zone').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Counting'));
    await tester.pumpAndSettle();

    expect(find.text('Scanning'), findsOneWidget);
    expect(container.read(stockCountNotifierProvider)?.locationId, 'zone-1');
    expect(container.read(stockCountNotifierProvider)?.location, 'COLD');
  });
}
```

- [ ] **Step 2: Run them to verify they fail**

Run: `$F test test/data/api/api_stock_count_repository_test.dart test/features/stock_count`
Expected: FAIL — compile errors: `count_records.dart`, `ApiStockCountRepository`, `CountItem.itemId`, the `startSession` `locationId` parameter and `CountSetupScreen` don't exist.

- [ ] **Step 3: The models and the repository contract**

`lib/core/models/count_records.dart`:
```dart
/// An item as counting needs it: the server's id, plus what to show.
class CatalogItemRef {
  const CatalogItemRef({required this.id, required this.sku, required this.name});

  final String id;
  final String sku;
  final String name;
}

/// Where a count happens: a bin, zone or dock of the warehouse.
class CountLocation {
  const CountLocation({required this.id, required this.code, required this.kind});

  final String id;
  final String code;
  final String kind;
}

enum CountProgress { sending, notAccepted, waitingReview, approved, rejected }

/// One count as its counter, or a supervisor, sees it in a list.
class CountSummary {
  const CountSummary({
    required this.id,
    required this.title,
    required this.lineCount,
    required this.progress,
    this.submittedAt,
    this.note,
  });

  final String id;
  final String title;
  final int lineCount;
  final CountProgress progress;
  final DateTime? submittedAt;

  /// The supervisor's reason for a rejection, or the server's reason for refusing it.
  final String? note;
}

/// A submitted count as a supervisor reviews it (live figures from the server).
class CountReview {
  const CountReview({required this.id, required this.title, required this.countedBy, required this.submittedAt, required this.status, required this.lines});

  final String id;
  final String title;
  final String countedBy;
  final DateTime submittedAt;
  final String status;
  final List<CountReviewLine> lines;

  /// Lines where stock moved since the count was submitted.
  int get movedLines => lines.where((l) => l.current != l.systemAtSubmit).length;

  /// Lines approval would change.
  int get changingLines => lines.where((l) => l.difference != 0).length;
}

class CountReviewLine {
  const CountReviewLine({
    required this.itemName,
    required this.sku,
    required this.locationCode,
    required this.counted,
    required this.systemAtSubmit,
    required this.current,
    required this.difference,
  });

  final String itemName;
  final String sku;
  final String locationCode;
  final double counted;
  final double systemAtSubmit;
  final double current;
  final double difference;
}

/// "8", "2.5", "-3": quantities without a trailing ".0".
String formatQty(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();
```

In `lib/core/models/count_session.dart`, give `CountItem` a server item id:
- add the field `final String? itemId;` with the doc comment `/// The server's item id; null in Sample mode.`;
- add the constructor parameter `this.itemId,`;
- in `copyWith`, pass `itemId: itemId,`.

Replace `lib/data/repositories/stock_count_repository.dart` with:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';

abstract class StockCountRepository {
  /// The item a barcode belongs to, or null when nobody knows it.
  Future<CatalogItemRef?> lookupItemByBarcode(String barcode);

  /// Items whose SKU or name contains [term], for counting without a barcode.
  Future<List<CatalogItemRef>> searchItems(String term);

  /// Where counts can happen in the current warehouse.
  Future<List<CountLocation>> getLocations();

  /// This person's latest counts: waiting to send, refused, or reviewed.
  Future<List<CountSummary>> getRecentCounts();

  /// Hands a finished count over for sending (queued until the server has it).
  Future<void> submitSession(CountSession session);
}

final stockCountRepositoryProvider = Provider<StockCountRepository>((ref) {
  throw UnimplementedError('stockCountRepositoryProvider not overridden');
});

final recentCountsProvider = FutureProvider.autoDispose<List<CountSummary>>(
  (ref) => ref.watch(stockCountRepositoryProvider).getRecentCounts(),
);

final countLocationsProvider = FutureProvider.autoDispose<List<CountLocation>>(
  (ref) => ref.watch(stockCountRepositoryProvider).getLocations(),
);
```

Replace `lib/data/sample/sample_stock_count_repository.dart` with:
```dart
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/sample/sample_locations.dart';

class SampleStockCountRepository implements StockCountRepository {
  static const _catalogue = {
    'WH-00142': 'Aluminium Sheet 2mm',
    'WH-00089': 'Steel Bolt M8',
    'WH-00210': 'Copper Wire 4mm',
    'WH-00301': 'PVC Pipe 20mm',
  };

  final List<CountSession> _sessions = [];

  @override
  Future<CatalogItemRef?> lookupItemByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final name = _catalogue[barcode];
    return name == null ? null : CatalogItemRef(id: barcode, sku: barcode, name: name);
  }

  @override
  Future<List<CatalogItemRef>> searchItems(String term) async {
    final query = term.trim().toLowerCase();
    return [
      for (final entry in _catalogue.entries)
        if (entry.key.toLowerCase().contains(query) || entry.value.toLowerCase().contains(query))
          CatalogItemRef(id: entry.key, sku: entry.key, name: entry.value),
    ];
  }

  @override
  Future<List<CountLocation>> getLocations() async =>
      [for (final location in sampleLocations) CountLocation(id: location.id, code: location.name, kind: 'Area')];

  @override
  Future<List<CountSummary>> getRecentCounts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      for (final session in _sessions.reversed.take(10))
        CountSummary(
          id: session.id,
          title: session.label ?? session.location,
          lineCount: session.items.length,
          progress: CountProgress.waitingReview,
          submittedAt: session.startedAt,
        ),
    ];
  }

  @override
  Future<void> submitSession(CountSession session) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _sessions.add(session.copyWith(status: CountSessionStatus.submitted));
  }
}
```

- [ ] **Step 4: The API repository**

`lib/data/api/api_stock_count_repository.dart`:
```dart
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

import 'api_client.dart';
import 'api_exception.dart';

final _guid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

/// Counts against the server: the catalogue and locations from the phone's copy, finished counts through the outbox.
class ApiStockCountRepository implements StockCountRepository {
  ApiStockCountRepository({
    required ApiClient client,
    required AppDatabase db,
    required UserSession? Function() session,
    required void Function() onQueued,
  })  : _client = client,
        _db = db,
        _session = session,
        _onQueued = onQueued;

  final ApiClient _client;
  final AppDatabase _db;
  final UserSession? Function() _session;
  final void Function() _onQueued;

  @override
  Future<CatalogItemRef?> lookupItemByBarcode(String barcode) async {
    final known = await _db.serverMirrorDao.itemByBarcode(barcode);
    if (known != null) return CatalogItemRef(id: known.id, sku: known.sku, name: known.name);
    try {
      // A code added on the server since the last pull (spec §3: online lookup for barcodes not yet cached).
      final found = await _client.get('/catalog/barcodes/${Uri.encodeComponent(barcode)}') as Map<String, dynamic>;
      final item = found['item'] as Map<String, dynamic>;
      return CatalogItemRef(id: item['id'] as String, sku: item['sku'] as String, name: item['name'] as String);
    } on ApiException {
      return null; // 404: nobody knows this code
    } on ApiOfflineException {
      return null; // offline and not in the copy: the counter can pick the item by name instead
    }
  }

  @override
  Future<List<CatalogItemRef>> searchItems(String term) async => [
        for (final item in await _db.serverMirrorDao.searchItems(term)) CatalogItemRef(id: item.id, sku: item.sku, name: item.name),
      ];

  @override
  Future<List<CountLocation>> getLocations() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    return [
      for (final location in await _db.serverMirrorDao.locationsFor(warehouseId))
        CountLocation(id: location.id, code: location.code, kind: location.type),
    ];
  }

  @override
  Future<void> submitSession(CountSession session) async {
    final locationId = session.locationId;
    if (locationId == null) throw StateError('Choose where you are counting first.');
    // The count belongs to the warehouse its location is in, even if the person switched warehouse meanwhile.
    final location = await _db.serverMirrorDao.locationById(locationId);
    final warehouseId = location?.warehouseId ?? _session()?.warehouseId;
    if (warehouseId == null) throw StateError('No warehouse chosen.');

    // The server takes each item once per location: entries of the same item are added up.
    final totals = <String, int>{};
    for (final item in session.items) {
      final itemId = item.itemId;
      if (itemId == null) throw StateError('${item.itemName} is not in the catalogue.');
      totals[itemId] = (totals[itemId] ?? 0) + item.counted;
    }
    final label = session.label?.trim();
    await _db.syncQueueDao.enqueue(
      operationType: SyncOps.countSubmit,
      referenceId: _guid.hasMatch(session.id) ? session.id : const Uuid().v4(),
      warehouseId: warehouseId,
      payload: jsonEncode({
        'label': label == null || label.isEmpty ? session.location : label,
        'lines': [
          for (final entry in totals.entries) {'itemId': entry.key, 'locationId': locationId, 'counted': entry.value},
        ],
      }),
    );
    _onQueued();
  }

  @override
  Future<List<CountSummary>> getRecentCounts() async {
    final session = _session();
    final warehouseId = session?.warehouseId;
    if (session == null || warehouseId == null) return const [];
    final summaries = <CountSummary>[
      for (final item in await _db.syncQueueDao.itemsFor(SyncOps.countSubmit, warehouseId: warehouseId)) _queued(item),
    ];
    for (final row in await _db.serverMirrorDao.countSessions(warehouseId: warehouseId, createdBy: session.userId, limit: 10)) {
      summaries.add(CountSummary(
        id: row.id,
        title: row.label ?? 'Count',
        lineCount: (await _db.serverMirrorDao.linesFor(row.id)).length,
        progress: switch (row.status) {
          'Approved' => CountProgress.approved,
          'Rejected' => CountProgress.rejected,
          _ => CountProgress.waitingReview,
        },
        submittedAt: row.submittedAt,
        note: row.rejectReason,
      ));
    }
    return summaries;
  }

  CountSummary _queued(SyncQueueData item) {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    final refused = item.status != 'pending';
    return CountSummary(
      id: item.referenceId,
      title: payload['label'] as String? ?? 'Count',
      lineCount: (payload['lines'] as List).length,
      progress: refused ? CountProgress.notAccepted : CountProgress.sending,
      submittedAt: item.queuedAt,
      note: refused && item.lastError != null
          ? ApiException.fromJson(jsonDecode(item.lastError!) as Map<String, dynamic>).message
          : null,
    );
  }
}
```

In `lib/main.dart`:
- replace the `stockCountRepositoryProvider.overrideWith((_) => SampleStockCountRepository()),` line with the block below;
- add imports for `dart:async`, `api_stock_count_repository.dart` and `sync_provider.dart` (already imported).
```dart
        stockCountRepositoryProvider.overrideWith(
          (ref) => client == null
              ? SampleStockCountRepository()
              : ApiStockCountRepository(
                  client: client,
                  db: database,
                  session: () => ref.read(authNotifierProvider).valueOrNull,
                  onQueued: () => unawaited(ref.read(syncCoordinatorProvider).syncNow()),
                ),
        ),
```

- [ ] **Step 5: Sessions with server ids**

In `lib/features/stock_count/providers/stock_count_provider.dart`:
- add `import 'package:uuid/uuid.dart';`;
- change `startSession` to `({required String location, String? label, String? locationId})`;
- create the session with `id: const Uuid().v4()` and `locationId: locationId`;
- pass `locationId: Value(session.locationId)` to the `CountSessionsCompanion.insert`;
- in `addItem`, pass `itemId: Value(item.itemId)` to `CountItemsCompanion.insert`;
- in `_itemFromDb`, add `itemId: data.itemId`.

In `lib/features/stock_count/providers/create_count_session_notifier.dart`:
- add `import 'package:uuid/uuid.dart';`;
- in `_getOrCreateDraftId`, replace `DateTime.now().millisecondsSinceEpoch.toString()` with `const Uuid().v4()`.

- [ ] **Step 6: The server-mode screens**

`lib/features/stock_count/presentation/count_setup_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/stock_count/providers/stock_count_provider.dart';

/// Server mode: a count is where you count, plus an optional label for the reviewer.
class CountSetupScreen extends ConsumerStatefulWidget {
  const CountSetupScreen({super.key});

  @override
  ConsumerState<CountSetupScreen> createState() => _CountSetupScreenState();
}

class _CountSetupScreenState extends ConsumerState<CountSetupScreen> {
  final _label = TextEditingController();
  String? _locationId;
  bool _submitted = false;
  bool _starting = false;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _submitted = true);
    final locations = ref.read(countLocationsProvider).valueOrNull ?? const [];
    final chosen = locations.where((l) => l.id == _locationId);
    if (chosen.isEmpty || _starting) return;
    setState(() => _starting = true);
    final label = _label.text.trim();
    await ref.read(stockCountNotifierProvider.notifier).startSession(
          location: chosen.first.code,
          label: label.isEmpty ? null : label,
          locationId: chosen.first.id,
        );
    if (mounted) context.pushReplacement(AppRoutes.stockCountScan);
  }

  Future<void> _refresh() async {
    await ref.read(syncCoordinatorProvider).syncNow();
    ref.invalidate(countLocationsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final locations = ref.watch(countLocationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Count Session')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Choose where you are counting. Everything you scan in this session is counted there.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
              ),
              const SizedBox(height: 16),
              locations.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text(
                  "Couldn't load the locations. Pull down to try again.",
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
                data: (items) => items.isEmpty
                    ? Text(
                        'No locations on this phone yet. Pull down to refresh, or ask a supervisor to add them.',
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: _locationId,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          errorText: _submitted && _locationId == null ? 'Choose where you are counting.' : null,
                        ),
                        items: [
                          for (final l in items) DropdownMenuItem(value: l.id, child: Text('${l.code} · ${l.kind}')),
                        ],
                        onChanged: (value) => setState(() => _locationId = value),
                      ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _label,
                maxLength: 120,
                decoration: const InputDecoration(labelText: 'Label (optional)', hintText: 'For example: Aisle A, front racks'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _starting ? null : _start,
                child: const Text('Start Counting'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

`lib/features/stock_count/presentation/count_item_picker_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/core/widgets/qty_adjuster.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';

final _searchProvider = FutureProvider.autoDispose.family<List<CatalogItemRef>, String>(
  (ref, term) => ref.watch(stockCountRepositoryProvider).searchItems(term),
);

/// Server mode: counting an item without a barcode means choosing it from the catalogue (no free-text items).
class CountItemPickerScreen extends ConsumerStatefulWidget {
  const CountItemPickerScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  ConsumerState<CountItemPickerScreen> createState() => _CountItemPickerScreenState();
}

class _CountItemPickerScreenState extends ConsumerState<CountItemPickerScreen> {
  late final TextEditingController _search = TextEditingController(text: widget.initialCode ?? '');
  late String _term = widget.initialCode ?? '';
  CatalogItemRef? _chosen;
  int _qty = 1;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final results = ref.watch(_searchProvider(_term));
    final chosen = _chosen;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Item')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _search,
                autofocus: true,
                onChanged: (value) => setState(() => _term = value),
                decoration: const InputDecoration(hintText: 'Search by SKU or name', prefixIcon: Icon(Icons.search)),
              ),
            ),
            Expanded(
              child: results.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text("Couldn't search the catalogue.")),
                data: (items) => items.isEmpty
                    ? Center(
                        child: Text(
                          'No item matches "$_term".',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) => ListTile(
                          title: Text(items[i].name, style: AppTextStyles.bodyMedium),
                          subtitle: Text(items[i].sku),
                          trailing: items[i].id == chosen?.id ? const Icon(Icons.check, color: AppColors.primary) : null,
                          onTap: () => setState(() {
                            _chosen = items[i];
                            _qty = 1;
                          }),
                        ),
                      ),
              ),
            ),
            if (chosen != null)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(chosen.name, style: AppTextStyles.title),
                    const SizedBox(height: 8),
                    QtyAdjuster(value: _qty, onChanged: (v) => setState(() => _qty = v)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _qty < 1
                          ? null
                          : () => context.pop(CountItem(
                                itemId: chosen.id,
                                itemCode: chosen.sku,
                                itemName: chosen.name,
                                expected: 0,
                                counted: _qty,
                                entryMethod: CountEntryMethod.typed,
                              )),
                      child: const Text('Add to Count'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

In `lib/core/router/app_router.dart`:
- import `../config/app_config.dart` and both new screens;
- change the `create` route's builder to `(_, __) => ref.read(useApiProvider) ? const CountSetupScreen() : const CreateCountSessionScreen(),`;
- change the `manual-entry` route's builder to:
```dart
                        builder: (_, state) => ref.read(useApiProvider)
                            ? CountItemPickerScreen(initialCode: state.extra as String?)
                            : CountManualEntryScreen(initialCode: state.extra as String?),
```

In `lib/features/stock_count/presentation/scan_count_screen.dart`:
- change `({String code, String name})? _scanned;` to `({String itemId, String code, String name})? _scanned;`;
- in `_onDetect`, rename `final name = await ref…lookupItemByBarcode(code);` to `final found = await …;`, test `if (found == null)`, and set `_scanned = (itemId: found.id, code: found.sku, name: found.name);`;
- in `_confirmItem`, add `itemId: item.itemId,` to the `CountItem(…)`.

In `lib/features/stock_count/presentation/review_count_screen.dart`:
- blind counts have nothing to compare against, so in the item row replace the trailing `Column(children: [Text('${item.counted}', …color: color), Text(item.variance …)])` with:
```dart
                        Text(
                          '${item.counted}',
                          style: AppTextStyles.title.copyWith(color: AppColors.textPrimary(brightness)),
                        ),
```
- delete the now-unused `final color = …;`;
- in the submit `onPressed`, after `submitSession()` succeeds and before `context.go`, add:
```dart
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ref.read(isOnlineProvider)
                            ? 'Count sent for review.'
                            : "Count saved. It will be sent when you're back online."),
                      ));
                    }
```
- import `../../../core/providers/connectivity_provider.dart`.

In `lib/features/stock_count/presentation/start_count_screen.dart`:
- import `../../../core/models/count_records.dart`, `../../../data/repositories/stock_count_repository.dart` and `../../../data/sync/sync_provider.dart`;
- wrap the body's `ListView` in a `RefreshIndicator`:
```dart
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(syncCoordinatorProvider).syncNow();
            ref.invalidate(recentCountsProvider);
          },
          child: ListView( /* as before */ ),
        ),
```
- add `const SizedBox(height: 16), const _RecentCounts(),` as the last children of the `ListView`;
- add at the end of the file:
```dart
class _RecentCounts extends ConsumerWidget {
  const _RecentCounts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final recent = ref.watch(recentCountsProvider).valueOrNull ?? const <CountSummary>[];
    if (recent.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent counts', style: AppTextStyles.title),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (final count in recent)
                ListTile(
                  title: Text(count.title, style: AppTextStyles.bodyMedium),
                  subtitle: Text(
                    [
                      '${count.lineCount} ${count.lineCount == 1 ? 'item' : 'items'}',
                      if (count.note != null) count.note!,
                    ].join(' · '),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary(brightness)),
                  ),
                  trailing: _ProgressLabel(count.progress),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel(this.progress);

  final CountProgress progress;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (progress) {
      CountProgress.sending => ('Waiting to send', AppColors.warning),
      CountProgress.notAccepted => ('Not accepted', AppColors.error),
      CountProgress.waitingReview => ('Waiting for review', AppColors.warning),
      CountProgress.approved => ('Approved', AppColors.success),
      CountProgress.rejected => ('Rejected', AppColors.error),
    };
    return Text(text, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600));
  }
}
```

- [ ] **Step 7: Regenerate and run every check**

```bash
$F pub run build_runner build --delete-conflicting-outputs
$F test && $F analyze lib test
```
Expected: the 3 repository tests, the 2 provider tests and the setup-screen test PASS; everything else PASSES; analyze clean. If a test elsewhere used `lookupItemByBarcode` returning a `String`, or `getRecentSessions`, update it to the new types and record a ruling.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat(stock-count): count against the server's catalogue and queue finished counts for review"
```

---

### Task 6: Reviewing counts on the phone

**Files:**
- Create: `lib/features/supervisor/screens/count_review_screen.dart`
- Modify: `lib/data/repositories/stock_count_repository.dart`, `lib/data/api/api_stock_count_repository.dart`, `lib/data/sample/sample_stock_count_repository.dart`, `lib/features/supervisor/providers/pending_review_provider.dart`, `lib/features/supervisor/screens/pending_review_screen.dart`, `lib/core/router/app_router.dart`
- Test: `test/data/api/api_stock_count_repository_test.dart` (extend), `test/features/supervisor/supervisor_notifiers_test.dart` (pending-review group replaced), `test/features/supervisor/count_review_screen_test.dart`

**Interfaces:**
- Consumes: the Task 5 repository, the `SyncOps` commands, `AppRoutes.pendingReviewDetail` (Task 3).
- Produces:
  - `StockCountRepository` methods:
    - `getCountsToReview() → List<CountSummary>`;
    - `getCountReview(id) → CountReview` (online);
    - `approveCount(id)`, `rejectCount(id, reason)`.
  - `pendingReviewProvider` (`AsyncNotifier<List<CountSummary>>`), `countReviewProvider(id)` and `CountReviewScreen(sessionId)`.

- [ ] **Step 1: Write the failing tests**

Append to `test/data/api/api_stock_count_repository_test.dart`:
```dart
  test('counts to review come from the phone copy, minus ones already decided on this phone', () async {
    final counts = await repo();
    for (final id in ['c1', 'c2']) {
      await db.serverMirrorDao.upsertCountSession(
        RemoteCountSessionsCompanion.insert(id: id, warehouseId: w, createdByUserId: 'someone', label: Value('Aisle $id'), status: 'Submitted', submittedAt: DateTime(2026, 10, 11)),
        [],
      );
    }

    await counts.approveCount('c1');

    expect((await counts.getCountsToReview()).map((c) => c.id), ['c2']);
    final queued = (await db.syncQueueDao.getPendingItems()).single;
    expect(queued.operationType, SyncOps.countApprove);
    expect(queued.referenceId, 'c1');
  });

  test('a rejection is queued with its reason', () async {
    final counts = await repo();

    await counts.rejectCount('c1', 'Count the back row too');

    final queued = (await db.syncQueueDao.getPendingItems()).single;
    expect(queued.operationType, SyncOps.countReject);
    expect(jsonDecode(queued.payload), {'reason': 'Count the back row too'});
  });

  test('the review shows each line and how many bins moved since the count', () async {
    final counts = await repo((r) async => jsonResponse({
          'id': 'c1', 'label': 'Aisle A', 'createdByUserId': 'u2', 'createdByName': 'Arjun Nair', 'status': 'Submitted',
          'submittedAt': '2026-10-11T00:12:00Z', 'reviewedByUserId': null, 'reviewedAt': null, 'rejectReason': null,
          'lines': [
            {'id': 'l1', 'itemId': beras, 'sku': 'WT-0001', 'itemName': 'Beras Wangi 10kg', 'locationId': bin, 'locationCode': 'A-01-01',
             'counted': 8, 'systemAtSubmit': 10, 'current': 9, 'difference': -2, 'adjustment': null},
          ],
        }));

    final review = await counts.getCountReview('c1');

    expect(review.countedBy, 'Arjun Nair');
    expect(review.lines.single.difference, -2);
    expect(review.movedLines, 1);
  });
```

In `test/features/supervisor/supervisor_notifiers_test.dart`, replace the `PendingReviewNotifier` group with:
```dart
  group('PendingReviewNotifier', () {
    test('loads the counts waiting for review', () async {
      final mockRepo = MockStockCountRepository();
      when(() => mockRepo.getCountsToReview()).thenAnswer((_) async => const [
            CountSummary(id: 'c1', title: 'Aisle A', lineCount: 2, progress: CountProgress.waitingReview),
          ]);
      final container = ProviderContainer(overrides: [stockCountRepositoryProvider.overrideWithValue(mockRepo)]);
      addTearDown(container.dispose);

      final reviews = await container.read(pendingReviewProvider.future);

      expect(reviews.single.title, 'Aisle A');
    });
  });
```
Add `class MockStockCountRepository extends Mock implements StockCountRepository {}` and the imports for `count_records.dart` and `stock_count_repository.dart`. Remove `MockAlertsRepository` and the `alert.dart`/`alerts_repository.dart` imports if nothing else in the file uses them.

`test/features/supervisor/count_review_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/features/supervisor/screens/count_review_screen.dart';

class MockStockCountRepository extends Mock implements StockCountRepository {}

void main() {
  testWidgets('rejecting needs a reason, then queues it', (tester) async {
    final repo = MockStockCountRepository();
    when(() => repo.getCountReview('c1')).thenAnswer((_) async => CountReview(
          id: 'c1',
          title: 'Aisle A',
          countedBy: 'Arjun Nair',
          submittedAt: DateTime(2026, 10, 11, 8, 12),
          status: 'Submitted',
          lines: const [
            CountReviewLine(itemName: 'Beras Wangi 10kg', sku: 'WT-0001', locationCode: 'A-01-01', counted: 8, systemAtSubmit: 10, current: 9, difference: -2),
          ],
        ));
    when(() => repo.rejectCount('c1', any())).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [stockCountRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: AppTheme.light, home: const CountReviewScreen(sessionId: 'c1')),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Beras Wangi 10kg'), findsOneWidget);
    expect(find.text('Stock moved in 1 bin since this count.'), findsOneWidget);

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reject Count'));
    await tester.pumpAndSettle();
    expect(find.text('Say why, so the counter knows what to recount.'), findsOneWidget);
    verifyNever(() => repo.rejectCount(any(), any()));

    await tester.enterText(find.byType(TextField), 'Count the back row too');
    await tester.tap(find.text('Reject Count'));
    await tester.pumpAndSettle();

    verify(() => repo.rejectCount('c1', 'Count the back row too')).called(1);
  });
}
```

- [ ] **Step 2: Run them to verify they fail**

Run: `$F test test/data/api/api_stock_count_repository_test.dart test/features/supervisor`
Expected: FAIL — compile errors: `approveCount`, `getCountReview`, `CountReviewScreen` and `getCountsToReview` don't exist.

- [ ] **Step 3: The repository side**

Add to `StockCountRepository` (`lib/data/repositories/stock_count_repository.dart`):
```dart
  /// Submitted counts in the current warehouse that nobody has decided on yet (supervisors).
  Future<List<CountSummary>> getCountsToReview();

  /// The count with live stock figures. Needs a connection.
  Future<CountReview> getCountReview(String sessionId);

  Future<void> approveCount(String sessionId);

  Future<void> rejectCount(String sessionId, String reason);
```

Add to `ApiStockCountRepository`:
```dart
  @override
  Future<List<CountSummary>> getCountsToReview() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final decided = {
      for (final op in [SyncOps.countApprove, SyncOps.countReject])
        for (final item in await _db.syncQueueDao.itemsFor(op)) item.referenceId,
    };
    return [
      for (final row in await _db.serverMirrorDao.countSessions(warehouseId: warehouseId, status: 'Submitted', limit: 100))
        if (!decided.contains(row.id))
          CountSummary(
            id: row.id,
            title: row.label ?? 'Count',
            lineCount: (await _db.serverMirrorDao.linesFor(row.id)).length,
            progress: CountProgress.waitingReview,
            submittedAt: row.submittedAt,
          ),
    ];
  }

  @override
  Future<CountReview> getCountReview(String sessionId) async {
    final warehouseId = _session()?.warehouseId;
    final json = await _client.get('/warehouses/$warehouseId/count-reviews/$sessionId') as Map<String, dynamic>;
    return CountReview(
      id: json['id'] as String,
      title: json['label'] as String? ?? 'Count',
      countedBy: json['createdByName'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String).toLocal(),
      status: json['status'] as String,
      lines: [
        for (final l in (json['lines'] as List).cast<Map<String, dynamic>>())
          CountReviewLine(
            itemName: l['itemName'] as String,
            sku: l['sku'] as String,
            locationCode: l['locationCode'] as String,
            counted: (l['counted'] as num).toDouble(),
            systemAtSubmit: (l['systemAtSubmit'] as num).toDouble(),
            current: (l['current'] as num).toDouble(),
            difference: (l['difference'] as num).toDouble(),
          ),
      ],
    );
  }

  @override
  Future<void> approveCount(String sessionId) => _decide(SyncOps.countApprove, sessionId, const {});

  @override
  Future<void> rejectCount(String sessionId, String reason) => _decide(SyncOps.countReject, sessionId, {'reason': reason});

  Future<void> _decide(String op, String sessionId, Map<String, Object?> body) async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) throw StateError('No warehouse chosen.');
    await _db.syncQueueDao.enqueue(operationType: op, referenceId: sessionId, warehouseId: warehouseId, payload: jsonEncode(body));
    _onQueued();
  }
```

Add to `SampleStockCountRepository`:
```dart
  final List<CountSummary> _toReview = [
    CountSummary(id: 'sample-review-1', title: 'Aisle C', lineCount: 3, progress: CountProgress.waitingReview, submittedAt: DateTime(2026, 4, 18, 9)),
  ];

  @override
  Future<List<CountSummary>> getCountsToReview() async => List.unmodifiable(_toReview);

  @override
  Future<CountReview> getCountReview(String sessionId) async => CountReview(
        id: sessionId,
        title: 'Aisle C',
        countedBy: 'John Doe',
        submittedAt: DateTime(2026, 4, 18, 9),
        status: 'Submitted',
        lines: const [
          CountReviewLine(itemName: 'Steel Bolt M8', sku: 'WH-00089', locationCode: 'Aisle C', counted: 40, systemAtSubmit: 42, current: 42, difference: -2),
          CountReviewLine(itemName: 'Copper Wire 4mm', sku: 'WH-00210', locationCode: 'Aisle C', counted: 12, systemAtSubmit: 12, current: 12, difference: 0),
        ],
      );

  @override
  Future<void> approveCount(String sessionId) async => _toReview.removeWhere((c) => c.id == sessionId);

  @override
  Future<void> rejectCount(String sessionId, String reason) async => _toReview.removeWhere((c) => c.id == sessionId);
```

- [ ] **Step 4: The screens**

Replace `lib/features/supervisor/providers/pending_review_provider.dart` with:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';

class PendingReviewNotifier extends AsyncNotifier<List<CountSummary>> {
  @override
  Future<List<CountSummary>> build() => ref.watch(stockCountRepositoryProvider).getCountsToReview();

  /// Sends anything queued, pulls the latest counts, then reloads.
  Future<void> refresh() async {
    await ref.read(syncCoordinatorProvider).syncNow();
    ref.invalidateSelf();
  }
}

final pendingReviewProvider = AsyncNotifierProvider<PendingReviewNotifier, List<CountSummary>>(PendingReviewNotifier.new);

final countReviewProvider = FutureProvider.autoDispose.family<CountReview, String>(
  (ref, sessionId) => ref.watch(stockCountRepositoryProvider).getCountReview(sessionId),
);
```

In `lib/features/supervisor/screens/pending_review_screen.dart`:
- replace the `alert.dart` import with `package:warehouse_app/core/models/count_records.dart`;
- change `_ReviewCard(alert: reviews[i], ref: ref)` to `_ReviewCard(count: reviews[i])`;
- replace the whole `_ReviewCard` class with the one below, which keeps the card styling:
```dart
class _ReviewCard extends StatelessWidget {
  final CountSummary count;

  const _ReviewCard({required this.count});

  @override
  Widget build(BuildContext context) {
    final secondaryText = AppColors.textSecondary(Theme.of(context).brightness);
    final submitted = count.submittedAt == null ? null : MaterialLocalizations.of(context).formatMediumDate(count.submittedAt!);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(count.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              [
                '${count.lineCount} ${count.lineCount == 1 ? 'item' : 'items'} counted',
                if (submitted != null) 'submitted $submitted',
              ].join(' · '),
              style: AppTextStyles.bodySmall.copyWith(color: secondaryText),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.pendingReviewDetail, extra: count.id),
                child: const Text('Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

`lib/features/supervisor/screens/count_review_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/features/supervisor/providers/pending_review_provider.dart';

/// A submitted count with live stock figures. Approve applies each difference on top of what is there now;
/// reject sends the counter a reason. Both are queued commands, so they also work offline.
class CountReviewScreen extends ConsumerWidget {
  const CountReviewScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(countReviewProvider(sessionId));
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Count')),
      body: review.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Couldn't load this count. Reviewing needs a connection.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary(brightness)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: () => ref.invalidate(countReviewProvider(sessionId)), child: const Text('Try Again')),
              ],
            ),
          ),
        ),
        data: (count) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(count.title, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    'Counted by ${count.countedBy} · ${MaterialLocalizations.of(context).formatMediumDate(count.submittedAt)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary(brightness)),
                  ),
                  if (count.movedLines > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Stock moved in ${count.movedLines} ${count.movedLines == 1 ? 'bin' : 'bins'} since this count.',
                      style: AppTextStyles.body.copyWith(color: AppColors.warning),
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final line in count.lines)
                    Card(
                      child: ListTile(
                        title: Text(line.itemName, style: AppTextStyles.bodyMedium),
                        subtitle: Text('${line.sku} · ${line.locationCode}\nCounted ${formatQty(line.counted)} · system ${formatQty(line.systemAtSubmit)} · now ${formatQty(line.current)}'),
                        isThreeLine: true,
                        trailing: Text(
                          line.difference > 0 ? '+${formatQty(line.difference)}' : formatQty(line.difference),
                          style: AppTextStyles.title.copyWith(
                            color: line.difference == 0 ? AppColors.textSecondary(brightness) : AppColors.textPrimary(brightness),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (count.status == 'Submitted')
              SafeArea(
                top: false,
                minimum: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        onPressed: () => _reject(context, ref),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(onPressed: () => _approve(context, ref, count), child: const Text('Approve')),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref, CountReview count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve this count?'),
        content: Text(
          "Stock in ${count.changingLines} ${count.changingLines == 1 ? 'bin' : 'bins'} changes by the differences shown. This can't be undone; a later count corrects it.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Approve Count')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(stockCountRepositoryProvider).approveCount(sessionId);
    if (!context.mounted) return;
    _done(context, ref, 'Approval sent.');
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _RejectDialog());
    if (reason == null) return;
    await ref.read(stockCountRepositoryProvider).rejectCount(sessionId, reason);
    if (!context.mounted) return;
    _done(context, ref, 'Rejection sent.');
  }

  void _done(BuildContext context, WidgetRef ref, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    ref.invalidate(pendingReviewProvider);
    if (context.canPop()) context.pop();
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Say why, so the counter knows what to recount.');
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Reject this count?'),
        content: TextField(
          controller: _reason,
          maxLength: 500,
          maxLines: 3,
          decoration: InputDecoration(labelText: 'Reason', errorText: _error),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: _submit, child: const Text('Reject Count')),
        ],
      );
}
```

In `lib/core/router/app_router.dart`, import the screen and add after the `AppRoutes.pendingReview` route:
```dart
      GoRoute(
        path: AppRoutes.pendingReviewDetail,
        builder: (_, state) => CountReviewScreen(sessionId: state.extra as String),
      ),
```

- [ ] **Step 5: Run every check**

Run: `$F test && $F analyze lib test`
Expected: the 3 new repository tests, the replaced notifier test and the review-screen test PASS; everything else PASSES; analyze clean.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(supervisor): review, approve and reject counts from the phone"
```

---

### Task 7: Biometric unlock

**Files:**
- Create: `lib/core/biometrics.dart`
- Modify: `lib/features/profile/providers/profile_provider.dart`, `lib/features/profile/screens/profile_screen.dart`, `lib/core/providers/auth_provider.dart`, `lib/core/router/auth_redirect.dart`, `lib/core/router/app_router.dart`, `lib/features/auth/presentation/login_screen.dart`, `lib/main.dart`
- Test: `test/core/router/auth_redirect_test.dart` (extend), `test/features/profile/profile_notifier_test.dart` (update), `test/features/auth/login_screen_test.dart` (extend)

**Interfaces:**
- Consumes: `KeyValueStore`/`MemoryKeyValueStore` (Task 1), `authRedirect` (Task 3).
- Produces:
  - `BiometricAuth` (`canCheck`, `authenticate(reason)`) and `biometricAuthProvider`.
  - `settingsStoreProvider` (a `KeyValueStore`) and `biometricPreferenceProvider` (`bool`, the launch value).
  - `lockedSessionProvider` (`StateProvider<UserSession?>`).
  - `AuthNotifier.unlock()`.
  - `ProfileSettingsNotifier.toggleBiometric() → Future<bool>`.
  - `authRedirect(…, locked:)`.

- [ ] **Step 1: Write the failing tests**

Append to `test/core/router/auth_redirect_test.dart`:
```dart
  test('a locked session waits on the sign-in screen for a fingerprint', () {
    final locked = session(warehouseId: 'sa1', warehouses: [sa1]);
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.dashboard, locked: locked), AppRoutes.login);
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.welcome, locked: locked), AppRoutes.login);
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.login, locked: locked), isNull);
  });
```

Replace the test in `test/features/profile/profile_notifier_test.dart` with:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/biometrics.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/features/profile/providers/profile_provider.dart';

class FakeBiometrics implements BiometricAuth {
  FakeBiometrics({this.available = true, this.approves = true});

  final bool available;
  final bool approves;

  @override
  Future<bool> canCheck() async => available;

  @override
  Future<bool> authenticate(String reason) async => approves;
}

void main() {
  test('biometric login turns on after a fingerprint, is remembered, and turns off', () async {
    final store = MemoryKeyValueStore();
    final container = ProviderContainer(overrides: [
      biometricAuthProvider.overrideWithValue(FakeBiometrics()),
      settingsStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    final notifier = container.read(profileSettingsProvider.notifier);

    expect(await notifier.toggleBiometric(), isTrue);
    expect(container.read(profileSettingsProvider).biometricEnabled, isTrue);
    expect(store.values['settings.biometric'], 'true');

    expect(await notifier.toggleBiometric(), isTrue);
    expect(container.read(profileSettingsProvider).biometricEnabled, isFalse);
    expect(store.values['settings.biometric'], 'false');
  });

  test('a phone without biometrics keeps it off', () async {
    final container = ProviderContainer(overrides: [
      biometricAuthProvider.overrideWithValue(FakeBiometrics(available: false)),
      settingsStoreProvider.overrideWithValue(MemoryKeyValueStore()),
    ]);
    addTearDown(container.dispose);

    expect(await container.read(profileSettingsProvider.notifier).toggleBiometric(), isFalse);
    expect(container.read(profileSettingsProvider).biometricEnabled, isFalse);
  });
}
```
If the file has other tests (dark mode, notifications, haptics), keep them and only replace the biometric one.

Append to `test/features/auth/login_screen_test.dart`:
```dart
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
```
Add imports for `core/biometrics.dart`, `core/models/user_session.dart` and `core/providers/auth_provider.dart`. Add a `FakeBiometrics` class that implements `BiometricAuth` and approves.

- [ ] **Step 2: Run them to verify they fail**

Run: `$F test test/core/router test/features/profile test/features/auth`
Expected: FAIL — compile errors: `BiometricAuth`, `settingsStoreProvider`, `lockedSessionProvider` and the `locked:` parameter don't exist.

- [ ] **Step 3: Implement**

`lib/core/biometrics.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Fingerprint or face check, wrapped so tests can stand in for the phone.
class BiometricAuth {
  BiometricAuth([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> canCheck() async => await _auth.canCheckBiometrics && await _auth.isDeviceSupported();

  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, options: const AuthenticationOptions(biometricOnly: true));
    } on Exception {
      return false; // cancelled, locked out, or not enrolled
    }
  }
}

final biometricAuthProvider = Provider<BiometricAuth>((_) => BiometricAuth());
```

In `lib/features/profile/providers/profile_provider.dart`:
- add the imports `package:warehouse_app/core/biometrics.dart` and `package:warehouse_app/data/api/key_value_store.dart`;
- add above the notifier:
```dart
/// Settings kept between launches. main.dart overrides it with secure storage.
final settingsStoreProvider = Provider<KeyValueStore>((_) => MemoryKeyValueStore());

/// Whether biometric login was on when the app started (read in main.dart).
final biometricPreferenceProvider = Provider<bool>((_) => false);
```
- change `build()` to `ProfileSettings build() => ProfileSettings(biometricEnabled: ref.read(biometricPreferenceProvider));`;
- replace `toggleBiometric` with:
```dart
  /// Turning it on asks for a fingerprint first, so nobody switches it on for a phone that can't check one.
  /// Returns false when that check is unavailable or fails.
  Future<bool> toggleBiometric() async {
    final turningOn = !state.biometricEnabled;
    if (turningOn) {
      final biometrics = ref.read(biometricAuthProvider);
      if (!await biometrics.canCheck() || !await biometrics.authenticate('Turn on biometric login for WareTrack')) return false;
    }
    await ref.read(settingsStoreProvider).write('settings.biometric', '$turningOn');
    state = state.copyWith(biometricEnabled: turningOn);
    return true;
  }
```

In `lib/features/profile/screens/profile_screen.dart`, change the biometric switch's `onChanged` to:
```dart
            onChanged: (_) async {
              final ok = await notifier.toggleBiometric();
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Biometric login needs a fingerprint or face set up on this phone.")),
                );
              }
            },
```

In `lib/core/providers/auth_provider.dart`, add:
```dart
/// A stored session waiting for a fingerprint (biometric login on). main.dart sets it at launch.
final lockedSessionProvider = StateProvider<UserSession?>((_) => null);
```
And add this to `AuthNotifier`:
```dart
  /// Opens the locked session after a successful fingerprint.
  void unlock() {
    final locked = ref.read(lockedSessionProvider);
    if (locked == null) return;
    ref.read(lockedSessionProvider.notifier).state = null;
    state = AsyncData(locked);
  }
```
In `login`, after the `state = await AsyncValue.guard(…)` line add `if (state.hasValue && state.value != null) ref.read(lockedSessionProvider.notifier).state = null;`. A password sign-in also unlocks.

In `lib/core/router/auth_redirect.dart`, add the parameter `UserSession? locked` and, right after the `isLoading` line:
```dart
  if (auth.valueOrNull == null && locked != null) return location == AppRoutes.login ? null : AppRoutes.login;
```
In `lib/core/router/app_router.dart`:
- pass `locked: _ref.read(lockedSessionProvider)` to `authRedirect`;
- in the `_RouterNotifier` constructor, also listen to the lock: `_lockSub = _ref.listen(lockedSessionProvider, (_, __) => notifyListeners());`;
- declare `late final ProviderSubscription<UserSession?> _lockSub;` and close it in `dispose`.

In `lib/features/auth/presentation/login_screen.dart`:
- add the imports `package:warehouse_app/core/biometrics.dart`;
- add `initState`:
```dart
  @override
  void initState() {
    super.initState();
    // Biometric login is on and a session is stored: ask straight away.
    if (ref.read(lockedSessionProvider) != null) Future.microtask(_biometricSignIn);
  }
```
- replace the body of `_biometricSignIn` with:
```dart
    final messenger = ScaffoldMessenger.of(context);
    if (ref.read(lockedSessionProvider) == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Sign in with your password, then turn on biometric login in Profile.')));
      return;
    }
    if (await ref.read(biometricAuthProvider).authenticate('Unlock WareTrack')) {
      ref.read(authNotifierProvider.notifier).unlock();
    }
```

In `lib/main.dart`:
- after `initialSession` is read, add:
```dart
  final settingsStore = SecureKeyValueStore(storage);
  final biometricOn = await settingsStore.read('settings.biometric') == 'true';
  final locked = biometricOn && initialSession != null; // ask for a fingerprint before opening a stored session
```
- change the bootstrap override to `AuthBootstrapState.hydrated(locked ? null : initialSession)`;
- add these overrides:
```dart
        settingsStoreProvider.overrideWithValue(settingsStore),
        biometricPreferenceProvider.overrideWithValue(biometricOn),
        lockedSessionProvider.overrideWith((_) => locked ? initialSession : null),
```

- [ ] **Step 4: Run every check**

Run: `$F test && $F analyze lib test`
Expected: the new redirect, profile and login tests PASS; the existing "renders biometric button with label" test still PASSES; everything else PASSES; analyze clean.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(auth): unlock a stored session with a fingerprint when biometric login is on"
```

---

### Task 8: End to end against a local server

**Files:**
- Create: `test/live/api_counts_live_test.dart`, `dart_test.yaml`

**Interfaces:**
- Consumes: everything above; the server's dev seed (SA1; `arjun` worker, `hafiz` supervisor; items `WT-0001`…; bins in SA1; password `Waretrack#2026` unless `WARETRACK_SEED_PASSWORD` is set).
- Produces: a live test, skipped unless `WARETRACK_API` is set: "a worker's count reaches the server and a supervisor approves it from a phone".

- [ ] **Step 1: Write the test**

`dart_test.yaml`:
```yaml
tags:
  live:
    # Needs a running WareTrack API: WARETRACK_API=http://localhost:5050 flutter test test/live
```

`test/live/api_counts_live_test.dart`:
```dart
@Tags(['live'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_stock_count_repository.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final api = Platform.environment['WARETRACK_API'];
final password = Platform.environment['WARETRACK_SEED_PASSWORD'] ?? 'Waretrack#2026';

/// One phone: its own database, tokens and outbox.
class Phone {
  Phone._(this.db, this.client, this.auth);

  static Phone create() {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final client = ApiClient(baseUrl: api!, httpClient: http.Client(), tokens: TokenStore(MemoryKeyValueStore()));
    return Phone._(db, client, ApiAuthRepository(client: client, db: db));
  }

  final AppDatabase db;
  final ApiClient client;
  final ApiAuthRepository auth;
  late UserSession session;

  late final counts = ApiStockCountRepository(client: client, db: db, session: () => session, onQueued: () {});
  late final outbox = SyncService(db: db, sender: CommandSender(client));
  late final puller = ChangeFeedPuller(client: client, db: db);

  Future<void> signIn(String email) async {
    session = await auth.login(email, password);
    if (session.warehouseId == null) {
      session = await auth.selectWarehouse(session, session.warehouses.firstWhere((w) => w.code == 'SA1').warehouseId);
    }
    await puller.pull(session.warehouseId!);
  }

  Future<void> sync() async {
    expect(await outbox.flushQueue(), FlushOutcome.done);
    await puller.pull(session.warehouseId!);
  }
}

void main() {
  test("a worker's count reaches the server and a supervisor approves it from a phone", () async {
    final worker = Phone.create();
    final supervisor = Phone.create();
    addTearDown(() async {
      await worker.db.close();
      await supervisor.db.close();
    });

    await worker.signIn('arjun@waretrack.local');
    final item = (await worker.counts.searchItems('WT-0001')).single;
    final bin = (await worker.counts.getLocations()).firstWhere((l) => l.kind == 'Bin');
    final countId = const Uuid().v4();
    await worker.counts.submitSession(CountSession(
      id: countId,
      location: bin.code,
      locationId: bin.id,
      label: 'Phone live test ${DateTime.now().toIso8601String()}',
      startedAt: DateTime.now(),
      status: CountSessionStatus.inProgress,
      items: [CountItem(itemId: item.id, itemCode: item.sku, itemName: item.name, expected: 0, counted: 49)],
    ));
    await worker.sync();
    expect((await worker.db.serverMirrorDao.countSessions(warehouseId: worker.session.warehouseId!)).map((s) => s.id), contains(countId));

    await supervisor.signIn('hafiz@waretrack.local');
    expect((await supervisor.counts.getCountsToReview()).map((c) => c.id), contains(countId));
    final review = await supervisor.counts.getCountReview(countId);
    expect(review.lines.single.counted, 49);
    await supervisor.counts.approveCount(countId);
    await supervisor.sync();

    await worker.sync();
    final mine = (await worker.counts.getRecentCounts()).firstWhere((c) => c.id == countId);
    expect(mine.progress.name, 'approved');
  }, skip: api == null ? 'Set WARETRACK_API=http://localhost:5050 (with the server running) to run this.' : false);
}
```

- [ ] **Step 2: Run it against the local stack**

```bash
cd ~/projects/Personal/DotNet/waretrack-server
docker compose -f deploy/docker-compose.dev.yml up -d
(DOTNET_ROOT=~/.dotnet PATH=~/.dotnet:$PATH dotnet run --project src/WareTrack.Api --launch-profile http > /tmp/waretrack-api.log 2>&1 &)
until curl -fsS http://localhost:5050/health >/dev/null; do sleep 2; done
cd ~/projects/Personal/Flutter/warehouse_app/.worktrees/api-integration
WARETRACK_API=http://localhost:5050 $F test test/live
$F test
pkill -f "WareTrack.Api"; docker compose -f ~/projects/Personal/DotNet/waretrack-server/deploy/docker-compose.dev.yml stop
```
Expected:
- the live test PASSES;
- the plain `$F test` run shows it as skipped, and everything else PASSES.

The test signs in twice, well under the server's limit of 10 sign-ins a minute.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "test: prove a phone count reaching the server and a supervisor approving it from a phone"
```

---

## Self-Review Notes

- **Spec coverage (3a part):**
  - §6 `Api*Repository` beside `Sample*`, chosen by build configuration → Tasks 3 and 5 (auth, stock counts).
  - `SyncService._processItem` sends real commands with the response table → Task 4.
  - Refresh on 401 → Task 1.
  - IDs become GUIDs → Task 5 (count sessions). Order IDs are 3b.
  - Device-token registration and push → 3c.
  - §3 change feed with a cursor → Task 2.
  - Online barcode lookup → Task 5.
  - Commands with `Idempotency-Key` and FIFO order → Task 4.
  - Supervisor review of submitted counts → Task 6.
  - Biometric login → Task 7.
- **Plan 3 decisions:**
  - Server mode drops count deadline, assignee and zone. The new setup screen and item picker are used only in server mode; Sample mode keeps the existing screens.
  - Sample mode stays the default build.
- **Consistency:**
  - `SyncOps` (Task 4) is used by the API repository (Tasks 5–6).
  - `itemsFor` (Task 4) is used by recent counts and the review list.
  - `AppRoutes.pendingReviewDetail` is defined in Task 3, before Task 6 routes to it.
  - `useApiProvider` (Task 1) is read by the router (Task 5) and the sync providers (Task 4).
  - `clearServerData` (Task 2) is used by sign-out (Task 3).
  - Drift rows end in `Row`, avoiding the `CatalogItem` model in `order.dart`.
- **Deferred to 3b and 3c:**
  - receiving with signatures, delivery and sales orders (int ID → GUID), tasks, alerts;
  - decimal quantity entry;
  - 3b's migration must reset `sync_cursors`;
  - push notifications and device tokens (3c, needs a Firebase project);
  - the scan screen's session-info dialog still shows "Unassigned / No deadline" in server mode (harmless; polish in 3b).
