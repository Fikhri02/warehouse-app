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
      return response.body.isEmpty ? null : _decode(response.body);
    }
    throw ApiException.fromResponse(response.statusCode, response.body);
  }

  Future<void> _refresh() async {
    final refreshToken = await _tokens.refreshToken;
    if (refreshToken == null) throw const SessionExpiredException();
    final response = await _raw('POST', '/auth/refresh', null, {'refreshToken': refreshToken}, null, false);
    if (response.statusCode == 200) {
      final json = _decode(response.body) as Map<String, dynamic>;
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

  /// A 2xx that is not JSON (a captive portal's login page, a misconfigured proxy) is treated as server trouble:
  /// the outbox pauses and tries again later instead of crashing.
  static dynamic _decode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const ApiException(status: 502, title: 'WareTrack sent an answer this app cannot read.');
    }
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
    } on IOException catch (e) {
      // Sockets, TLS handshakes, HTTP protocol errors: the server was not properly reached.
      throw ApiOfflineException(e);
    } on TimeoutException catch (e) {
      throw ApiOfflineException(e);
    } on http.ClientException catch (e) {
      throw ApiOfflineException(e);
    }
  }
}
