import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/features/supervisor/screens/assign_tasks_screen.dart';

class MockTasksRepository extends Mock implements TasksRepository {}

const hafiz = UserSession(userId: 'u9', name: 'Hafiz Rahman', email: 'h@w', site: 'SA1', role: UserRole.supervisor, token: 't', warehouseId: 'w1');

void main() {
  late MockTasksRepository repo;

  setUp(() {
    repo = MockTasksRepository();
    when(() => repo.getOpenTasks()).thenAnswer((_) async => const [
          StaffTask(id: 't1', title: 'Receive PO-2041', type: TaskType.stockReceive, status: TaskStatus.inProgress, assigneeId: 'u1', assigneeName: 'Arjun Nair'),
          StaffTask(id: 't3', title: 'Tidy dock 2', type: TaskType.other, status: TaskStatus.pending),
        ]);
    when(() => repo.getTeam()).thenAnswer((_) async => const [
          TeamMember(id: 'u1', name: 'Arjun Nair', role: UserRole.worker),
          TeamMember(id: 'u2', name: 'Mei Ling Tan', role: UserRole.worker),
        ]);
    when(() => repo.assignTask(any(), any())).thenAnswer((_) async {});
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(repo),
        authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(hafiz)),
      ],
      child: const MaterialApp(home: AssignTasksScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('unassigned tasks come first, then assigned ones with who has them', (tester) async {
    await open(tester);

    final unassigned = tester.getTopLeft(find.text('Unassigned').first).dy;
    final assigned = tester.getTopLeft(find.text('Assigned')).dy;
    expect(unassigned, lessThan(assigned));
    expect(tester.getTopLeft(find.text('Tidy dock 2')).dy, lessThan(assigned));
    expect(find.text('Arjun Nair'), findsOneWidget);
  });

  testWidgets('picking a person assigns the task to them', (tester) async {
    await open(tester);

    await tester.tap(find.text('Tidy dock 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mei Ling Tan'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Assign'));
    await tester.pumpAndSettle();

    verify(() => repo.assignTask('t3', 'u2')).called(1);
  });

  testWidgets('names on assigned tasks appear once the team has loaded, without leaving the screen', (tester) async {
    var teamLoaded = false;
    when(() => repo.getOpenTasks()).thenAnswer((_) async => [
          StaffTask(
            id: 't1',
            title: 'Receive PO-2041',
            type: TaskType.stockReceive,
            status: TaskStatus.inProgress,
            assigneeId: 'u1',
            assigneeName: teamLoaded ? 'Arjun Nair' : 'Someone else', // names come from the saved team
          ),
        ]);
    when(() => repo.getTeam()).thenAnswer((_) async {
      await Future<void>.value();
      teamLoaded = true;
      return const [TeamMember(id: 'u1', name: 'Arjun Nair', role: UserRole.worker)];
    });

    await open(tester);

    expect(find.text('Someone else'), findsNothing);
    expect(find.text('Arjun Nair'), findsOneWidget);
  });

  testWidgets('tapping a task again while the team is still loading opens one picker, not two', (tester) async {
    final team = Completer<List<TeamMember>>();
    when(() => repo.getTeam()).thenAnswer((_) => team.future);
    await open(tester);

    await tester.tap(find.text('Tidy dock 2'));
    await tester.tap(find.text('Tidy dock 2'));
    team.complete(const [TeamMember(id: 'u2', name: 'Mei Ling Tan', role: UserRole.worker)]);
    await tester.pumpAndSettle();

    expect(find.text('Assign to'), findsOneWidget);
  });
}
