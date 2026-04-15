import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/alert.dart';

abstract class AlertsRepository {
  Future<List<Alert>> getAlerts();
  Future<void> markRead(String alertId);
  Future<void> markAllRead();
  Future<List<Alert>> getPendingReviews();
}

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  throw UnimplementedError('alertsRepositoryProvider not overridden');
});
