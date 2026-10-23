import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/features/dashboard/presentation/widgets/dashboard_greeting.dart';

void main() {
  test('the greeting follows the clock', () {
    expect(greetingFor(DateTime(2026, 10, 23, 4, 59)), 'Good evening');
    expect(greetingFor(DateTime(2026, 10, 23, 5)), 'Good morning');
    expect(greetingFor(DateTime(2026, 10, 23, 11, 59)), 'Good morning');
    expect(greetingFor(DateTime(2026, 10, 23, 12)), 'Good afternoon');
    expect(greetingFor(DateTime(2026, 10, 23, 17, 59)), 'Good afternoon');
    expect(greetingFor(DateTime(2026, 10, 23, 18)), 'Good evening');
  });

  testWidgets('Home greets by first name with the time of day', (tester) async {
    const session = UserSession(userId: 'u2', name: 'John Doe', email: 'w@x', site: 'Warehouse A', role: UserRole.worker, token: 't');
    await tester.pumpWidget(MaterialApp(
      home: DashboardGreeting(session: session, clock: () => DateTime(2026, 10, 23, 15)),
    ));
    expect(find.text('Good afternoon, John'), findsOneWidget);
    expect(find.text('Worker · Warehouse A'), findsOneWidget);
  });
}
