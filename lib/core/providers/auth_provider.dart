import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';

class AuthNotifier extends AsyncNotifier<UserSession?> {
  @override
  Future<UserSession?> build() async {
    return ref.read(authRepositoryProvider).getStoredSession();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).clearSession();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserSession?>(AuthNotifier.new);
