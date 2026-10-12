import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/features/delivery_orders/providers/create_delivery_order_notifier.dart';

const binA = OrderLocation(id: 'bin-a', name: 'A-01-01', type: 'Bin');
const binB = OrderLocation(id: 'bin-b', name: 'B-01-01', type: 'Bin');
const beras = OrderItem(itemId: 'C-001', itemName: 'Beras 5kg', itemSku: 'SKU-BERAS-5KG', quantity: 3);

void main() {
  late SampleOrdersRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = SampleOrdersRepository();
    container = ProviderContainer(overrides: [ordersRepositoryProvider.overrideWithValue(repo)]);
  });
  tearDown(() => container.dispose());

  CreateDeliveryOrderNotifier notifier() => container.read(createDeliveryOrderNotifierProvider.notifier);
  CreateDeliveryOrderState state() => container.read(createDeliveryOrderNotifierProvider);

  test('a delivery needs a destination and a bin to pick from', () {
    expect(notifier().validateStep1(), isFalse);
    expect(state().errors.keys, containsAll(['destination', 'pickFrom']));
  });

  test('notes longer than the server keeps are caught on the phone', () {
    notifier()
      ..setPickFrom(binA)
      ..setDestination('Outlet')
      ..setNotes('x' * 1001);

    expect(notifier().validateStep1(), isFalse);
    expect(state().errors['notes'], 'Notes must be at most 1000 characters');
  });

  test('items are picked from the chosen bin, and changing the bin moves every line', () {
    notifier()
      ..setPickFrom(binA)
      ..setItems([beras]);
    expect(state().items.single.locationId, 'bin-a');

    notifier().setPickFrom(binB);

    final line = state().items.single;
    expect((line.locationId, line.locationCode), ('bin-b', 'B-01-01'));
  });

  test('loading an order keeps each line\'s own bin', () {
    notifier().loadFromOrder(DeliveryOrder(
      id: 'do-x',
      orderNumber: 'DO-X',
      destination: 'Outlet Subang',
      deliveryDate: DateTime(2026, 10, 14),
      status: OrderStatus.draft,
      requiresApproval: false,
      createdBy: 'Hafiz Rahman',
      createdAt: DateTime(2026, 10, 12),
      items: [
        beras.copyWith(locationId: 'bin-a', locationCode: 'A-01-01'),
        const OrderItem(itemId: 'C-002', itemName: 'Minyak', itemSku: 'SKU-MINYAK-5L', locationId: 'bin-b', locationCode: 'B-01-01'),
      ],
    ));

    notifier().setItems([...state().items, const OrderItem(itemId: 'C-003', itemName: 'Gula', itemSku: 'SKU-GULA-1KG')]);

    expect(state().items.map((i) => i.locationId), ['bin-a', 'bin-b', 'bin-a']); // the new line takes Pick From (the first line's bin)
  });

  test('a new order needing approval is saved under its own id and waits for approval', () async {
    notifier()
      ..setPickFrom(binA)
      ..setDestination('Outlet Damansara')
      ..toggleApproval(true)
      ..setItems([beras]);

    final saved = await notifier().submit(asDraft: false);

    expect(saved.id, hasLength(36));
    expect(saved.status, OrderStatus.pendingApproval);
    final stored = await repo.getDeliveryOrderById(saved.id);
    expect((stored!.destination, stored.items.single.locationId, stored.orderNumber.isNotEmpty), ('Outlet Damansara', 'bin-a', true));
  });

  test('editing an order keeps its id and number', () async {
    final existing = (await repo.getDeliveryOrders(active: true)).first;
    notifier().loadFromOrder(existing);
    notifier().setDestination('Outlet Ampang');

    final saved = await notifier().submit(asDraft: true);

    expect((saved.id, saved.orderNumber, saved.destination), (existing.id, existing.orderNumber, 'Outlet Ampang'));
  });
}
