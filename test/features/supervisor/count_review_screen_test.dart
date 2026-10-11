import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/features/supervisor/screens/count_review_screen.dart';

class MockStockCountRepository extends Mock implements StockCountRepository {}

void main() {
  testWidgets('rejecting needs a reason, then queues it', (tester) async {
    final repo = MockStockCountRepository();
    when(() => repo.getCountReview('c1')).thenAnswer((_) async => CountReview(
          id: 'c1',
          title: 'Aisle A',
          countedBy: 'Arjun Nair',
          submittedAt: DateTime(2026, 10, 11, 8, 12),
          status: 'Submitted',
          lines: const [
            CountReviewLine(itemName: 'Beras Wangi 10kg', sku: 'WT-0001', locationCode: 'A-01-01', counted: 8, systemAtSubmit: 10, current: 9, difference: -2),
          ],
        ));
    when(() => repo.rejectCount('c1', any())).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [stockCountRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: AppTheme.light, home: const CountReviewScreen(sessionId: 'c1')),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Beras Wangi 10kg'), findsOneWidget);
    expect(find.text('Stock moved in 1 bin since this count.'), findsOneWidget);

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reject Count'));
    await tester.pumpAndSettle();
    expect(find.text('Say why, so the counter knows what to recount.'), findsOneWidget);
    verifyNever(() => repo.rejectCount(any(), any()));

    await tester.enterText(find.byType(TextField), 'Count the back row too');
    await tester.tap(find.text('Reject Count'));
    await tester.pumpAndSettle();

    verify(() => repo.rejectCount('c1', 'Count the back row too')).called(1);
  });
}
