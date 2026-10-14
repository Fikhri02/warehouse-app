import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/features/alerts/screens/alerts_screen.dart';

class MockAlertsRepository extends Mock implements AlertsRepository {}

class MockTasksRepository extends Mock implements TasksRepository {}

class MockStockCountRepository extends Mock implements StockCountRepository {}

const hafiz = UserSession(userId: 'u9', name: 'Hafiz Rahman', email: 'h@w', site: 'SA1', role: UserRole.supervisor, token: 't', warehouseId: 'w1');

Alert alert(String id, AlertType type, String title, [Map<String, dynamic> payload = const {}]) =>
    Alert(id: id, type: type, title: title, body: 'body', createdAt: DateTime.now(), payload: payload);

void main() {
  late MockAlertsRepository alerts;
  late MockTasksRepository tasks;
  late MockStockCountRepository counts;

  setUp(() {
    alerts = MockAlertsRepository();
    tasks = MockTasksRepository();
    counts = MockStockCountRepository();
    when(() => alerts.getAlerts()).thenAnswer((_) async => [
          alert('a1', AlertType.taskAssigned, 'New task', {'taskId': 't1'}),
          alert('a2', AlertType.countToReview, 'Count to review', {'sessionId': 'c1'}),
          alert('a3', AlertType.syncConflict, 'Task already done'),
          alert('a4', AlertType.lowStock, 'Low stock: Beras'),
        ]);
    when(() => alerts.markRead(any())).thenAnswer((_) async {});
    when(() => tasks.getTask('t1')).thenAnswer((_) async =>
        const StaffTask(id: 't1', title: 'Count aisle C', type: TaskType.stockCount, status: TaskStatus.pending, assigneeId: 'u9'));
    when(() => counts.getCountsToReview()).thenAnswer((_) async =>
        const [CountSummary(id: 'c1', title: 'Aisle A', lineCount: 2, progress: CountProgress.waitingReview)]);
  });

  Future<void> open(WidgetTester tester) async {
    final router = GoRouter(initialLocation: AppRoutes.alerts, routes: [
      GoRoute(path: AppRoutes.alerts, builder: (_, __) => const AlertsScreen()),
      GoRoute(path: AppRoutes.tasks, builder: (_, state) => Text('tasks ${state.extra}')),
      GoRoute(path: AppRoutes.pendingReviewDetail, builder: (_, state) => Text('review ${state.extra}')),
      GoRoute(path: AppRoutes.syncIssues, builder: (_, __) => const Text('sync issues')),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        alertsRepositoryProvider.overrideWithValue(alerts),
        tasksRepositoryProvider.overrideWithValue(tasks),
        stockCountRepositoryProvider.overrideWithValue(counts),
        authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(hafiz)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a task alert marks it read and opens My Tasks at that task', (tester) async {
    await open(tester);

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();

    verify(() => alerts.markRead('a1')).called(1);
    expect(find.text('tasks t1'), findsOneWidget);
  });

  testWidgets('a task alert whose task is gone says so and stays', (tester) async {
    when(() => tasks.getTask('t1')).thenAnswer((_) async => null);
    await open(tester);

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();

    expect(find.text('No longer available'), findsOneWidget);
    expect(find.text('Count to review'), findsOneWidget);
  });

  testWidgets('a count alert opens the review only while the count still waits', (tester) async {
    await open(tester);
    await tester.tap(find.text('Count to review'));
    await tester.pumpAndSettle();
    expect(find.text('review c1'), findsOneWidget);
  });

  testWidgets('a count already reviewed says so', (tester) async {
    when(() => counts.getCountsToReview()).thenAnswer((_) async => const []);
    await open(tester);

    await tester.tap(find.text('Count to review'));
    await tester.pumpAndSettle();

    expect(find.text('No longer available'), findsOneWidget);
  });

  testWidgets('a conflict alert opens Sync Issues; a low stock alert is only marked read', (tester) async {
    await open(tester);

    await tester.tap(find.text('Low stock: Beras'));
    await tester.pumpAndSettle();
    verify(() => alerts.markRead('a4')).called(1);
    expect(find.text('Low stock: Beras'), findsOneWidget);

    await tester.tap(find.text('Task already done'));
    await tester.pumpAndSettle();
    expect(find.text('sync issues'), findsOneWidget);
  });

  testWidgets('the Sync chip shows only conflicts', (tester) async {
    await open(tester);

    await tester.tap(find.text('Sync'));
    await tester.pumpAndSettle();

    expect(find.text('Task already done'), findsOneWidget);
    expect(find.text('New task'), findsNothing);
  });

  testWidgets('a task alert for a task since given to someone else says so and stays', (tester) async {
    when(() => tasks.getTask('t1')).thenAnswer((_) async =>
        const StaffTask(id: 't1', title: 'Count aisle C', type: TaskType.stockCount, status: TaskStatus.pending, assigneeId: 'u7'));
    await open(tester);

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();

    expect(find.text('No longer available'), findsOneWidget);
    expect(find.text('tasks t1'), findsNothing);
  });

  testWidgets('tapping an alert twice quickly opens it once', (tester) async {
    await open(tester);

    await tester.tap(find.text('Count to review'));
    await tester.tap(find.text('Count to review'));
    await tester.pumpAndSettle();

    verify(() => counts.getCountsToReview()).called(1);
  });
}
