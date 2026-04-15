enum TaskType { stockCount, stockReceive }

enum TaskStatus { pending, inProgress, done }

class StaffTask {
  final String id;
  final TaskType type;
  final String location;
  final DateTime dueAt;
  final TaskStatus status;
  final String assignedTo;

  const StaffTask({
    required this.id,
    required this.type,
    required this.location,
    required this.dueAt,
    required this.status,
    this.assignedTo = '',
  });

  StaffTask copyWith({
    String? id,
    TaskType? type,
    String? location,
    DateTime? dueAt,
    TaskStatus? status,
    String? assignedTo,
  }) => StaffTask(
        id: id ?? this.id,
        type: type ?? this.type,
        location: location ?? this.location,
        dueAt: dueAt ?? this.dueAt,
        status: status ?? this.status,
        assignedTo: assignedTo ?? this.assignedTo,
      );

  @override
  bool operator ==(Object other) => other is StaffTask && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
