import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';

class SampleTasksRepository implements TasksRepository {
  @override
  Future<List<StaffTask>> getTasks() async {
    // Supervisor view — all tasks across all workers
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      StaffTask(
        id: 't001',
        type: TaskType.stockCount,
        location: 'Aisle C — Zone 2',
        dueAt: DateTime(now.year, now.month, now.day, 15, 0),
        status: TaskStatus.pending,
        assignedTo: 'u002',
      ),
      StaffTask(
        id: 't002',
        type: TaskType.stockReceive,
        location: 'Receiving Bay 1',
        dueAt: DateTime(now.year, now.month, now.day, 14, 0),
        status: TaskStatus.inProgress,
        assignedTo: 'u002',
      ),
      StaffTask(
        id: 't003',
        type: TaskType.stockCount,
        location: 'Aisle B — Zone 1',
        dueAt: now.subtract(const Duration(days: 1)),
        status: TaskStatus.done,
        assignedTo: 'u002',
      ),
      StaffTask(
        id: 'at-1',
        type: TaskType.stockCount,
        location: 'Zone B',
        dueAt: now.add(const Duration(hours: 2)),
        status: TaskStatus.pending,
      ),
      StaffTask(
        id: 'at-2',
        type: TaskType.stockReceive,
        location: 'Dock 2',
        dueAt: now.add(const Duration(hours: 4)),
        status: TaskStatus.pending,
      ),
    ];
  }

  @override
  Future<List<StaffTask>> getMyTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      StaffTask(
        id: 't001',
        type: TaskType.stockCount,
        location: 'Aisle C — Zone 2',
        dueAt: DateTime(now.year, now.month, now.day, 15, 0),
        status: TaskStatus.pending,
        assignedTo: 'u002',
      ),
      StaffTask(
        id: 't002',
        type: TaskType.stockReceive,
        location: 'Receiving Bay 1',
        dueAt: DateTime(now.year, now.month, now.day, 14, 0),
        status: TaskStatus.inProgress,
        assignedTo: 'u002',
      ),
      StaffTask(
        id: 't003',
        type: TaskType.stockCount,
        location: 'Aisle B — Zone 1',
        dueAt: now.subtract(const Duration(days: 1)),
        status: TaskStatus.done,
        assignedTo: 'u002',
      ),
    ];
  }

  @override
  Future<List<StaffTask>> getAssignableTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      StaffTask(
        id: 'at-1',
        type: TaskType.stockCount,
        location: 'Zone B',
        dueAt: DateTime.now().add(const Duration(hours: 2)),
        status: TaskStatus.pending,
      ),
      StaffTask(
        id: 'at-2',
        type: TaskType.stockReceive,
        location: 'Dock 2',
        dueAt: DateTime.now().add(const Duration(hours: 4)),
        status: TaskStatus.pending,
      ),
    ];
  }

  @override
  Future<void> assignTask(StaffTask task) async {
    // Sample layer: no-op
  }

  @override
  Future<List<StaffTask>> getCompletedTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      StaffTask(
        id: 'ct-1',
        type: TaskType.stockCount,
        location: 'Zone A',
        dueAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: TaskStatus.done,
        assignedTo: 'u002',
      ),
    ];
  }
}
