import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

    await tester.fling(find.text('No pending purchase orders'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => sync.syncNow()).called(1);
    verify(() => repo.getPurchaseOrders()).called(2);
  });
}
