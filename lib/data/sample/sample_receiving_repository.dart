import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/data/repositories/receiving_repository.dart';

class SampleReceivingRepository implements ReceivingRepository {
  final List<PurchaseOrder> _orders = [
    PurchaseOrder(
      id: 'PO-2041',
      supplier: 'Acme Supplies',
      status: PoStatus.inProgress,
      dueDate: DateTime(2026, 4, 18),
      lineItems: const [
        PoLineItem(
            itemCode: 'WH-00142',
            itemName: 'Aluminium Sheet 2mm',
            expected: 50),
        PoLineItem(
          itemCode: 'WH-00210',
          itemName: 'Copper Wire 4mm',
          expected: 100,
          received: 30,
          lineStatus: PoLineItemStatus.confirmed,
        ),
        PoLineItem(
            itemCode: 'WH-00089', itemName: 'Steel Bolt M8', expected: 200),
      ],
    ),
    PurchaseOrder(
      id: 'PO-2042',
      supplier: 'Metro Parts',
      status: PoStatus.inProgress,
      dueDate: DateTime(2026, 4, 18),
      lineItems: const [
        PoLineItem(
          itemCode: 'WH-00301',
          itemName: 'PVC Pipe 20mm',
          expected: 30,
          received: 10,
          lineStatus: PoLineItemStatus.confirmed,
        ),
        PoLineItem(
            itemCode: 'WH-00302', itemName: 'PVC Elbow 20mm', expected: 20),
      ],
    ),
    PurchaseOrder(
      id: 'PO-2043',
      supplier: 'Global Metals',
      status: PoStatus.pending,
      dueDate: DateTime(2026, 4, 19),
      lineItems: const [
        PoLineItem(
            itemCode: 'WH-00401', itemName: 'Stainless Rod 10mm', expected: 80),
        PoLineItem(
            itemCode: 'WH-00402', itemName: 'Hex Nut M10', expected: 500),
      ],
    ),
    PurchaseOrder(
      id: 'PO-2044',
      supplier: 'Mega Wholesale Sdn Bhd',
      status: PoStatus.pending,
      dueDate: DateTime(2026, 4, 22),
      lineItems: const [
        PoLineItem(
            itemCode: 'WH-00501', itemName: 'Safety Gloves L', expected: 40),
        PoLineItem(
            itemCode: 'WH-00502', itemName: 'Hard Hat Yellow', expected: 20),
        PoLineItem(
            itemCode: 'WH-00503', itemName: 'Reflective Vest', expected: 30),
      ],
    ),
    PurchaseOrder(
      id: 'PO-2039',
      supplier: 'Acme Supplies',
      status: PoStatus.received,
      dueDate: DateTime(2026, 4, 16),
      receivedAt: DateTime(2026, 4, 16, 10, 22),
      lineItems: const [
        PoLineItem(
          itemCode: 'WH-00089',
          itemName: 'Steel Bolt M8',
          expected: 100,
          received: 100,
          lineStatus: PoLineItemStatus.confirmed,
        ),
        PoLineItem(
          itemCode: 'WH-00090',
          itemName: 'Steel Washer M8',
          expected: 100,
          received: 95,
          lineStatus: PoLineItemStatus.confirmed,
        ),
      ],
    ),
    PurchaseOrder(
      id: 'PO-2037',
      supplier: 'Global Metals',
      status: PoStatus.received,
      dueDate: DateTime(2026, 4, 14),
      receivedAt: DateTime(2026, 4, 14, 14, 5),
      lineItems: const [
        PoLineItem(
          itemCode: 'WH-00210',
          itemName: 'Copper Wire 4mm',
          expected: 60,
          received: 60,
          lineStatus: PoLineItemStatus.confirmed,
        ),
      ],
    ),
  ];

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_orders);
  }

  @override
  Future<void> submitReceive(PurchaseOrder order) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _orders.indexWhere((o) => o.id == order.id);
    if (idx != -1) {
      _orders[idx] = PurchaseOrder(
        id: order.id,
        supplier: order.supplier,
        status: PoStatus.received,
        dueDate: order.dueDate,
        receivedAt: DateTime.now(),
        lineItems: order.lineItems,
      );
    }
  }
}
