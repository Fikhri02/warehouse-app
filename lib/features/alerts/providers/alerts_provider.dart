import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';

export 'package:warehouse_app/data/repositories/alerts_repository.dart'
    show alertsRepositoryProvider;

class AlertsNotifier extends AsyncNotifier<AlertsState> {
  @override
  Future<AlertsState> build() async {
    final alerts = await ref.watch(alertsRepositoryProvider).getAlerts();
    return AlertsState(all: alerts);
  }

  void setFilter(AlertFilter filter) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(filter: filter));
  }

  Future<void> markAllRead() async {
    await ref.read(alertsRepositoryProvider).markAllRead();
    ref.invalidateSelf();
  }
}

final alertsProvider = AsyncNotifierProvider<AlertsNotifier, AlertsState>(
  AlertsNotifier.new,
);
