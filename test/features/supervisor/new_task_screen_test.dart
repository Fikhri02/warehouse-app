import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/features/supervisor/screens/new_task_screen.dart';

class MockTasksRepository extends Mock implements TasksRepository {}

const hafiz = UserSession(userId: 'u9', name: 'Hafiz Rahman', email: 'h@w', site: 'SA1', role: UserRole.supervisor, token: 't', warehouseId: 'w1');

void main() {
  late MockTasksRepository repo;
  late List<NewTask> created;

  setUpAll(() => registerFallbackValue(const NewTask(id: 'x', title: 'x', type: TaskType.other)));

  setUp(() {
    repo = MockTasksRepository();
    created = [];
    when(() => repo.getOpenTasks()).thenAnswer((_) async => const []);
    when(() => repo.getPlaces()).thenAnswer((_) async => const [TaskPlace(id: 'bin-1', code: 'A-01-01')]);
    when(() => repo.getTeam()).thenAnswer((_) async => const [TeamMember(id: 'u2', name: 'Mei Ling Tan', role: UserRole.worker)]);
    when(() => repo.createTask(any())).thenAnswer((call) async => created.add(call.positionalArguments.single as NewTask));
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(repo),
        authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(hafiz)),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const NewTaskScreen())),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  // The button sits below the fold on the test screen.
  Future<void> tapCreate(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Create Task'));
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();
  }

  testWidgets('a task needs a title', (tester) async {
    await open(tester);

    await tapCreate(tester);

    expect(find.text('Enter a title'), findsOneWidget);
    expect(created, isEmpty);
  });

  testWidgets('a supervisor creates a count for one person, and the form closes', (tester) async {
    await open(tester);

    await tester.enterText(find.byType(TextFormField), 'Count aisle D');
    await tester.tap(find.text('Nobody yet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mei Ling Tan').last);
    await tester.pumpAndSettle();
    await tapCreate(tester);

    expect(created.single.title, 'Count aisle D');
    expect((created.single.type, created.single.assigneeId, created.single.locationId), (TaskType.stockCount, 'u2', null));
    expect(find.text('Open'), findsOneWidget); // back where it was opened from
  });

  testWidgets('with no team saved, the form says so and still creates an unassigned task', (tester) async {
    when(() => repo.getTeam()).thenAnswer((_) async => const []);
    await open(tester);

    expect(find.text('Connect once to load your team'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Tidy dock 2');
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    await tapCreate(tester);

    expect((created.single.type, created.single.assigneeId), (TaskType.other, null));
  });

  testWidgets('while the team is loading the form says so, not "Connect once"', (tester) async {
    final team = Completer<List<TeamMember>>();
    when(() => repo.getTeam()).thenAnswer((_) => team.future);
    await open(tester);

    expect(find.text('Loading your team…'), findsOneWidget);
    expect(find.text('Connect once to load your team'), findsNothing);
    team.complete(const []);
  });
}
