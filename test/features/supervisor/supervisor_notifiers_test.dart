import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/features/supervisor/providers/assign_tasks_provider.dart';
import 'package:warehouse_app/features/supervisor/providers/pending_review_provider.dart';
import 'package:warehouse_app/features/supervisor/providers/reports_provider.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';

class MockTasksRepository extends Mock implements TasksRepository {}

class MockStockCountRepository extends Mock implements StockCountRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AssignTasksNotifier', () {
    test('assign sends the task and person to the repository and reloads', () async {
      final mockRepo = MockTasksRepository();
      when(() => mockRepo.getOpenTasks()).thenAnswer((_) async => []);
      when(() => mockRepo.assignTask('t3', 'u2')).thenAnswer((_) async {});
      final container = ProviderContainer(overrides: [tasksRepositoryProvider.overrideWithValue(mockRepo)]);
      addTearDown(container.dispose);

      await container.read(assignTasksProvider.future);
      await container.read(assignTasksProvider.notifier).assign('t3', 'u2');
      await container.read(assignTasksProvider.future); // the reload runs on the next read

      verify(() => mockRepo.assignTask('t3', 'u2')).called(1);
      verify(() => mockRepo.getOpenTasks()).called(2);
    });
  });

  group('PendingReviewNotifier', () {
    test('loads the counts waiting for review', () async {
      final mockRepo = MockStockCountRepository();
      when(() => mockRepo.getCountsToReview()).thenAnswer((_) async => const [
            CountSummary(id: 'c1', title: 'Aisle A', lineCount: 2, progress: CountProgress.waitingReview),
          ]);
      final container = ProviderContainer(overrides: [stockCountRepositoryProvider.overrideWithValue(mockRepo)]);
      addTearDown(container.dispose);

      final reviews = await container.read(pendingReviewProvider.future);

      expect(reviews.single.title, 'Aisle A');
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

  test('the_review_list_follows_the_chosen_warehouse', () async {
    final counts = MockStockCountRepository();
    final auth = MockAuthRepository();
    const a = UserSession(userId: 'u1', name: 'Hafiz', email: 'h@w', site: 'A', role: UserRole.supervisor, token: 't', warehouseId: 'wa');
    registerFallbackValue(a);
    when(() => counts.getCountsToReview()).thenAnswer((_) async => const []);
    when(() => auth.selectWarehouse(any(), 'wb')).thenAnswer((_) async => a.copyWith(warehouseId: 'wb', site: 'B'));
    final container = ProviderContainer(overrides: [
      stockCountRepositoryProvider.overrideWithValue(counts),
      authRepositoryProvider.overrideWithValue(auth),
      authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(a)),
    ]);
    addTearDown(container.dispose);
    container.listen(pendingReviewProvider, (_, __) {});

    await container.read(pendingReviewProvider.future);
    await container.read(authNotifierProvider.notifier).selectWarehouse('wb');
    await container.read(pendingReviewProvider.future);

    verify(() => counts.getCountsToReview()).called(2);
  });
}
