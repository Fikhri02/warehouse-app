import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/data/repositories/receiving_repository.dart';

class SampleReceivingRepository implements ReceivingRepository {
  final List<PurchaseOrder> _orders = [
    const PurchaseOrder(
      id: 'PO-2041',
      supplier: 'Acme Supplies',
      status: PoStatus.pending,
      lineItems: [
        PoLineItem(itemCode: 'WH-00142', itemName: 'Aluminium Sheet 2mm', expected: 50),
        PoLineItem(itemCode: 'WH-00210', itemName: 'Copper Wire 4mm', expected: 100),
        PoLineItem(itemCode: 'WH-00089', itemName: 'Steel Bolt M8', expected: 200),
      ],
    ),
    const PurchaseOrder(
      id: 'PO-2038',
      supplier: 'Metro Parts',
      status: PoStatus.pending,
      lineItems: [
        PoLineItem(itemCode: 'WH-00301', itemName: 'PVC Pipe 20mm', expected: 30),
      ],
    ),
    const PurchaseOrder(
      id: 'PO-2035',
      supplier: 'Global Metals',
      status: PoStatus.received,
      lineItems: [
        PoLineItem(
          itemCode: 'WH-00089',
          itemName: 'Steel Bolt M8',
          expected: 100,
          received: 100,
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
        lineItems: order.lineItems,
      );
    }
  }
}
