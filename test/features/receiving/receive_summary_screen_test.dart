import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/config/app_config.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/receiving_repository.dart';
import 'package:warehouse_app/features/receiving/presentation/receive_summary_screen.dart';
import 'package:warehouse_app/features/receiving/providers/receiving_provider.dart';

class MockReceivingRepository extends Mock implements ReceivingRepository {}

const order = PurchaseOrder(
  id: 'po-1',
  number: 'PO-SA1-001',
  supplier: 'Gula Prai Trading',
  status: PoStatus.inProgress,
  lineItems: [PoLineItem(lineId: 'pl-1', itemId: 'i1', itemCode: 'WT-0001', itemName: 'Beras Wangi 10kg', expected: 10, received: 7, alreadyReceived: 4)],
);

void main() {
  setUpAll(() => registerFallbackValue(order));

  testWidgets('the receipt goes to the dock unless another place is chosen, with the signature', (tester) async {
    final repo = MockReceivingRepository();
    when(() => repo.getPurchaseOrders()).thenAnswer((_) async => const [order]);
    when(() => repo.getPutAwayLocations()).thenAnswer((_) async => const [
          CountLocation(id: 'dock-1', code: 'DOCK-1', kind: 'Dock'),
          CountLocation(id: 'bin-1', code: 'A-01-01', kind: 'Bin'),
        ]);
    when(() => repo.submitReceive(any(), signature: any(named: 'signature'), locationId: any(named: 'locationId'))).thenAnswer((_) async {});
    final container = ProviderContainer(overrides: [
      useApiProvider.overrideWithValue(true),
      receivingRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
    container.read(activeReceiveNotifierProvider.notifier).startReceive(order);
    final router = GoRouter(initialLocation: '/summary', routes: [
      GoRoute(path: AppRoutes.receiving, builder: (_, __) => const Text('Orders')),
      GoRoute(path: '/summary', builder: (_, __) => const ReceiveSummaryScreen()),
      GoRoute(path: AppRoutes.receivingSignature, builder: (context, _) => TextButton(
            onPressed: () => context.pop(Uint8List.fromList([0x89, 0x50])),
            child: const Text('Sign'),
          )),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: MaterialApp.router(theme: AppTheme.light, routerConfig: router)));
    await tester.pumpAndSettle();

    expect(find.text('PO-SA1-001'), findsWidgets);
    expect(find.text('DOCK-1 · Dock'), findsOneWidget); // the default put-away place

    await tester.tap(find.text('Sign & Submit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign'));
    await tester.pumpAndSettle();

    verify(() => repo.submitReceive(any(), signature: any(named: 'signature', that: isNotNull), locationId: 'dock-1')).called(1);
    expect(find.text('Orders'), findsOneWidget);
  });
}
