import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_tasks_repository.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/sync/command_sender.dart';

import '../../support/api_fakes.dart';

const w = '22222222-2222-4222-8222-222222222222';

UserSession person(String id, String name, UserRole role) => UserSession(
      userId: id,
      name: name,
      email: '$id@waretrack.local',
      site: 'Shah Alam DC',
      role: role,
      token: 't',
      warehouseId: w,
      warehouses: [WarehouseMembership(warehouseId: w, code: 'SA1', name: 'Shah Alam DC', role: role)],
    );

final arjun = person('u1', 'Arjun Nair', UserRole.worker);
final hafiz = person('u9', 'Hafiz Rahman', UserRole.supervisor);

RemoteTasksCompanion task(String id, String status, {String? assignee, DateTime? due, String? bin}) => RemoteTasksCompanion.insert(
      id: id,
      warehouseId: w,
      title: 'Task $id',
      type: 'StockCount',
      locationId: Value(bin),
      assigneeUserId: Value(assignee),
      status: status,
      dueAt: Value(due),
      createdByUserId: 'u9',
      completedAt: Value(status == 'Done' ? DateTime.utc(2026, 10, 13, 5) : null),
    );

void main() {
  late AppDatabase db;
  late UserSession session;
  late ApiTasksRepository repo;
  late int kicks;
  late bool online;
  late List<Map<String, dynamic>> serverMembers;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    session = arjun;
    kicks = 0;
    online = true;
    serverMembers = [
      {'userId': 'u1', 'displayName': 'Arjun Nair', 'email': 'a@w', 'role': 'Worker', 'isActive': true},
      {'userId': 'u2', 'displayName': 'Mei Ling Tan', 'email': 'm@w', 'role': 'Worker', 'isActive': true},
      {'userId': 'u5', 'displayName': 'Left Last Year', 'email': 'l@w', 'role': 'Worker', 'isActive': false},
      {'userId': 'u9', 'displayName': 'Hafiz Rahman', 'email': 'h@w', 'role': 'Supervisor', 'isActive': true},
    ];
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((r) async {
        if (!online) throw http.ClientException('offline');
        expect(r.url.path, '/api/warehouses/$w/members');
        return jsonResponse(serverMembers);
      }),
    );
    repo = ApiTasksRepository(client: client, db: db, session: () => session, onQueued: () => kicks++);
    final dao = db.serverMirrorDao;
    await dao.upsertLocation(WarehouseLocationsCompanion.insert(id: 'bin-1', warehouseId: w, code: 'A-01-01', type: 'Bin'));
    await dao.replaceMembers(w, [
      WarehouseMembersCompanion.insert(warehouseId: w, userId: 'u2', displayName: 'Mei Ling Tan', role: 'Worker', isActive: true),
    ]);
    await dao.upsertTask(task('mine', 'Pending', assignee: 'u1', due: DateTime.utc(2026, 10, 13, 7), bin: 'bin-1'));
    await dao.upsertTask(task('hers', 'InProgress', assignee: 'u2'));
    await dao.upsertTask(task('nobody', 'Pending'));
    await dao.upsertTask(task('finished', 'Done', assignee: 'u1'));
  });
  tearDown(() => db.close());

  Future<List<SyncQueueData>> queued() => db.syncQueueDao.getPendingItems();

  test('my tasks are the unfinished ones given to me, with their bin and my name', () async {
    final mine = await repo.getMyTasks();

    expect(mine.map((t) => (t.id, t.locationCode, t.assigneeName)), [('mine', 'A-01-01', 'Arjun Nair')]);
  });

  test('starting a task offline shows it in progress at once and queues one start', () async {
    await repo.startTask('mine');
    await repo.startTask('mine'); // already in progress on the phone: nothing more to send

    expect((await repo.getMyTasks()).single.status, TaskStatus.inProgress);
    expect((await queued()).map((c) => (c.operationType, c.referenceId)), [(SyncOps.taskStart, 'mine')]);
    expect(jsonDecode((await queued()).single.payload), {'title': 'Task mine'});
    expect(kicks, 1);
  });

  test("a worker cannot start a task that isn't theirs", () async {
    await expectLater(repo.startTask('nobody'), throwsA(isA<StateError>()));
    expect(await queued(), isEmpty);
  });

  test("finishing shows it done at once; a worker can't finish someone else's task, a supervisor can", () async {
    await repo.completeTask('mine');
    expect(await repo.getMyTasks(), isEmpty);
    await expectLater(repo.completeTask('hers'), throwsA(isA<StateError>()));

    session = hafiz;
    await repo.completeTask('hers');

    final done = await repo.getCompletedTasks();
    expect(done.map((t) => t.id).toSet(), {'mine', 'hers', 'finished'});
  });

  test('a task given to someone else leaves my list even with my start waiting', () async {
    await repo.startTask('mine');
    await db.serverMirrorDao.upsertTask(task('mine', 'Pending', assignee: 'u2'));

    expect(await repo.getMyTasks(), isEmpty);
  });

  test("a supervisor's new task shows before it is sent, with its bin and person", () async {
    session = hafiz;

    await repo.createTask(NewTask(
      id: 'new-1',
      title: '  Count aisle D ',
      type: TaskType.stockCount,
      locationId: 'bin-1',
      assigneeId: 'u2',
      dueAt: DateTime.utc(2026, 10, 14, 1),
    ));

    final created = (await repo.getOpenTasks()).firstWhere((t) => t.id == 'new-1');
    expect((created.title, created.locationCode, created.assigneeName, created.status),
        ('Count aisle D', 'A-01-01', 'Mei Ling Tan', TaskStatus.pending));
    expect(jsonDecode((await queued()).single.payload), {
      'title': 'Count aisle D',
      'body': {
        'id': 'new-1',
        'title': 'Count aisle D',
        'type': 'StockCount',
        'locationId': 'bin-1',
        'assigneeUserId': 'u2',
        'dueAt': '2026-10-14T01:00:00.000Z',
      },
    });
  });

  test('a new task needs a title, and only a supervisor can create or assign', () async {
    await expectLater(repo.createTask(const NewTask(id: 'n', title: 'Count', type: TaskType.other)), throwsA(isA<StateError>()));
    await expectLater(repo.assignTask('nobody', 'u1'), throwsA(isA<StateError>()));
    session = hafiz;
    await expectLater(repo.createTask(const NewTask(id: 'n', title: '   ', type: TaskType.other)), throwsA(isA<StateError>()));
    expect(await queued(), isEmpty);
  });

  test('assigning offline moves the task at once', () async {
    session = hafiz;

    await repo.assignTask('nobody', 'u2');

    final moved = (await repo.getOpenTasks()).firstWhere((t) => t.id == 'nobody');
    expect((moved.assigneeId, moved.assigneeName), ('u2', 'Mei Ling Tan'));
    expect(jsonDecode((await queued()).single.payload), {'title': 'Task nobody', 'assigneeUserId': 'u2'});
  });

  test('the team comes from the server when it can be reached, else the saved list; people who left are not offered', () async {
    session = hafiz;

    expect((await repo.getTeam()).map((m) => m.name), ['Arjun Nair', 'Hafiz Rahman', 'Mei Ling Tan']);
    online = false;
    serverMembers = [];
    expect((await repo.getTeam()).map((m) => (m.name, m.role)),
        [('Arjun Nair', UserRole.worker), ('Hafiz Rahman', UserRole.supervisor), ('Mei Ling Tan', UserRole.worker)]);
  });

  test('a create already in the copy is not shown twice', () async {
    session = hafiz;
    await repo.createTask(const NewTask(id: 'nobody', title: 'Task nobody', type: TaskType.stockCount));

    expect((await repo.getOpenTasks()).where((t) => t.id == 'nobody'), hasLength(1));
  });
}
