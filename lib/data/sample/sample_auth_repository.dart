import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';

class SampleAuthRepository implements AuthRepository {
  final FlutterSecureStorage _storage;

  SampleAuthRepository(this._storage);

  @override
  Future<UserSession> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final isSupervisor = email == 'supervisor@warehouse.com';
    final session = UserSession(
      userId: isSupervisor ? 'u001' : 'u002',
      name: isSupervisor ? 'Sarah Chen' : 'John Doe',
      email: email,
      site: 'Warehouse A',
      role: isSupervisor ? UserRole.supervisor : UserRole.worker,
      token: isSupervisor ? 'sample-token-supervisor' : 'sample-token-worker',
    );
    await storeSession(session);
    return session;
  }

  @override
  Future<UserSession?> getStoredSession() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;
    final role = await _storage.read(key: 'role');
    final userId = await _storage.read(key: 'userId');
    final name = await _storage.read(key: 'name');
    final email = await _storage.read(key: 'email');
    final site = await _storage.read(key: 'site');
    // If any required key is missing (partial write), clear and return null
    if (userId == null || name == null || email == null || site == null || role == null) {
      await clearSession();
      return null;
    }
    return UserSession(
      userId: userId,
      name: name,
      email: email,
      site: site,
      role: role == 'supervisor' ? UserRole.supervisor : UserRole.worker,
      token: token,
    );
  }

  @override
  Future<void> storeSession(UserSession session) async {
    await _storage.write(key: 'token', value: session.token);
    await _storage.write(key: 'role', value: session.role.name);
    await _storage.write(key: 'userId', value: session.userId);
    await _storage.write(key: 'name', value: session.name);
    await _storage.write(key: 'email', value: session.email);
    await _storage.write(key: 'site', value: session.site);
  }

  @override
  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
