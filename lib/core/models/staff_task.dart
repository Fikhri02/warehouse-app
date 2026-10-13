import 'package:warehouse_app/core/models/user_session.dart';

/// Spec §2 StaffTask. [serverName] is how the server spells it.
enum TaskType {
  stockCount('StockCount', 'Stock Count'),
  stockReceive('StockReceive', 'Stock Receive'),
  other('Other', 'Other');

  const TaskType(this.serverName, this.label);

  final String serverName;
  final String label;

  static TaskType fromServer(String value) => values.firstWhere((t) => t.serverName == value, orElse: () => other);
}

enum TaskStatus {
  pending('Pending', 'Pending'),
  inProgress('InProgress', 'In Progress'),
  done('Done', 'Done');

  const TaskStatus(this.serverName, this.label);

  final String serverName;
  final String label;

  static TaskStatus fromServer(String value) => values.firstWhere((s) => s.serverName == value, orElse: () => pending);
}

class StaffTask {
  const StaffTask({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.locationId,
    this.locationCode,
    this.assigneeId,
    this.assigneeName,
    this.dueAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final TaskType type;
  final TaskStatus status;
  final String? locationId;

  /// The place's code, e.g. A-04-02; null when the task names no place.
  final String? locationCode;
  final String? assigneeId;
  final String? assigneeName;
  final DateTime? dueAt;
  final DateTime? completedAt;

  StaffTask copyWith({
    TaskStatus? status,
    String? assigneeId,
    String? assigneeName,
    String? locationCode,
    DateTime? completedAt,
  }) =>
      StaffTask(
        id: id,
        title: title,
        type: type,
        status: status ?? this.status,
        locationId: locationId,
        locationCode: locationCode ?? this.locationCode,
        assigneeId: assigneeId ?? this.assigneeId,
        assigneeName: assigneeName ?? this.assigneeName,
        dueAt: dueAt,
        completedAt: completedAt ?? this.completedAt,
      );

  @override
  bool operator ==(Object other) => other is StaffTask && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Earliest due first; tasks with no due date last; then by title.
List<StaffTask> byDue(Iterable<StaffTask> tasks) => tasks.toList()
  ..sort((a, b) {
    final x = a.dueAt;
    final y = b.dueAt;
    if (x != null && y != null && x != y) return x.compareTo(y);
    if (x == null && y != null) return 1;
    if (x != null && y == null) return -1;
    return a.title.compareTo(b.title);
  });

/// A task a supervisor is creating on the phone.
class NewTask {
  const NewTask({required this.id, required this.title, required this.type, this.locationId, this.assigneeId, this.dueAt});

  final String id;
  final String title;
  final TaskType type;
  final String? locationId;
  final String? assigneeId;
  final DateTime? dueAt;
}

/// Someone in the warehouse a task can go to.
class TeamMember {
  const TeamMember({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final UserRole role;
}

/// A place a task can point at.
class TaskPlace {
  const TaskPlace({required this.id, required this.code});

  final String id;
  final String code;
}
