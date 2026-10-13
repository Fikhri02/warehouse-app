import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/features/tasks/widgets/task_card.dart';

void main() {
  test('the due label says today, tomorrow or the date', () {
    final now = DateTime(2026, 10, 13, 9);
    expect(dueLabel(DateTime(2026, 10, 13, 15), now: now), 'Today 15:00');
    expect(dueLabel(DateTime(2026, 10, 14, 8, 5), now: now), 'Tomorrow 08:05');
    expect(dueLabel(DateTime(2026, 10, 20, 17), now: now), '20 Oct 17:00');
  });

  testWidgets('a card shows the title, type, bin and, for supervisors, who it is with', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TaskCard(
          task: const StaffTask(id: 't1', title: 'Count aisle C', type: TaskType.stockCount, status: TaskStatus.pending, locationCode: 'A-01-01'),
          onTap: () {},
          showAssignee: true,
        ),
      ),
    ));

    expect(find.text('Count aisle C'), findsOneWidget);
    expect(find.text('Stock Count'), findsOneWidget);
    expect(find.text('A-01-01'), findsOneWidget);
    expect(find.text('Unassigned'), findsOneWidget);
  });
}
