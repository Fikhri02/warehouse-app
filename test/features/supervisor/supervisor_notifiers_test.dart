import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/features/supervisor/providers/assign_tasks_provider.dart';
import 'package:warehouse_app/features/supervisor/providers/pending_review_provider.dart';
import 'package:warehouse_app/features/supervisor/providers/reports_provider.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';

class MockTasksRepository extends Mock implements TasksRepository {}

class MockAlertsRepository extends Mock implements AlertsRepository {}

class _FakeStaffTask extends Fake implements StaffTask {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeStaffTask());
  });

  group('AssignTasksNotifier', () {
    test('assignTask calls repository and refreshes', () async {
      final mockRepo = MockTasksRepository();
      when(() => mockRepo.getAssignableTasks()).thenAnswer((_) async => []);
      when(() => mockRepo.assignTask(any())).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [tasksRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(assignTasksProvider.future);
      await container.read(assignTasksProvider.notifier).assignTask(
            StaffTask(
              id: 'new-task',
              type: TaskType.stockCount,
              location: 'Zone C',
              dueAt: DateTime(2026, 4, 15, 17),
              status: TaskStatus.pending,
              assignedTo: 'worker-2',
            ),
          );

      verify(() => mockRepo.assignTask(any())).called(1);
    });
  });

  group('PendingReviewNotifier', () {
    test('loads pending reviews on build', () async {
      final mockRepo = MockAlertsRepository();

      final pendingAlerts = [
        Alert(
          id: 'pa1',
          type: AlertType.discrepancy,
          title: 'Discrepancy: PO-001',
          body: '2 items flagged',
          createdAt: DateTime(2026, 4, 15, 10),
          isRead: false,
        ),
      ];
      when(() => mockRepo.getPendingReviews())
          .thenAnswer((_) async => pendingAlerts);

      final container = ProviderContainer(
        overrides: [alertsRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(pendingReviewProvider.future);
      final reviews = container.read(pendingReviewProvider).valueOrNull;
      expect(reviews?.length, 1);
    });
  });

  group('ReportsNotifier', () {
    test('loads reports on build', () async {
      final mockRepo = MockTasksRepository();
      when(() => mockRepo.getCompletedTasks()).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [tasksRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(reportsProvider.future);
      final reports = container.read(reportsProvider).valueOrNull;
      expect(reports, isNotNull);
    });
  });
}
