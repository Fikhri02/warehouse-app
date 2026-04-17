import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';

void main() {
  group('CountItem', () {
    test('variance is counted minus expected', () {
      final item = CountItem(
        itemCode: 'WH-001',
        itemName: 'Test Item',
        expected: 50,
        counted: 48,
      );
      expect(item.variance, equals(-2));
    });

    test('matched is true when variance is zero', () {
      final item = CountItem(
        itemCode: 'WH-001',
        itemName: 'Test Item',
        expected: 50,
        counted: 50,
      );
      expect(item.matched, isTrue);
    });

    test('matched is false when variance is non-zero', () {
      final item = CountItem(
        itemCode: 'WH-001',
        itemName: 'Test Item',
        expected: 50,
        counted: 45,
      );
      expect(item.matched, isFalse);
    });
  });

  group('CountSession.copyWith', () {
    test('copyWith updates status without changing other fields', () {
      final session = CountSession(
        id: 's001',
        location: 'Aisle A',
        startedAt: DateTime(2026, 4, 15),
        status: CountSessionStatus.inProgress,
      );
      final submitted = session.copyWith(status: CountSessionStatus.submitted);
      expect(submitted.status, equals(CountSessionStatus.submitted));
      expect(submitted.location, equals('Aisle A'));
      expect(submitted.id, equals('s001'));
    });
  });

  group('PurchaseOrder', () {
    test('hasFlagged is true when any line item is flagged', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Test',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(itemCode: 'WH-001', itemName: 'Item', expected: 10, flagged: true),
          PoLineItem(itemCode: 'WH-002', itemName: 'Item 2', expected: 5),
        ],
      );
      expect(order.hasFlagged, isTrue);
    });

    test('hasFlagged is false when no line items are flagged', () {
      const order = PurchaseOrder(
        id: 'PO-001',
        supplier: 'Test',
        status: PoStatus.pending,
        lineItems: [
          PoLineItem(itemCode: 'WH-001', itemName: 'Item', expected: 10),
        ],
      );
      expect(order.hasFlagged, isFalse);
    });

    test('PoLineItem.variance is received minus expected', () {
      const item = PoLineItem(
        itemCode: 'WH-001',
        itemName: 'Item',
        expected: 100,
        received: 80,
      );
      expect(item.variance, equals(-20));
    });
  });
}
