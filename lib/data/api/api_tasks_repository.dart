import 'dart:async';
import 'dart:convert';

import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

/// Tasks against the server (spec addendum 3d). Tasks come from the phone's copy, with this phone's commands that the
/// copy doesn't show yet laid on top, oldest first. Creating, assigning, starting and finishing go through the outbox.
class ApiTasksRepository implements TasksRepository {
  ApiTasksRepository({
    required ApiClient client,
    required AppDatabase db,
    required UserSession? Function() session,
    required void Function() onQueued,
    Duration teamWait = const Duration(seconds: 4),
  })  : _client = client,
        _db = db,
        _session = session,
        _onQueued = onQueued,
        _teamWait = teamWait;

  final ApiClient _client;
  final AppDatabase _db;
  final UserSession? Function() _session;
  final void Function() _onQueued;

  /// How long the team picker waits on the server before using the saved list (a weak signal can take 20 s to fail).
  final Duration _teamWait;

  @override
  Future<List<StaffTask>> getMyTasks() async {
    final me = _session()?.userId;
    return byDue((await _tasks()).where((t) => t.assigneeId == me && t.status != TaskStatus.done));
  }

  @override
  Future<List<StaffTask>> getOpenTasks() async => byDue((await _tasks()).where((t) => t.status != TaskStatus.done));

  @override
  Future<List<StaffTask>> getCompletedTasks() async => (await _tasks()).where((t) => t.status == TaskStatus.done).toList()
    ..sort((a, b) => (b.completedAt ?? DateTime(0)).compareTo(a.completedAt ?? DateTime(0)));

  @override
  Future<StaffTask?> getTask(String id) async => _find(await _tasks(), id);

  @override
  Future<void> startTask(String id) async {
    final (session, warehouseId) = _where();
    final task = await _require(id);
    if (task.status != TaskStatus.pending) return; // already started or done: nothing to send
    if (task.assigneeId != session.userId) throw StateError('Only the person this task is assigned to can start it.');
    await _queue(SyncOps.taskStart, id, warehouseId, {'title': task.title});
  }

  @override
  Future<void> completeTask(String id) async {
    final (session, warehouseId) = _where();
    final task = await _require(id);
    if (task.status == TaskStatus.done) return;
    if (task.assigneeId != session.userId && session.role != UserRole.supervisor) {
      throw StateError('Only the person this task is assigned to, or a supervisor, can finish it.');
    }
    await _queue(SyncOps.taskComplete, id, warehouseId, {'title': task.title});
  }

  @override
  Future<void> assignTask(String id, String assigneeId) async {
    final (session, warehouseId) = _where();
    _supervisorOnly(session, 'assign tasks');
    final task = await _require(id);
    if (task.status == TaskStatus.done) throw StateError('"${task.title}" is already done.');
    if (task.assigneeId == assigneeId) return;
    await _queue(SyncOps.taskAssign, id, warehouseId, {'title': task.title, 'assigneeUserId': assigneeId});
  }

  @override
  Future<void> createTask(NewTask task) async {
    final (session, warehouseId) = _where();
    _supervisorOnly(session, 'create tasks');
    final title = task.title.trim();
    if (title.isEmpty || title.length > 200) throw StateError('A title must be 1 to 200 characters.');
    await _queue(SyncOps.taskCreate, task.id, warehouseId, {
      'title': title,
      'body': {
        'id': task.id,
        'title': title,
        'type': task.type.serverName,
        if (task.locationId != null) 'locationId': task.locationId,
        if (task.assigneeId != null) 'assigneeUserId': task.assigneeId,
        if (task.dueAt != null) 'dueAt': task.dueAt!.toUtc().toIso8601String(),
      },
    });
  }

  @override
  Future<List<TeamMember>> getTeam() async {
    final (session, warehouseId) = _where();
    if (session.role == UserRole.supervisor) {
      // Only supervisors may list the people; a fresh list replaces the saved one.
      try {
        final listed = (await _client.get('/warehouses/$warehouseId/members').timeout(_teamWait) as List).cast<Map<String, dynamic>>();
        await _db.serverMirrorDao.replaceMembers(warehouseId, [
          for (final m in listed)
            WarehouseMembersCompanion.insert(
              warehouseId: warehouseId,
              userId: m['userId'] as String,
              displayName: m['displayName'] as String,
              role: m['role'] as String,
              isActive: m['isActive'] as bool,
            ),
        ]);
      } on ApiOfflineException {
        // Offline: the list saved last time.
      } on TimeoutException {
        // A weak signal: the list saved last time rather than a long wait.
      } on ApiException {
        // The server is having trouble: the list saved last time.
      } on SessionExpiredException {
        // The client has already sent the person back to sign-in.
      }
    }
    return [
      for (final m in await _db.serverMirrorDao.members(warehouseId))
        if (m.isActive)
          TeamMember(id: m.userId, name: m.displayName, role: m.role == 'Supervisor' ? UserRole.supervisor : UserRole.worker),
    ];
  }

  @override
  Future<List<TaskPlace>> getPlaces() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final rows = await _db.serverMirrorDao.locationsFor(warehouseId);
    rows.sort((a, b) => (a.type == 'Bin' ? 0 : 1).compareTo(b.type == 'Bin' ? 0 : 1)); // stable: codes stay in order
    return [for (final l in rows) TaskPlace(id: l.id, code: l.code)];
  }

  /// The server's copy, with this phone's changes it doesn't show yet laid on top in the order they were made.
  Future<List<StaffTask>> _tasks() async {
    final session = _session();
    final warehouseId = session?.warehouseId;
    if (session == null || warehouseId == null) return const [];
    final dao = _db.serverMirrorDao;
    final byId = <String, StaffTask>{
      for (final row in await dao.tasks(warehouseId))
        row.id: StaffTask(
          id: row.id,
          title: row.title,
          type: TaskType.fromServer(row.type),
          status: TaskStatus.fromServer(row.status),
          locationId: row.locationId,
          assigneeId: row.assigneeUserId,
          dueAt: row.dueAt,
          completedAt: row.completedAt,
        ),
    };

    final caughtUp = await dao.caughtUpThrough(warehouseId);
    final waiting = [
      for (final op in SyncOps.taskCommands)
        ...await _db.syncQueueDao.notYetInCopy(op, warehouseId: warehouseId, caughtUpThrough: caughtUp),
    ]..sort((a, b) => a.id.compareTo(b.id));
    for (final command in waiting) {
      final payload = jsonDecode(command.payload) as Map<String, dynamic>;
      final task = byId[command.referenceId];
      switch (command.operationType) {
        case SyncOps.taskCreate:
          if (task == null) {
            final body = payload['body'] as Map<String, dynamic>;
            byId[command.referenceId] = StaffTask(
              id: command.referenceId,
              title: body['title'] as String,
              type: TaskType.fromServer(body['type'] as String),
              status: TaskStatus.pending,
              locationId: body['locationId'] as String?,
              assigneeId: body['assigneeUserId'] as String?,
              dueAt: body['dueAt'] == null ? null : DateTime.parse(body['dueAt'] as String).toLocal(),
            );
          }
        case SyncOps.taskAssign:
          if (task != null && task.status != TaskStatus.done) {
            byId[command.referenceId] = task.copyWith(assigneeId: payload['assigneeUserId'] as String);
          }
        case SyncOps.taskStart:
          if (task != null && task.status == TaskStatus.pending) {
            byId[command.referenceId] = task.copyWith(status: TaskStatus.inProgress);
          }
        case SyncOps.taskComplete:
          if (task != null) {
            byId[command.referenceId] = task.copyWith(status: TaskStatus.done, completedAt: task.completedAt ?? command.queuedAt);
          }
      }
    }

    final names = {for (final m in await dao.members(warehouseId)) m.userId: m.displayName, session.userId: session.name};
    final codes = {for (final l in await dao.locationsFor(warehouseId)) l.id: l.code};
    return [
      for (final t in byId.values)
        t.copyWith(
          locationCode: t.locationId == null ? null : codes[t.locationId] ?? 'Unknown place',
          assigneeName: t.assigneeId == null ? null : names[t.assigneeId] ?? 'Someone else',
        ),
    ];
  }

  (UserSession, String) _where() {
    final session = _session();
    final warehouseId = session?.warehouseId;
    if (session == null || warehouseId == null) throw StateError('No warehouse chosen.');
    return (session, warehouseId);
  }

  Future<StaffTask> _require(String id) async =>
      _find(await _tasks(), id) ?? (throw StateError('This task is no longer on the phone.'));

  static void _supervisorOnly(UserSession session, String what) {
    if (session.role != UserRole.supervisor) throw StateError('Only a supervisor can $what.');
  }

  Future<void> _queue(String op, String id, String warehouseId, Map<String, Object?> payload) async {
    await _db.syncQueueDao.enqueue(operationType: op, referenceId: id, warehouseId: warehouseId, payload: jsonEncode(payload));
    _onQueued();
  }

  static StaffTask? _find(List<StaffTask> tasks, String id) => tasks.where((t) => t.id == id).firstOrNull;
}
