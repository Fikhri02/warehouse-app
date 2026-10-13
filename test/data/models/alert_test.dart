import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/alert.dart';

Alert alert(String id, AlertType type) =>
    Alert(id: id, type: type, title: id, body: '', createdAt: DateTime(2026, 10, 13));

void main() {
  test('an alert knows the task or count it is about', () {
    final a = Alert(
      id: 'a1',
      type: AlertType.taskAssigned,
      title: 'New task',
      body: 'Count aisle C',
      createdAt: DateTime(2026, 10, 13),
      payload: const {'taskId': 't1'},
    );

    expect((a.taskId, a.sessionId), ('t1', null));
    expect(AlertType.fromServer('CountToReview'), AlertType.countToReview);
    expect(AlertType.fromServer('Birthday'), isNull);
  });

  test('the chips split alerts into stock, tasks and sync', () {
    final state = AlertsState(all: [
      alert('low', AlertType.lowStock),
      alert('review', AlertType.countToReview),
      alert('task', AlertType.taskAssigned),
      alert('conflict', AlertType.syncConflict),
    ]);

    expect(state.copyWith(filter: AlertFilter.stock).filtered.map((a) => a.id), ['low', 'review']);
    expect(state.copyWith(filter: AlertFilter.tasks).filtered.map((a) => a.id), ['task']);
    expect(state.copyWith(filter: AlertFilter.sync).filtered.map((a) => a.id), ['conflict']);
  });
}
