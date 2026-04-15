import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';

class SampleAlertsRepository implements AlertsRepository {
  final List<Alert> _alerts = [
    Alert(
      id: 'a001',
      type: AlertType.lowStock,
      title: 'Low Stock Alert',
      body: 'Aluminium Sheet 2mm (WH-00142) is below minimum threshold — 12 units remaining.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Alert(
      id: 'a002',
      type: AlertType.taskAssigned,
      title: 'Task Assigned',
      body: 'Supervisor assigned you a stock count — Aisle C, Zone 2. Due by 3:00 PM.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Alert(
      id: 'a003',
      type: AlertType.taskCompleted,
      title: 'Task Completed',
      body: 'Count Session #14 (Aisle B) submitted and accepted by supervisor.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    Alert(
      id: 'a004',
      type: AlertType.discrepancy,
      title: 'Discrepancy: PO-2041',
      body: 'Worker flagged 2 items during receiving. Supervisor review required.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  Future<List<Alert>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_alerts);
  }

  @override
  Future<void> markRead(String alertId) async {
    final idx = _alerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) _alerts[idx] = _alerts[idx].copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead() async {
    for (var i = 0; i < _alerts.length; i++) {
      _alerts[i] = _alerts[i].copyWith(isRead: true);
    }
  }

  @override
  Future<List<Alert>> getPendingReviews() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _alerts.where((a) => a.type == AlertType.discrepancy && !a.isRead).toList();
  }
}
