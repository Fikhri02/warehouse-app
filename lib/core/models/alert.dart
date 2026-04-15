enum AlertType { lowStock, taskAssigned, discrepancy, taskCompleted }

class Alert {
  final String id;
  final AlertType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  Alert copyWith({
    String? id,
    AlertType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
  }) => Alert(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
        isRead: isRead ?? this.isRead,
      );

  @override
  bool operator ==(Object other) => other is Alert && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

enum AlertFilter { all, stock, tasks }

class AlertsState {
  final List<Alert> all;
  final AlertFilter filter;

  const AlertsState({required this.all, this.filter = AlertFilter.all});

  List<Alert> get filtered {
    return switch (filter) {
      AlertFilter.all => all,
      AlertFilter.stock => all.where((a) => a.type == AlertType.lowStock || a.type == AlertType.discrepancy).toList(),
      AlertFilter.tasks => all.where((a) => a.type == AlertType.taskAssigned || a.type == AlertType.taskCompleted).toList(),
    };
  }

  int get unreadCount => all.where((a) => !a.isRead).length;

  AlertsState copyWith({List<Alert>? all, AlertFilter? filter}) {
    return AlertsState(all: all ?? this.all, filter: filter ?? this.filter);
  }
}
