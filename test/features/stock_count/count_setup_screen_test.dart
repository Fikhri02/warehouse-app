import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/local/app_database.dart' as db;
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/features/stock_count/presentation/count_setup_screen.dart';
import 'package:warehouse_app/features/stock_count/providers/stock_count_provider.dart';

class MockStockCountRepository extends Mock implements StockCountRepository {}

void main() {
  testWidgets('a count starts once a location is chosen', (tester) async {
    final repo = MockStockCountRepository();
    when(() => repo.getLocations()).thenAnswer((_) async => const [
          CountLocation(id: 'bin-1', code: 'A-01-01', kind: 'Bin'),
          CountLocation(id: 'zone-1', code: 'COLD', kind: 'Zone'),
        ]);
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(overrides: [
      stockCountRepositoryProvider.overrideWithValue(repo),
      db.appDatabaseProvider.overrideWithValue(database),
    ]);
    addTearDown(container.dispose);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const CountSetupScreen()),
      GoRoute(path: '/stock-count/scan', builder: (_, __) => const Text('Scanning')),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Counting'));
    await tester.pumpAndSettle();
    expect(find.text('Choose where you are counting.'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COLD · Zone').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Counting'));
    await tester.pumpAndSettle();

    expect(find.text('Scanning'), findsOneWidget);
    expect(container.read(stockCountNotifierProvider)?.locationId, 'zone-1');
    expect(container.read(stockCountNotifierProvider)?.location, 'COLD');
  });
}
