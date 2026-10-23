import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/data/repositories/receiving_repository.dart';
import 'package:warehouse_app/data/sync/sync_coordinator.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/receiving/presentation/po_list_screen.dart';

class MockReceivingRepository extends Mock implements ReceivingRepository {}

class MockSyncCoordinator extends Mock implements SyncCoordinator {}

void main() {
  testWidgets('pulling down an empty list fetches new orders', (tester) async {
    final repo = MockReceivingRepository();
    final sync = MockSyncCoordinator();
    when(() => repo.getPurchaseOrders()).thenAnswer((_) async => const []);
    when(() => sync.syncNow()).thenAnswer((_) async {});
    await tester.pumpWidget(ProviderScope(
      overrides: [receivingRepositoryProvider.overrideWithValue(repo), syncCoordinatorProvider.overrideWithValue(sync)],
      child: const MaterialApp(home: PoListScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.fling(find.textContaining('No purchase orders to receive'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => sync.syncNow()).called(1);
    verify(() => repo.getPurchaseOrders()).called(2);
  });

  testWidgets('an order being received opens to its first three lines, started ones first', (tester) async {
    final repo = MockReceivingRepository();
    when(() => repo.getPurchaseOrders()).thenAnswer((_) async => const [
          PurchaseOrder(
            id: 'PO-1',
            supplier: 'Acme Supplies',
            status: PoStatus.inProgress,
            lineItems: [
              PoLineItem(itemCode: 'A', itemName: 'Aluminium Sheet', expected: 50),
              PoLineItem(itemCode: 'B', itemName: 'Brass Hinge', expected: 10),
              PoLineItem(itemCode: 'C', itemName: 'Copper Wire', expected: 100, received: 30),
              PoLineItem(itemCode: 'D', itemName: 'Duct Tape', expected: 5),
              PoLineItem(itemCode: 'E', itemName: 'Epoxy', expected: 2),
            ],
          ),
        ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [receivingRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: PoListScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Continue receiving'), findsNothing);

    await tester.tap(find.text('Acme Supplies'));
    await tester.pumpAndSettle();

    expect(find.text('Copper Wire'), findsOneWidget);
    expect(find.text('30 / 100'), findsOneWidget);
    expect(find.text('Aluminium Sheet'), findsOneWidget);
    expect(find.text('Brass Hinge'), findsOneWidget);
    expect(find.text('Duct Tape'), findsNothing);
    expect(find.text('and 2 more…'), findsOneWidget);
    expect(find.text('Continue receiving'), findsOneWidget);

    await tester.tap(find.text('Acme Supplies'));
    await tester.pumpAndSettle();
    expect(find.text('Continue receiving'), findsNothing);
  });
}
