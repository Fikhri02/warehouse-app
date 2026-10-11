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
