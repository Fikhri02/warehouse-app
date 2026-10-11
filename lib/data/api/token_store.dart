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
