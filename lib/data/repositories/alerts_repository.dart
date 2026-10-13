import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/alert.dart';

abstract class AlertsRepository {
  /// The signed-in person's alerts, newest first.
  Future<List<Alert>> getAlerts();

  Future<void> markRead(String alertId);

  /// Marks [alertIds] read: the alerts the person has on screen, never ones the chip hides or that arrive later.
  Future<void> markAllRead(Iterable<String> alertIds);
}

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  throw UnimplementedError('alertsRepositoryProvider not overridden');
});
