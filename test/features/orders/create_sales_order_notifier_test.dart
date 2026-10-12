import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/features/sales_orders/providers/create_sales_order_notifier.dart';

const binA = OrderLocation(id: 'bin-a', name: 'A-01-01', type: 'Bin');

void main() {
  late SampleOrdersRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = SampleOrdersRepository();
    container = ProviderContainer(overrides: [ordersRepositoryProvider.overrideWithValue(repo)]);
  });
  tearDown(() => container.dispose());

  test('a sales order needs a customer and a bin to pick from', () {
    final notifier = container.read(createSalesOrderNotifierProvider.notifier);

    expect(notifier.validateStep1(), isFalse);
    expect(container.read(createSalesOrderNotifierProvider).errors.keys, containsAll(['customerName', 'pickFrom']));
  });

  test('sales notes longer than the server keeps are caught on the phone', () {
    final notifier = container.read(createSalesOrderNotifierProvider.notifier)
      ..setPickFrom(binA)
      ..setCustomerName('Kedai Maju Jaya')
      ..setNotes('x' * 1001);

    expect(notifier.validateStep1(), isFalse);
    expect(container.read(createSalesOrderNotifierProvider).errors['notes'], 'Notes must be at most 1000 characters');
  });

  test('a sales order is saved with its lines picked from the chosen bin', () async {
    final notifier = container.read(createSalesOrderNotifierProvider.notifier)
      ..setPickFrom(binA)
      ..setCustomerName('Kedai Maju Jaya')
      ..setItems([const OrderItem(itemId: 'C-005', itemName: 'Susu Pekat 500g', itemSku: 'SKU-SUSU-500G', quantity: 6)]);

    final saved = await notifier.submit(asDraft: false);

    final stored = await repo.getSalesOrderById(saved.id);
    expect((stored!.customerName, stored.status, stored.items.single.locationCode), ('Kedai Maju Jaya', OrderStatus.submitted, 'A-01-01'));
  });
}
