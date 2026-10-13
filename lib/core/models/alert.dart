/// Spec §2 Alert. [serverName] is how the server spells it.
enum AlertType {
  lowStock('LowStock'),
  taskAssigned('TaskAssigned'),
  countToReview('CountToReview'),
  syncConflict('SyncConflict');

  const AlertType(this.serverName);

  final String serverName;

  /// Null for a type this version of the app does not know; such alerts are not shown.
  static AlertType? fromServer(String value) {
    for (final type in values) {
      if (type.serverName == value) return type;
    }
    return null;
  }
}

class Alert {
  const Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.payload = const {},
  });

  final String id;
  final AlertType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  /// What the server attached: taskId (TaskAssigned), sessionId (CountToReview), itemId/sku/total/threshold
  /// (LowStock), code/conflictId (SyncConflict).
  final Map<String, dynamic> payload;

  String? get taskId => payload['taskId'] as String?;

  String? get sessionId => payload['sessionId'] as String?;

  Alert copyWith({bool? isRead}) => Alert(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        payload: payload,
      );

  @override
  bool operator ==(Object other) => other is Alert && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

enum AlertFilter { all, stock, tasks, sync }

class AlertsState {
  final List<Alert> all;
  final AlertFilter filter;

  const AlertsState({required this.all, this.filter = AlertFilter.all});

  List<Alert> get filtered => switch (filter) {
        AlertFilter.all => all,
        AlertFilter.stock => all.where((a) => a.type == AlertType.lowStock || a.type == AlertType.countToReview).toList(),
        AlertFilter.tasks => all.where((a) => a.type == AlertType.taskAssigned).toList(),
        AlertFilter.sync => all.where((a) => a.type == AlertType.syncConflict).toList(),
      };

  int get unreadCount => all.where((a) => !a.isRead).length;

  AlertsState copyWith({List<Alert>? all, AlertFilter? filter}) => AlertsState(all: all ?? this.all, filter: filter ?? this.filter);
}
