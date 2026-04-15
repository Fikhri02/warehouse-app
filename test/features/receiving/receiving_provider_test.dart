import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/data/repositories/receiving_repository.dart';
import 'package:warehouse_app/features/receiving/providers/receiving_provider.dart';

class MockReceivingRepository extends Mock implements ReceivingRepository {}

void main() {
  late MockReceivingRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockReceivingRepository();
    registerFallbackValue(const PurchaseOrder(
      id: 'PO-X',
      supplier: 'Test',
      status: PoStatus.pending,
    ));
    container = ProviderContainer(
      overrides: [receivingRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() => container.dispose());

  group('PurchaseOrdersNotifier', () {
    test('loads purchase orders on init', () async {
      when(() => mockRepo.getPurchaseOrders()).thenAnswer((_) async => [
            const PurchaseOrder(
              id: 'PO-001',
              supplier: 'Acme',
              status: PoStatus.pending,
            ),
          ]);

      final orders =
          await container.read(purchaseOrdersNotifierProvider.future);
      expect(orders.length, equals(1));
      expect(orders.first.id, equals('PO-001'));
    });
  });

  group('ActiveReceiveNotifier', () {
    test('confirmItem marks item as received with given qty', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(itemCode: 'WH-001', itemName: 'Item', expected: 50),
        ],
      );

      container.read(activeReceiveNotifierProvider.notifier).startReceive(order);
      container
          .read(activeReceiveNotifierProvider.notifier)
          .confirmItem(itemCode: 'WH-001', received: 48);

      final state = container.read(activeReceiveNotifierProvider)!;
      expect(state.lineItems.first.received, equals(48));
      expect(state.lineItems.first.lineStatus, equals(PoLineItemStatus.confirmed));
    });

    test('flagItem marks item as flagged', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(itemCode: 'WH-001', itemName: 'Item', expected: 50),
        ],
      );

      container.read(activeReceiveNotifierProvider.notifier).startReceive(order);
      container
          .read(activeReceiveNotifierProvider.notifier)
          .flagItem(itemCode: 'WH-001');

      final state = container.read(activeReceiveNotifierProvider)!;
      expect(state.lineItems.first.flagged, isTrue);
      expect(state.lineItems.first.lineStatus, equals(PoLineItemStatus.flagged));
    });
  });

  group('ActiveReceiveNotifier.submitReceive', () {
    test('calls submitReceive on repo, refreshes orders, resets state to null', () async {
      when(() => mockRepo.submitReceive(any())).thenAnswer((_) async {});
      when(() => mockRepo.getPurchaseOrders()).thenAnswer((_) async => []);

      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
      );

      container.read(activeReceiveNotifierProvider.notifier).startReceive(order);
      await container.read(activeReceiveNotifierProvider.notifier).submitReceive();

      verify(() => mockRepo.submitReceive(any())).called(1);
      expect(container.read(activeReceiveNotifierProvider), isNull);
    });
  });
}
