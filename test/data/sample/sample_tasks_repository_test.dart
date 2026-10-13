import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/data/sample/sample_tasks_repository.dart';

void main() {
  test('the sample worker sees their own unfinished tasks, and can start one', () async {
    final repo = SampleTasksRepository(now: DateTime(2026, 10, 13, 9));

    final mine = await repo.getMyTasks();
    expect(mine.map((t) => t.id), ['t002', 't001']); // due 14:00, then 15:00
    await repo.startTask('t001');

    expect((await repo.getTask('t001'))!.status, TaskStatus.inProgress);
  });

  test('a sample supervisor creates a task and it shows with its bin and person', () async {
    final repo = SampleTasksRepository(now: DateTime(2026, 10, 13, 9));

    await repo.createTask(const NewTask(id: 'n1', title: 'Count aisle D', type: TaskType.stockCount, locationId: 'p1', assigneeId: 'u003'));

    final created = (await repo.getOpenTasks()).firstWhere((t) => t.id == 'n1');
    expect((created.locationCode, created.assigneeName, created.status), ('A-01-01', 'Mei Ling Tan', TaskStatus.pending));
  });
}
