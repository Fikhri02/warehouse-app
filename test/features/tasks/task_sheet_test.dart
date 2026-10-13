import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/features/tasks/widgets/task_sheet.dart';

void main() {
  late List<String> tapped;

  Future<void> show(WidgetTester tester, StaffTask task) => tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskSheet(
            task: task,
            onStart: () => tapped.add('start'),
            onDone: () => tapped.add('done'),
            onGo: () => tapped.add('go'),
          ),
        ),
      ));

  setUp(() => tapped = []);

  testWidgets('a waiting count offers Start and the way to counting, not Done', (tester) async {
    await show(tester, const StaffTask(id: 't1', title: 'Count aisle C', type: TaskType.stockCount, status: TaskStatus.pending, locationCode: 'A-01-01'));

    expect(find.text('A-01-01'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
    await tester.tap(find.text('Go to counting'));
    await tester.tap(find.text('Start'));

    expect(tapped, ['go', 'start']);
  });

  testWidgets('a receive in progress offers Done and the way to receiving', (tester) async {
    await show(tester, const StaffTask(id: 't2', title: 'Receive PO-2041', type: TaskType.stockReceive, status: TaskStatus.inProgress));

    expect(find.text('Start'), findsNothing);
    await tester.tap(find.text('Go to receiving'));
    await tester.tap(find.text('Done'));

    expect(tapped, ['go', 'done']);
  });

  testWidgets('an Other task has nowhere to go', (tester) async {
    await show(tester, const StaffTask(id: 't3', title: 'Tidy dock 2', type: TaskType.other, status: TaskStatus.pending));

    expect(find.textContaining('Go to'), findsNothing);
    expect(find.text('Start'), findsOneWidget);
  });
}
