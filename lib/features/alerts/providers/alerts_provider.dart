import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';

export 'package:warehouse_app/data/repositories/alerts_repository.dart'
    show alertsRepositoryProvider;

class AlertsNotifier extends AsyncNotifier<AlertsState> {
  /// Kept on the notifier so a reload (a read, a pull) doesn't reset the chip.
  AlertFilter _filter = AlertFilter.all;

  @override
  Future<AlertsState> build() async {
    ref.watch(authNotifierProvider.select((auth) => (auth.valueOrNull?.userId, auth.valueOrNull?.warehouseId)));
    ref.watch(pulledProvider);
    final alerts = await ref.watch(alertsRepositoryProvider).getAlerts();
    return AlertsState(all: alerts, filter: _filter);
  }

  void setFilter(AlertFilter filter) {
    _filter = filter;
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(filter: filter));
  }

  Future<void> markRead(String id) async {
    await ref.read(alertsRepositoryProvider).markRead(id);
    ref.invalidateSelf();
  }

  /// Marks read the unread alerts the current chip shows — the ones the person can see.
  Future<void> markAllRead() async {
    final onScreen = [for (final a in state.valueOrNull?.filtered ?? const <Alert>[]) if (!a.isRead) a.id];
    if (onScreen.isEmpty) return;
    await ref.read(alertsRepositoryProvider).markAllRead(onScreen);
    ref.invalidateSelf();
  }

  Future<void> syncAndReload() async {
    await ref.read(syncCoordinatorProvider).syncNow();
    ref.invalidateSelf();
    await future;
  }
}

final alertsProvider = AsyncNotifierProvider<AlertsNotifier, AlertsState>(
  AlertsNotifier.new,
);
