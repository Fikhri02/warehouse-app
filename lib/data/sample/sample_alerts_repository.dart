import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';

/// Sample data for builds without WARETRACK_API.
class SampleAlertsRepository implements AlertsRepository {
  final List<Alert> _alerts = [
    Alert(
      id: 'a001',
      type: AlertType.lowStock,
      title: 'Low stock: Aluminium Sheet 2mm',
      body: '12 left in SA1, below 20',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      payload: const {'sku': 'WH-00142', 'total': 12, 'threshold': 20},
    ),
    Alert(
      id: 'a002',
      type: AlertType.taskAssigned,
      title: 'New task',
      body: 'Count aisle C',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      payload: const {'taskId': 't001'},
    ),
    Alert(
      id: 'a003',
      type: AlertType.countToReview,
      title: 'Count to review',
      body: 'Arjun Nair counted 4 line(s) in Aisle B',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      payload: const {'sessionId': 'c1'},
    ),
    Alert(
      id: 'a004',
      type: AlertType.syncConflict,
      title: 'Task already done',
      body: '"Count aisle B" was already completed.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Future<List<Alert>> getAlerts() async => List.unmodifiable(_alerts);

  @override
  Future<void> markRead(String alertId) async {
    final i = _alerts.indexWhere((a) => a.id == alertId);
    if (i != -1) _alerts[i] = _alerts[i].copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead(Iterable<String> alertIds) async {
    final ids = alertIds.toSet();
    for (var i = 0; i < _alerts.length; i++) {
      if (ids.contains(_alerts[i].id)) _alerts[i] = _alerts[i].copyWith(isRead: true);
    }
  }
}
