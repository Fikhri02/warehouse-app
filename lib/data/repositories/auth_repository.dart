import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login(String email, String password);
  Future<UserSession?> getStoredSession();
  Future<void> storeSession(UserSession session);
  Future<void> clearSession();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('authRepositoryProvider not overridden');
});
