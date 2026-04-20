import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/sample/sample_order_locations.dart';

abstract class OrdersRepository {
  Future<List<DeliveryOrder>> getDeliveryOrders({required bool active});
  Future<List<SalesOrder>> getSalesOrders({required bool active});
  Future<DeliveryOrder?> getDeliveryOrderById(int id);
  Future<SalesOrder?> getSalesOrderById(int id);
  Future<DeliveryOrder> createDeliveryOrder(
    DeliveryOrder order, {
    int? existingOrderId,
  });
  Future<SalesOrder> createSalesOrder(
    SalesOrder order, {
    int? existingOrderId,
  });
  Future<void> updateOrderStatus({
    required String orderType,
    required int id,
    required OrderStatus status,
    String changedBy,
  });
  Future<List<OrderLocation>> getLocations();
}

class SampleOrdersRepository implements OrdersRepository {
  SampleOrdersRepository();

  final List<OrderLocation> _locations =
      List.unmodifiable(sampleOrderLocations);
  late final List<DeliveryOrder> _deliveryOrders = [
    DeliveryOrder(
      id: 1,
      orderNumber: 'DO-2026-0001',
      fromLocation: _locations.first,
      toLocation: _locations[2],
      deliveryDate: DateTime(2026, 4, 20),
      status: OrderStatus.submitted,
      requiresApproval: false,
      notes: 'Urgent outlet restock',
      createdBy: 'Aisyah',
      createdAt: DateTime(2026, 4, 18, 9, 0),
      items: const [
        OrderItem(
          itemId: 'C-001',
          itemName: 'Beras 5kg',
          itemSku: 'SKU-BERAS-5KG',
          quantity: 8,
        ),
        OrderItem(
          itemId: 'C-002',
          itemName: 'Minyak Masak 5L',
          itemSku: 'SKU-MINYAK-5L',
          quantity: 4,
        ),
      ],
      statusHistory: [
        OrderStatusHistory(
          id: 'h-1',
          status: OrderStatus.submitted,
          changedBy: 'Aisyah',
          changedAt: DateTime(2026, 4, 18, 9, 0),
        ),
      ],
    ),
    DeliveryOrder(
      id: 2,
      orderNumber: 'DO-2026-0002',
      fromLocation: _locations[1],
      toLocation: _locations[4],
      deliveryDate: DateTime(2026, 4, 21),
      status: OrderStatus.pendingApproval,
      requiresApproval: true,
      notes: 'Large transfer for promo weekend',
      createdBy: 'Irfan',
      createdAt: DateTime(2026, 4, 18, 11, 20),
      items: const [
        OrderItem(
          itemId: 'C-003',
          itemName: 'Gula Putih 1kg',
          itemSku: 'SKU-GULA-1KG',
          quantity: 12,
        ),
        OrderItem(
          itemId: 'C-004',
          itemName: 'Tepung Gandum 1kg',
          itemSku: 'SKU-TEPUNG-1KG',
          quantity: 10,
        ),
      ],
      statusHistory: [
        OrderStatusHistory(
          id: 'h-2',
          status: OrderStatus.pendingApproval,
          changedBy: 'Irfan',
          changedAt: DateTime(2026, 4, 18, 11, 20),
        ),
      ],
    ),
    DeliveryOrder(
      id: 3,
      orderNumber: 'DO-2026-0003',
      fromLocation: _locations.first,
      toLocation: _locations[3],
      deliveryDate: DateTime(2026, 4, 17),
      status: OrderStatus.shipped,
      requiresApproval: false,
      notes: null,
      createdBy: 'Hakim',
      createdAt: DateTime(2026, 4, 16, 14, 30),
      items: const [
        OrderItem(
          itemId: 'C-006',
          itemName: 'Mi Segera Kari',
          itemSku: 'SKU-MI-KARI',
          quantity: 20,
        ),
      ],
      statusHistory: [
        OrderStatusHistory(
          id: 'h-3a',
          status: OrderStatus.submitted,
          changedBy: 'Hakim',
          changedAt: DateTime(2026, 4, 16, 14, 30),
        ),
        OrderStatusHistory(
          id: 'h-3b',
          status: OrderStatus.packed,
          changedBy: 'Hakim',
          changedAt: DateTime(2026, 4, 16, 16, 0),
        ),
        OrderStatusHistory(
          id: 'h-3c',
          status: OrderStatus.inTransit,
          changedBy: 'Hakim',
          changedAt: DateTime(2026, 4, 17, 9, 10),
        ),
        OrderStatusHistory(
          id: 'h-3d',
          status: OrderStatus.shipped,
          changedBy: 'Hakim',
          changedAt: DateTime(2026, 4, 17, 13, 45),
        ),
      ],
    ),
  ];
  late final List<SalesOrder> _salesOrders = [
    SalesOrder(
      id: 1,
      orderNumber: 'SO-2026-0001',
      customerName: 'Kedai Maju Jaya',
      orderDate: DateTime(2026, 4, 19),
      status: OrderStatus.draft,
      requiresApproval: false,
      notes: 'Waiting for final confirmation',
      createdBy: 'Aisyah',
      createdAt: DateTime(2026, 4, 19, 8, 30),
      items: const [
        OrderItem(
          itemId: 'C-005',
          itemName: 'Susu Pekat 500g',
          itemSku: 'SKU-SUSU-500G',
          quantity: 6,
        ),
      ],
      statusHistory: [
        OrderStatusHistory(
          id: 's-1',
          status: OrderStatus.draft,
          changedBy: 'Aisyah',
          changedAt: DateTime(2026, 4, 19, 8, 30),
        ),
      ],
    ),
    SalesOrder(
      id: 2,
      orderNumber: 'SO-2026-0002',
      customerName: 'Restoran Seri Damai',
      orderDate: DateTime(2026, 4, 18),
      status: OrderStatus.packed,
      requiresApproval: false,
      notes: 'Deliver before noon',
      createdBy: 'Hakim',
      createdAt: DateTime(2026, 4, 18, 10, 15),
      items: const [
        OrderItem(
          itemId: 'C-007',
          itemName: 'Air Mineral 1.5L',
          itemSku: 'SKU-AIR-15L',
          quantity: 15,
        ),
        OrderItem(
          itemId: 'C-010',
          itemName: 'Biskut Kraker 300g',
          itemSku: 'SKU-BISKUT-300G',
          quantity: 10,
        ),
      ],
      statusHistory: [
        OrderStatusHistory(
          id: 's-2a',
          status: OrderStatus.submitted,
          changedBy: 'Hakim',
          changedAt: DateTime(2026, 4, 18, 10, 15),
        ),
        OrderStatusHistory(
          id: 's-2b',
          status: OrderStatus.packed,
          changedBy: 'Hakim',
          changedAt: DateTime(2026, 4, 18, 12, 40),
        ),
      ],
    ),
    SalesOrder(
      id: 3,
      orderNumber: 'SO-2026-0003',
      customerName: 'Cafe Sentral',
      orderDate: DateTime(2026, 4, 16),
      status: OrderStatus.shipped,
      requiresApproval: true,
      notes: null,
      createdBy: 'Irfan',
      createdAt: DateTime(2026, 4, 16, 9, 5),
      items: const [
        OrderItem(
          itemId: 'C-008',
          itemName: 'Sardin Tin 425g',
          itemSku: 'SKU-SARDIN-425G',
          quantity: 18,
        ),
        OrderItem(
          itemId: 'C-009',
          itemName: 'Kopi O 200g',
          itemSku: 'SKU-KOPI-200G',
          quantity: 8,
        ),
      ],
      statusHistory: [
        OrderStatusHistory(
          id: 's-3a',
          status: OrderStatus.pendingApproval,
          changedBy: 'Irfan',
          changedAt: DateTime(2026, 4, 16, 9, 5),
        ),
        OrderStatusHistory(
          id: 's-3b',
          status: OrderStatus.submitted,
          changedBy: 'Nadia',
          changedAt: DateTime(2026, 4, 16, 9, 45),
        ),
        OrderStatusHistory(
          id: 's-3c',
          status: OrderStatus.packed,
          changedBy: 'Nadia',
          changedAt: DateTime(2026, 4, 16, 11, 15),
        ),
        OrderStatusHistory(
          id: 's-3d',
          status: OrderStatus.inTransit,
          changedBy: 'Nadia',
          changedAt: DateTime(2026, 4, 16, 12, 30),
        ),
        OrderStatusHistory(
          id: 's-3e',
          status: OrderStatus.shipped,
          changedBy: 'Nadia',
          changedAt: DateTime(2026, 4, 16, 15, 0),
        ),
      ],
    ),
  ];

  int _nextDeliveryId = 4;
  int _nextSalesId = 4;

  @override
  Future<List<DeliveryOrder>> getDeliveryOrders({required bool active}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _deliveryOrders
        .where((order) => order.status.isActive == active)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<SalesOrder>> getSalesOrders({required bool active}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _salesOrders
        .where((order) => order.status.isActive == active)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<DeliveryOrder?> getDeliveryOrderById(int id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _findDelivery(id);
  }

  @override
  Future<SalesOrder?> getSalesOrderById(int id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _findSales(id);
  }

  @override
  Future<DeliveryOrder> createDeliveryOrder(
    DeliveryOrder order, {
    int? existingOrderId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final status = order.status;
    if (existingOrderId != null) {
      final index = _deliveryOrders
          .indexWhere((element) => element.id == existingOrderId);
      final updated = order.copyWith(
        id: existingOrderId,
        orderNumber: _deliveryOrders[index].orderNumber,
      );
      if (index != -1) {
        _deliveryOrders[index] = updated;
        return updated;
      }
    }

    final id = _nextDeliveryId++;
    final created = order.copyWith(
      id: id,
      orderNumber: _deliveryOrderNumber(id),
      statusHistory: [
        OrderStatusHistory(
          id: 'do-$id-${DateTime.now().millisecondsSinceEpoch}',
          status: status,
          changedBy: order.createdBy,
          changedAt: DateTime.now(),
        ),
      ],
    );
    _deliveryOrders.insert(0, created);
    return created;
  }

  @override
  Future<SalesOrder> createSalesOrder(
    SalesOrder order, {
    int? existingOrderId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final status = order.status;
    if (existingOrderId != null) {
      final index =
          _salesOrders.indexWhere((element) => element.id == existingOrderId);
      final updated = order.copyWith(
        id: existingOrderId,
        orderNumber: _salesOrders[index].orderNumber,
      );
      if (index != -1) {
        _salesOrders[index] = updated;
        return updated;
      }
    }

    final id = _nextSalesId++;
    final created = order.copyWith(
      id: id,
      orderNumber: _salesOrderNumber(id),
      statusHistory: [
        OrderStatusHistory(
          id: 'so-$id-${DateTime.now().millisecondsSinceEpoch}',
          status: status,
          changedBy: order.createdBy,
          changedAt: DateTime.now(),
        ),
      ],
    );
    _salesOrders.insert(0, created);
    return created;
  }

  @override
  Future<void> updateOrderStatus({
    required String orderType,
    required int id,
    required OrderStatus status,
    String changedBy = 'Current User',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (orderType == 'delivery') {
      final index = _deliveryOrders.indexWhere((order) => order.id == id);
      if (index == -1) return;
      final current = _deliveryOrders[index];
      _deliveryOrders[index] = current.copyWith(
        status: status,
        statusHistory: [
          ...current.statusHistory,
          OrderStatusHistory(
            id: 'do-$id-${DateTime.now().millisecondsSinceEpoch}',
            status: status,
            changedBy: changedBy,
            changedAt: DateTime.now(),
          ),
        ],
      );
      return;
    }

    final index = _salesOrders.indexWhere((order) => order.id == id);
    if (index == -1) return;
    final current = _salesOrders[index];
    _salesOrders[index] = current.copyWith(
      status: status,
      statusHistory: [
        ...current.statusHistory,
        OrderStatusHistory(
          id: 'so-$id-${DateTime.now().millisecondsSinceEpoch}',
          status: status,
          changedBy: changedBy,
          changedAt: DateTime.now(),
        ),
      ],
    );
  }

  @override
  Future<List<OrderLocation>> getLocations() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _locations;
  }

  DeliveryOrder? _findDelivery(int id) {
    for (final order in _deliveryOrders) {
      if (order.id == id) return order;
    }
    return null;
  }

  SalesOrder? _findSales(int id) {
    for (final order in _salesOrders) {
      if (order.id == id) return order;
    }
    return null;
  }

  String _deliveryOrderNumber(int id) =>
      'DO-${DateTime.now().year}-${id.toString().padLeft(4, '0')}';

  String _salesOrderNumber(int id) =>
      'SO-${DateTime.now().year}-${id.toString().padLeft(4, '0')}';
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  throw UnimplementedError('ordersRepositoryProvider not overridden');
});
