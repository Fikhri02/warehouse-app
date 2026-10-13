import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/staff_task.dart';

abstract class TasksRepository {
  /// Tasks given to the signed-in person that are not done, by due date.
  Future<List<StaffTask>> getMyTasks();

  /// Every task in the warehouse that is not done, by due date (supervisors).
  Future<List<StaffTask>> getOpenTasks();

  /// Finished tasks, most recently finished first.
  Future<List<StaffTask>> getCompletedTasks();

  Future<StaffTask?> getTask(String id);

  /// Throws [StateError] with a sentence for the person when it cannot be done.
  Future<void> startTask(String id);

  Future<void> completeTask(String id);

  Future<void> assignTask(String id, String assigneeId);

  Future<void> createTask(NewTask task);

  /// The warehouse's people: from the server when it can be reached, else the list saved last time.
  Future<List<TeamMember>> getTeam();

  /// Places a task can point at, bins first.
  Future<List<TaskPlace>> getPlaces();
}

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  throw UnimplementedError('tasksRepositoryProvider not overridden');
});
