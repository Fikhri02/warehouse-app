import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/data/sync/sync_coordinator.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/delivery_orders/presentation/delivery_order_detail_screen.dart';
import 'package:warehouse_app/features/delivery_orders/presentation/delivery_orders_list_screen.dart';
import 'package:warehouse_app/core/widgets/item_picker_sheet.dart';
import 'package:warehouse_app/features/delivery_orders/providers/delivery_orders_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOrdersRepository extends Mock implements OrdersRepository {}

class MockSyncCoordinator extends Mock implements SyncCoordinator {}

UserSession member(UserRole role, {String warehouseId = 'wa'}) => UserSession(
      userId: 'u1', name: 'Hafiz', email: 'h@w', site: 'A', role: role, token: 't', warehouseId: warehouseId);

void main() {
  late MockAuthRepository auth;

  setUp(() {
    auth = MockAuthRepository();
    registerFallbackValue(member(UserRole.worker));
    registerFallbackValue(OrderKind.delivery);
    registerFallbackValue(OrderStatus.draft);
  });

  Widget app(UserSession session, Widget home, {List<Override> overrides = const []}) => ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          authBootstrapStateProvider.overrideWithValue(AuthBootstrapState.hydrated(session)),
          ...overrides,
        ],
        child: MaterialApp(home: home),
      );

  testWidgets('a worker sees that an order waits for a supervisor, not the approve buttons', (tester) async {
    await tester.pumpWidget(app(member(UserRole.worker), const DeliveryOrderDetailScreen(id: 'do-2'),
        overrides: [ordersRepositoryProvider.overrideWithValue(SampleOrdersRepository())]));
    await tester.pumpAndSettle();

    expect(find.text('Approve'), findsNothing);
    expect(find.text('Waiting for a supervisor to approve'), findsOneWidget);
  });

  testWidgets('a supervisor can approve or reject', (tester) async {
    await tester.pumpWidget(app(member(UserRole.supervisor), const DeliveryOrderDetailScreen(id: 'do-2'),
        overrides: [ordersRepositoryProvider.overrideWithValue(SampleOrdersRepository())]));
    await tester.pumpAndSettle();

    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  testWidgets('a refused status change says why', (tester) async {
    final repo = MockOrdersRepository();
    final sample = SampleOrdersRepository();
    when(() => repo.getDeliveryOrderById('do-1')).thenAnswer((_) => sample.getDeliveryOrderById('do-1'));
    when(() => repo.updateOrderStatus(kind: any(named: 'kind'), id: any(named: 'id'), status: any(named: 'status')))
        .thenThrow(StateError('This order is no longer on the phone.'));
    await tester.pumpWidget(app(member(UserRole.worker), const DeliveryOrderDetailScreen(id: 'do-1'),
        overrides: [ordersRepositoryProvider.overrideWithValue(repo)]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as Packed'));
    await tester.pumpAndSettle();

    expect(find.text('This order is no longer on the phone.'), findsOneWidget);
  });

  test('the bins to pick from follow the chosen warehouse', () async {
    final repo = MockOrdersRepository();
    const a = UserSession(userId: 'u1', name: 'Hafiz', email: 'h@w', site: 'A', role: UserRole.worker, token: 't', warehouseId: 'wa');
    when(() => repo.getPickLocations()).thenAnswer((_) async => const []);
    when(() => auth.selectWarehouse(any(), 'wb')).thenAnswer((_) async => a.copyWith(warehouseId: 'wb', site: 'B'));
    final container = ProviderContainer(overrides: [
      ordersRepositoryProvider.overrideWithValue(repo),
      authRepositoryProvider.overrideWithValue(auth),
      authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(a)),
    ]);
    addTearDown(container.dispose);
    container.listen(pickLocationsProvider, (_, __) {});

    await container.read(pickLocationsProvider.future);
    await container.read(authNotifierProvider.notifier).selectWarehouse('wb');
    await container.read(pickLocationsProvider.future);

    verify(() => repo.getPickLocations()).called(2);
  });

  testWidgets('after a status change is sent, the order shows what the server made of it', (tester) async {
    final repo = MockOrdersRepository();
    final sync = MockSyncCoordinator();
    final sample = (await tester.runAsync(() => SampleOrdersRepository().getDeliveryOrderById('do-1')))!; // Submitted
    var shown = sample;
    when(() => repo.getDeliveryOrderById('do-1')).thenAnswer((_) async => shown);
    when(() => repo.updateOrderStatus(kind: any(named: 'kind'), id: any(named: 'id'), status: any(named: 'status'))).thenAnswer((_) async {
      shown = sample.copyWith(status: OrderStatus.packed); // queued
    });
    when(() => sync.syncNow()).thenAnswer((_) async {
      shown = sample; // the server refused it
    });
    await tester.pumpWidget(app(member(UserRole.worker), const DeliveryOrderDetailScreen(id: 'do-1'), overrides: [
      ordersRepositoryProvider.overrideWithValue(repo),
      syncCoordinatorProvider.overrideWithValue(sync),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as Packed'));
    await tester.pumpAndSettle();

    expect(find.text('Mark as Packed'), findsOneWidget);
  });

  testWidgets('removing one of two lines for the same item from different bins keeps the other', (tester) async {
    List<OrderItem>? changed;
    await tester.pumpWidget(ProviderScope(
      overrides: [ordersRepositoryProvider.overrideWithValue(SampleOrdersRepository())],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ItemPickerSheet(
              items: const [
                OrderItem(itemId: 'C-001', itemName: 'Beras 5kg', itemSku: 'SKU-BERAS-5KG', quantity: 10, locationId: 'bin-a', locationCode: 'A-01-01'),
                OrderItem(itemId: 'C-001', itemName: 'Beras 5kg', itemSku: 'SKU-BERAS-5KG', quantity: 5, locationId: 'bin-b', locationCode: 'B-01-01'),
              ],
              onChanged: (items) => changed = items,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close).last);

    expect(changed!.map((i) => (i.locationId, i.quantity)), [('bin-a', 10)]);
  });

  test('the delivery list follows the chosen warehouse', () async {
    final repo = MockOrdersRepository();
    const a = UserSession(userId: 'u1', name: 'Hafiz', email: 'h@w', site: 'A', role: UserRole.worker, token: 't', warehouseId: 'wa');
    when(() => repo.getDeliveryOrders(active: true)).thenAnswer((_) async => const []);
    when(() => auth.selectWarehouse(any(), 'wb')).thenAnswer((_) async => a.copyWith(warehouseId: 'wb', site: 'B'));
    final container = ProviderContainer(overrides: [
      ordersRepositoryProvider.overrideWithValue(repo),
      authRepositoryProvider.overrideWithValue(auth),
      authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(a)),
    ]);
    addTearDown(container.dispose);
    container.listen(deliveryOrdersProvider(true), (_, __) {});

    await container.read(deliveryOrdersProvider(true).future);
    await container.read(authNotifierProvider.notifier).selectWarehouse('wb');
    await container.read(deliveryOrdersProvider(true).future);

    verify(() => repo.getDeliveryOrders(active: true)).called(2);
  });

  testWidgets('pulling the delivery list down sends and fetches first', (tester) async {
    final repo = MockOrdersRepository();
    final sync = MockSyncCoordinator();
    when(() => repo.getDeliveryOrders(active: any(named: 'active'))).thenAnswer((_) async => const []);
    when(() => sync.syncNow()).thenAnswer((_) async {});
    await tester.pumpWidget(app(member(UserRole.worker), const DeliveryOrdersListScreen(), overrides: [
      ordersRepositoryProvider.overrideWithValue(repo),
      syncCoordinatorProvider.overrideWithValue(sync),
    ]));
    await tester.pumpAndSettle();

    await tester.fling(find.text('No delivery orders yet'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => sync.syncNow()).called(1);
  });
}
