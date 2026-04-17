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

  group('PurchaseOrder computed getters', () {
    test('shortItems returns items where received < expected', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(
              itemCode: 'A', itemName: 'Item A', expected: 10, received: 6),
          PoLineItem(
              itemCode: 'B', itemName: 'Item B', expected: 5, received: 5),
          PoLineItem(
              itemCode: 'C', itemName: 'Item C', expected: 3, received: 4),
        ],
      );

      expect(order.shortItems.map((i) => i.itemCode), equals(['A']));
    });

    test('extraItems returns items where received > expected', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(
              itemCode: 'A', itemName: 'Item A', expected: 10, received: 6),
          PoLineItem(
              itemCode: 'C', itemName: 'Item C', expected: 3, received: 4),
        ],
      );

      expect(order.extraItems.map((i) => i.itemCode), equals(['C']));
    });

    test('allFulfilled is true when all items received exactly', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(
              itemCode: 'A', itemName: 'Item A', expected: 5, received: 5),
          PoLineItem(
              itemCode: 'B', itemName: 'Item B', expected: 3, received: 3),
        ],
      );

      expect(order.allFulfilled, isTrue);
    });
  });

  group('ActiveReceiveNotifier.scanItem', () {
    test('increments received qty by 1 on each scan for matching itemCode', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(itemCode: 'WH-001', itemName: 'Item A', expected: 10),
        ],
      );

      container
          .read(activeReceiveNotifierProvider.notifier)
          .startReceive(order);
      container.read(activeReceiveNotifierProvider.notifier).scanItem('WH-001');
      container.read(activeReceiveNotifierProvider.notifier).scanItem('WH-001');

      final item =
          container.read(activeReceiveNotifierProvider)!.lineItems.first;
      expect(item.received, equals(2));
      expect(item.lineStatus, equals(PoLineItemStatus.confirmed));
    });

    test('returns false for unknown barcode', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(itemCode: 'WH-001', itemName: 'Item A', expected: 5),
        ],
      );

      container
          .read(activeReceiveNotifierProvider.notifier)
          .startReceive(order);
      final found = container
          .read(activeReceiveNotifierProvider.notifier)
          .scanItem('UNKNOWN-999');

      expect(found, isFalse);
    });
  });

  group('ActiveReceiveNotifier.flagItemWithReason', () {
    test('stores flagReason on the line item', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(itemCode: 'WH-001', itemName: 'Item A', expected: 5),
        ],
      );

      container
          .read(activeReceiveNotifierProvider.notifier)
          .startReceive(order);
      container.read(activeReceiveNotifierProvider.notifier).flagItemWithReason(
            itemCode: 'WH-001',
            reason: 'Damaged / Poor condition',
          );

      final item =
          container.read(activeReceiveNotifierProvider)!.lineItems.first;
      expect(item.flagged, isTrue);
      expect(item.flagReason, equals('Damaged / Poor condition'));
      expect(item.lineStatus, equals(PoLineItemStatus.flagged));
    });
  });

  group('ActiveReceiveNotifier.addUnknownItem', () {
    test('appends item with expected 0 and received qty', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
        lineItems: [],
      );

      container
          .read(activeReceiveNotifierProvider.notifier)
          .startReceive(order);
      container.read(activeReceiveNotifierProvider.notifier).addUnknownItem(
            itemCode: 'UNK-001',
            itemName: 'Unknown Item',
            qty: 3,
          );

      final items = container.read(activeReceiveNotifierProvider)!.lineItems;
      expect(items.length, equals(1));
      expect(items.first.expected, equals(0));
      expect(items.first.received, equals(3));
      expect(items.first.lineStatus, equals(PoLineItemStatus.confirmed));
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

      container
          .read(activeReceiveNotifierProvider.notifier)
          .startReceive(order);
      container
          .read(activeReceiveNotifierProvider.notifier)
          .confirmItem(itemCode: 'WH-001', received: 48);

      final state = container.read(activeReceiveNotifierProvider)!;
      expect(state.lineItems.first.received, equals(48));
      expect(
          state.lineItems.first.lineStatus, equals(PoLineItemStatus.confirmed));
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

      container
          .read(activeReceiveNotifierProvider.notifier)
          .startReceive(order);
      container
          .read(activeReceiveNotifierProvider.notifier)
          .flagItem(itemCode: 'WH-001');

      final state = container.read(activeReceiveNotifierProvider)!;
      expect(state.lineItems.first.flagged, isTrue);
      expect(
          state.lineItems.first.lineStatus, equals(PoLineItemStatus.flagged));
    });
  });

  group('ActiveReceiveNotifier.submitReceive', () {
    test('calls submitReceive on repo, refreshes orders, resets state to null',
        () async {
      when(() => mockRepo.submitReceive(any())).thenAnswer((_) async {});
      when(() => mockRepo.getPurchaseOrders()).thenAnswer((_) async => []);

      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Acme',
        status: PoStatus.pending,
      );

      container
          .read(activeReceiveNotifierProvider.notifier)
          .startReceive(order);
      await container
          .read(activeReceiveNotifierProvider.notifier)
          .submitReceive();

      verify(() => mockRepo.submitReceive(any())).called(1);
      expect(container.read(activeReceiveNotifierProvider), isNull);
    });
  });
}
