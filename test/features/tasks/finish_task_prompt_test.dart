import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/features/tasks/providers/active_task_provider.dart';
import 'package:warehouse_app/features/tasks/widgets/finish_task_prompt.dart';

class MockTasksRepository extends Mock implements TasksRepository {}

const count = StaffTask(id: 't1', title: 'Count aisle C', type: TaskType.stockCount, status: TaskStatus.inProgress, assigneeId: 'u1');
const arjun = UserSession(userId: 'u1', name: 'Arjun Nair', email: 'a@w', site: 'SA1', role: UserRole.worker, token: 't', warehouseId: 'w1');

void main() {
  late MockTasksRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockTasksRepository();
    when(() => repo.completeTask(any())).thenAnswer((_) async {});
    when(() => repo.getMyTasks()).thenAnswer((_) async => []);
    when(() => repo.getTask('t1')).thenAnswer((_) async => count);
    container = ProviderContainer(overrides: [
      tasksRepositoryProvider.overrideWithValue(repo),
      authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(arjun)),
    ]);
  });
  tearDown(() => container.dispose());

  Future<void> submitted(WidgetTester tester, TaskType type) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () => offerToFinishTask(context, ref, type),
              child: const Text('Submit'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
  }

  testWidgets('after a count opened from a task, Done finishes that task', (tester) async {
    container.read(activeTaskProvider.notifier).remember(count);

    await submitted(tester, TaskType.stockCount);
    expect(find.text("Mark 'Count aisle C' done?"), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    verify(() => repo.completeTask('t1')).called(1);
    expect(container.read(activeTaskProvider), isNull);
  });

  testWidgets('Not yet leaves the task as it is', (tester) async {
    container.read(activeTaskProvider.notifier).remember(count);

    await submitted(tester, TaskType.stockCount);
    await tester.tap(find.text('Not yet'));
    await tester.pumpAndSettle();

    verifyNever(() => repo.completeTask(any()));
  });

  testWidgets('a receipt is not offered a remembered count task', (tester) async {
    container.read(activeTaskProvider.notifier).remember(count);

    await submitted(tester, TaskType.stockReceive);

    expect(find.textContaining('done?'), findsNothing);
    expect(container.read(activeTaskProvider), isNull);
  });

  testWidgets('a task given to someone else meanwhile is not offered', (tester) async {
    when(() => repo.getTask('t1')).thenAnswer((_) async =>
        const StaffTask(id: 't1', title: 'Count aisle C', type: TaskType.stockCount, status: TaskStatus.inProgress, assigneeId: 'u2'));
    container.read(activeTaskProvider.notifier).remember(count);

    await submitted(tester, TaskType.stockCount);

    expect(find.textContaining('done?'), findsNothing);
  });

  testWidgets('if finishing fails the person is told to finish it from My Tasks, and the count is not called failed', (tester) async {
    when(() => repo.completeTask('t1')).thenAnswer((_) async => throw Exception('database is locked'));
    container.read(activeTaskProvider.notifier).remember(count);

    await submitted(tester, TaskType.stockCount);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't mark the task done — you can finish it from My Tasks"), findsOneWidget);
  });
}
