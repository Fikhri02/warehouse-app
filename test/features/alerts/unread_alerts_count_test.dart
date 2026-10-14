import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';
import 'package:warehouse_app/features/alerts/widgets/alerts_bell.dart';

class MockAlertsRepository extends Mock implements AlertsRepository {}

Alert alert(String id, {bool read = false}) =>
    Alert(id: id, type: AlertType.lowStock, title: id, body: '', createdAt: DateTime(2026, 10, 14), isRead: read);

void main() {
  Future<void> show(WidgetTester tester, List<Alert> alerts) async {
    final repo = MockAlertsRepository();
    when(() => repo.getAlerts()).thenAnswer((_) async => alerts);
    await tester.pumpWidget(ProviderScope(
      overrides: [alertsRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: Scaffold(body: UnreadAlertsCount())),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('the menu shows how many alerts are unread', (tester) async {
    await show(tester, [alert('a'), alert('b'), alert('c', read: true)]);

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('with nothing unread the menu shows no count', (tester) async {
    await show(tester, [alert('c', read: true)]);

    expect(find.byType(Badge), findsNothing);
  });
}
