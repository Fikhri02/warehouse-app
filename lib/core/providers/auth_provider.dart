import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';

class AuthBootstrapState {
  final bool isHydrated;
  final UserSession? session;

  const AuthBootstrapState._({
    required this.isHydrated,
    required this.session,
  });

  const AuthBootstrapState.unhydrated()
      : this._(isHydrated: false, session: null);

  const AuthBootstrapState.hydrated(UserSession? session)
      : this._(isHydrated: true, session: session);
}

final authBootstrapStateProvider = Provider<AuthBootstrapState>(
  (_) => const AuthBootstrapState.unhydrated(),
);

class AuthNotifier extends AsyncNotifier<UserSession?> {
  @override
  FutureOr<UserSession?> build() {
    final bootstrap = ref.watch(authBootstrapStateProvider);
    if (bootstrap.isHydrated) {
      return bootstrap.session;
    }

    return ref.watch(authRepositoryProvider).getStoredSession();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
  }

  /// Chooses (or switches to) one of the person's warehouses.
  Future<void> selectWarehouse(String warehouseId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(await ref.read(authRepositoryProvider).selectWarehouse(current, warehouseId));
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).clearSession();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserSession?>(AuthNotifier.new);
