import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login(String email, String password);
  Future<UserSession?> getStoredSession();
  Future<void> storeSession(UserSession session);
  Future<void> clearSession();

  /// The session as it is in [warehouseId]: its name and the person's role there.
  Future<UserSession> selectWarehouse(UserSession session, String warehouseId);
}

/// A sign-in the person can do something about. [message] is shown as is.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('authRepositoryProvider not overridden');
});
