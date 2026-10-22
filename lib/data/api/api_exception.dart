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
    return title ?? 'Atura refused this (HTTP $status).';
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
  String toString() => "Couldn't reach Atura. Check your connection and try again.";
}

/// The refresh token was refused: the person has to sign in again.
class SessionExpiredException implements Exception {
  const SessionExpiredException();

  @override
  String toString() => 'Your session has ended. Sign in again.';
}
