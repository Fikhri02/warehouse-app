import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/tasks/screens/tasks_screen.dart';

class MockTasksRepository extends Mock implements TasksRepository {}

const arjun = UserSession(userId: 'u1', name: 'Arjun Nair', email: 'a@w', site: 'SA1', role: UserRole.worker, token: 't', warehouseId: 'w1');
const count = StaffTask(id: 't1', title: 'Count aisle C', type: TaskType.stockCount, status: TaskStatus.pending, assigneeId: 'u1');

void main() {
  late MockTasksRepository repo;

  setUp(() {
    repo = MockTasksRepository();
    when(() => repo.getMyTasks()).thenAnswer((_) async => [count]);
    when(() => repo.startTask('t1')).thenAnswer((_) async {});
  });

  Future<void> open(WidgetTester tester, {String? openTaskId}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(repo),
        authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(arjun)),
      ],
      child: MaterialApp(home: TasksScreen(openTaskId: openTaskId)),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a task opens its sheet, and Start starts it', (tester) async {
    await open(tester);

    await tester.tap(find.text('Count aisle C'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    verify(() => repo.startTask('t1')).called(1);
    expect(find.text('Task started'), findsOneWidget);
  });

  testWidgets('opened from an alert, the task sheet opens by itself', (tester) async {
    await open(tester, openTaskId: 't1');

    expect(find.text('Go to counting'), findsOneWidget);
  });

  testWidgets('opened from an alert for a task that is gone, the screen says so', (tester) async {
    await open(tester, openTaskId: 'gone');

    expect(find.text('No longer available'), findsOneWidget);
  });

  testWidgets('a sync in the background keeps the list where it is, with no spinner', (tester) async {
    when(() => repo.getMyTasks()).thenAnswer((_) async => [
          for (var i = 0; i < 40; i++)
            StaffTask(id: 't$i', title: 'Task $i', type: TaskType.other, status: TaskStatus.pending, assigneeId: 'u1'),
        ]);
    final container = ProviderContainer(overrides: [
      tasksRepositoryProvider.overrideWithValue(repo),
      authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(arjun)),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MaterialApp(home: TasksScreen())));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();
    final offset = tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;

    container.read(pulledProvider.notifier).state++;
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels, offset);
  });
}
