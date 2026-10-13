import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/staff_task.dart';

StaffTask task(String id, {DateTime? due, String? title}) =>
    StaffTask(id: id, title: title ?? id, type: TaskType.stockCount, status: TaskStatus.pending, dueAt: due);

void main() {
  test('tasks due soonest come first, and tasks with no due date last', () {
    final sorted = byDue([
      task('none-b', title: 'B'),
      task('late', due: DateTime(2026, 10, 14, 9)),
      task('none-a', title: 'A'),
      task('soon', due: DateTime(2026, 10, 13, 15)),
    ]);

    expect(sorted.map((t) => t.id), ['soon', 'late', 'none-a', 'none-b']);
  });

  test('server spellings map both ways, and an unknown type is Other', () {
    expect(TaskType.fromServer('StockReceive'), TaskType.stockReceive);
    expect(TaskType.fromServer('Cleaning'), TaskType.other);
    expect(TaskStatus.fromServer('InProgress'), TaskStatus.inProgress);
    expect(TaskStatus.done.serverName, 'Done');
  });
}
