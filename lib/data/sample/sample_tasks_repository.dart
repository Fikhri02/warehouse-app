import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';

/// Sample data for builds without WARETRACK_API. The sample worker is u002 (see SampleAuthRepository).
class SampleTasksRepository implements TasksRepository {
  SampleTasksRepository({DateTime? now}) : _tasks = _seed(now ?? DateTime.now());

  static const _me = 'u002';

  static const team = [
    TeamMember(id: 'u001', name: 'Hafiz Rahman', role: UserRole.supervisor),
    TeamMember(id: 'u002', name: 'Arjun Nair', role: UserRole.worker),
    TeamMember(id: 'u003', name: 'Mei Ling Tan', role: UserRole.worker),
  ];

  static const places = [
    TaskPlace(id: 'p1', code: 'A-01-01'),
    TaskPlace(id: 'p2', code: 'B-02-03'),
    TaskPlace(id: 'p3', code: 'DOCK-1'),
  ];

  final List<StaffTask> _tasks;

  static List<StaffTask> _seed(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return [
      StaffTask(
        id: 't001',
        title: 'Count aisle C',
        type: TaskType.stockCount,
        status: TaskStatus.pending,
        locationId: 'p2',
        locationCode: 'B-02-03',
        assigneeId: _me,
        assigneeName: 'Arjun Nair',
        dueAt: today.add(const Duration(hours: 15)),
      ),
      StaffTask(
        id: 't002',
        title: 'Receive PO-2041',
        type: TaskType.stockReceive,
        status: TaskStatus.inProgress,
        locationId: 'p3',
        locationCode: 'DOCK-1',
        assigneeId: _me,
        assigneeName: 'Arjun Nair',
        dueAt: today.add(const Duration(hours: 14)),
      ),
      StaffTask(
        id: 't003',
        title: 'Count aisle B',
        type: TaskType.stockCount,
        status: TaskStatus.done,
        locationId: 'p1',
        locationCode: 'A-01-01',
        assigneeId: _me,
        assigneeName: 'Arjun Nair',
        dueAt: today.subtract(const Duration(hours: 9)),
        completedAt: today.subtract(const Duration(hours: 10)),
      ),
      StaffTask(id: 'at-1', title: 'Count zone B', type: TaskType.stockCount, status: TaskStatus.pending, dueAt: now.add(const Duration(hours: 2))),
      const StaffTask(id: 'at-2', title: 'Tidy dock 2', type: TaskType.other, status: TaskStatus.pending),
    ];
  }

  @override
  Future<List<StaffTask>> getMyTasks() async => byDue(_tasks.where((t) => t.assigneeId == _me && t.status != TaskStatus.done));

  @override
  Future<List<StaffTask>> getOpenTasks() async => byDue(_tasks.where((t) => t.status != TaskStatus.done));

  @override
  Future<List<StaffTask>> getCompletedTasks() async => _tasks.where((t) => t.status == TaskStatus.done).toList()
    ..sort((a, b) => (b.completedAt ?? DateTime(0)).compareTo(a.completedAt ?? DateTime(0)));

  @override
  Future<StaffTask?> getTask(String id) async => _tasks.where((t) => t.id == id).firstOrNull;

  @override
  Future<void> startTask(String id) async =>
      _replace(id, (t) => t.status == TaskStatus.pending ? t.copyWith(status: TaskStatus.inProgress) : t);

  @override
  Future<void> completeTask(String id) async =>
      _replace(id, (t) => t.copyWith(status: TaskStatus.done, completedAt: DateTime.now()));

  @override
  Future<void> assignTask(String id, String assigneeId) async =>
      _replace(id, (t) => t.copyWith(assigneeId: assigneeId, assigneeName: _name(assigneeId)));

  @override
  Future<void> createTask(NewTask task) async => _tasks.add(StaffTask(
        id: task.id,
        title: task.title.trim(),
        type: task.type,
        status: TaskStatus.pending,
        locationId: task.locationId,
        locationCode: places.where((p) => p.id == task.locationId).firstOrNull?.code,
        assigneeId: task.assigneeId,
        assigneeName: task.assigneeId == null ? null : _name(task.assigneeId!),
        dueAt: task.dueAt,
      ));

  @override
  Future<List<TeamMember>> getTeam() async => team;

  @override
  Future<List<TaskPlace>> getPlaces() async => places;

  void _replace(String id, StaffTask Function(StaffTask) change) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i != -1) _tasks[i] = change(_tasks[i]);
  }

  static String _name(String id) => team.where((m) => m.id == id).firstOrNull?.name ?? 'Someone else';
}
