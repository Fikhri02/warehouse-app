import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/features/tasks/providers/active_task_provider.dart';

const count = StaffTask(id: 't1', title: 'Count aisle C', type: TaskType.stockCount, status: TaskStatus.inProgress);

void main() {
  test('only the remembered task of the same kind is offered, and it is forgotten either way', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final active = container.read(activeTaskProvider.notifier);

    active.remember(count);
    expect(active.take(TaskType.stockReceive), isNull);
    expect(container.read(activeTaskProvider), isNull);

    active.remember(count);
    expect(active.take(TaskType.stockCount), count);
    expect(container.read(activeTaskProvider), isNull);
  });

  test('the task is kept only while the person stays in counting, receiving or My Tasks', () {
    expect(keepsActiveTask('/stock-count/scan/manual-entry'), isTrue);
    expect(keepsActiveTask('/receiving/summary/signature'), isTrue);
    expect(keepsActiveTask('/tasks'), isTrue);
    expect(keepsActiveTask('/dashboard'), isFalse);
    expect(keepsActiveTask('/delivery-orders'), isFalse);
  });

  testWidgets('a screen opened on top of counting forgets the task; moving within counting keeps it', (tester) async {
    var forgotten = 0;
    final router = GoRouter(initialLocation: '/stock-count', routes: [
      GoRoute(path: '/stock-count', builder: (_, __) => const Text('counting'), routes: [
        GoRoute(path: 'scan', builder: (_, __) => const Text('scanning')),
      ]),
      GoRoute(path: '/alerts', builder: (_, __) => const Text('alerts')),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    final stop = forgetTaskOutsideItsWork(router, () => forgotten++);
    addTearDown(stop);

    router.push('/stock-count/scan');
    await tester.pumpAndSettle();
    expect(forgotten, 0);

    router.push('/alerts');
    await tester.pumpAndSettle();
    expect(forgotten, 1);
  });
}
