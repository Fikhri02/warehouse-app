import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/features/tasks/providers/tasks_provider.dart';
import 'package:warehouse_app/data/repositories/tasks_repository.dart';

class MockTasksRepository extends Mock implements TasksRepository {}

void main() {
  late MockTasksRepository mockRepo;

  setUp(() {
    mockRepo = MockTasksRepository();
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [tasksRepositoryProvider.overrideWithValue(mockRepo)],
    );
  }

  const sampleTasks = [
    StaffTask(id: 't1', title: 'Count zone A', type: TaskType.stockCount, status: TaskStatus.pending, assigneeId: 'worker-1'),
    StaffTask(id: 't2', title: 'Receive at dock 3', type: TaskType.stockReceive, status: TaskStatus.inProgress, assigneeId: 'worker-1'),
  ];

  test('loads tasks on build', () async {
    when(() => mockRepo.getMyTasks()).thenAnswer((_) async => sampleTasks);
    final container = makeContainer();
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    final tasks = container.read(tasksProvider).valueOrNull;

    expect(tasks?.length, 2);
    expect(tasks?.first.type, TaskType.stockCount);
  });

  test('returns empty list when no tasks', () async {
    when(() => mockRepo.getMyTasks()).thenAnswer((_) async => []);
    final container = makeContainer();
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    final tasks = container.read(tasksProvider).valueOrNull;
    expect(tasks, isEmpty);
  });

  test('start goes through the repository and the list reloads', () async {
    when(() => mockRepo.getMyTasks()).thenAnswer((_) async => sampleTasks);
    when(() => mockRepo.startTask('t1')).thenAnswer((_) async {});
    final container = makeContainer();
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    await container.read(tasksProvider.notifier).start('t1');
    await container.read(tasksProvider.future);

    verify(() => mockRepo.startTask('t1')).called(1);
    verify(() => mockRepo.getMyTasks()).called(2);
  });
}
