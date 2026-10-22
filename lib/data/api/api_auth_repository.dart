import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/local/app_database.dart' show AppDatabase; // its generated UserSession row clashes with the model
import 'package:warehouse_app/data/repositories/auth_repository.dart';

import 'api_client.dart';
import 'api_exception.dart';
import 'token_store.dart';

export 'package:warehouse_app/data/repositories/auth_repository.dart' show AuthFailure;

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
      throw const AuthFailure("Couldn't reach Atura. Check your connection and try again.");
    }
    final user = json['user'] as Map<String, dynamic>;
    final session = _sessionFrom(user, json['accessToken'] as String, await _tokens.readWarehouseId());
    if (session.warehouses.isEmpty) {
      throw const AuthFailure("Your account isn't part of any warehouse yet. Ask an administrator to add you to one.");
    }
    // Someone else's queued commands and copy must never go out under this account.
    final previous = await _tokens.readUser();
    if (previous == null || previous['id'] != user['id']) await _db.clearServerData();
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
      await _db.clearServerData(); // nothing of theirs is left for the next person to send
      return null;
    } on ApiOfflineException {
      // Keep working offline with what was stored.
    } on ApiException {
      // Server trouble: the same.
    }
    final user = await _tokens.readUser();
    if (user == null) {
      await _tokens.clear();
      await _db.clearServerData();
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
