import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/sample/sample_order_catalog.dart';
import 'package:warehouse_app/data/sample/sample_order_locations.dart';

abstract class OrdersRepository {
  Future<List<DeliveryOrder>> getDeliveryOrders({required bool active});
  Future<List<SalesOrder>> getSalesOrders({required bool active});
  Future<DeliveryOrder?> getDeliveryOrderById(String id);
  Future<SalesOrder?> getSalesOrderById(String id);

  /// Creates or updates the order with this id. An empty number means "give it one". [DeliveryOrder.status] is where the
  /// order should end up: draft, pendingApproval or submitted.
  Future<DeliveryOrder> saveDeliveryOrder(DeliveryOrder order);
  Future<SalesOrder> saveSalesOrder(SalesOrder order);
  Future<void> updateOrderStatus({required OrderKind kind, required String id, required OrderStatus status});

  /// Where goods can be picked from: bins first.
  Future<List<OrderLocation>> getPickLocations();
  Future<List<CatalogItem>> searchItems(String term);

  /// The item with this barcode or SKU.
  Future<CatalogItem?> findItem(String code);
}

class SampleOrdersRepository implements OrdersRepository {
  SampleOrdersRepository({this.userName = 'Hasan'});

  final String userName;
  final List<OrderLocation> _bins = List.unmodifiable(sampleOrderLocations);

  OrderItem _line(String id, String name, String sku, int quantity, int bin) => OrderItem(
        itemId: id,
        itemName: name,
        itemSku: sku,
        quantity: quantity,
        locationId: _bins[bin].id,
        locationCode: _bins[bin].name,
      );

  late final List<DeliveryOrder> _deliveryOrders = [
    DeliveryOrder(
      id: 'do-1',
      orderNumber: 'DO-2026-0001',
      destination: 'Outlet Damansara',
      deliveryDate: DateTime(2026, 4, 20),
      status: OrderStatus.submitted,
      requiresApproval: false,
      notes: 'Urgent outlet restock',
      createdBy: 'Aisyah',
      createdAt: DateTime(2026, 4, 18, 9, 0),
      items: [
        _line('C-001', 'Beras 5kg', 'SKU-BERAS-5KG', 8, 0),
        _line('C-002', 'Minyak Masak 5L', 'SKU-MINYAK-5L', 4, 0),
      ],
      statusHistory: [
        OrderStatusHistory(id: 'h-1', status: OrderStatus.submitted, changedBy: 'Aisyah', changedAt: DateTime(2026, 4, 18, 9, 0)),
      ],
    ),
    DeliveryOrder(
      id: 'do-2',
      orderNumber: 'DO-2026-0002',
      destination: 'Outlet Cheras',
      deliveryDate: DateTime(2026, 4, 21),
      status: OrderStatus.pendingApproval,
      requiresApproval: true,
      notes: 'Large transfer for promo weekend',
      createdBy: 'Irfan',
      createdAt: DateTime(2026, 4, 18, 11, 20),
      items: [
        _line('C-003', 'Gula Putih 1kg', 'SKU-GULA-1KG', 12, 1),
        _line('C-004', 'Tepung Gandum 1kg', 'SKU-TEPUNG-1KG', 10, 1),
      ],
      statusHistory: [
        OrderStatusHistory(id: 'h-2', status: OrderStatus.pendingApproval, changedBy: 'Irfan', changedAt: DateTime(2026, 4, 18, 11, 20)),
      ],
    ),
    DeliveryOrder(
      id: 'do-3',
      orderNumber: 'DO-2026-0003',
      destination: 'Outlet Subang',
      deliveryDate: DateTime(2026, 4, 17),
      status: OrderStatus.shipped,
      requiresApproval: false,
      createdBy: 'Hakim',
      createdAt: DateTime(2026, 4, 16, 14, 30),
      items: [_line('C-006', 'Mi Segera Kari', 'SKU-MI-KARI', 20, 2)],
      statusHistory: [
        OrderStatusHistory(id: 'h-3a', status: OrderStatus.submitted, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 16, 14, 30)),
        OrderStatusHistory(id: 'h-3b', status: OrderStatus.packed, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 16, 16, 0)),
        OrderStatusHistory(id: 'h-3c', status: OrderStatus.inTransit, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 17, 9, 10)),
        OrderStatusHistory(id: 'h-3d', status: OrderStatus.shipped, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 17, 13, 45)),
      ],
    ),
  ];

  late final List<SalesOrder> _salesOrders = [
    SalesOrder(
      id: 'so-1',
      orderNumber: 'SO-2026-0001',
      customerName: 'Kedai Maju Jaya',
      orderDate: DateTime(2026, 4, 19),
      status: OrderStatus.draft,
      requiresApproval: false,
      notes: 'Waiting for final confirmation',
      createdBy: 'Aisyah',
      createdAt: DateTime(2026, 4, 19, 8, 30),
      items: [_line('C-005', 'Susu Pekat 500g', 'SKU-SUSU-500G', 6, 0)],
      statusHistory: [
        OrderStatusHistory(id: 's-1', status: OrderStatus.draft, changedBy: 'Aisyah', changedAt: DateTime(2026, 4, 19, 8, 30)),
      ],
    ),
    SalesOrder(
      id: 'so-2',
      orderNumber: 'SO-2026-0002',
      customerName: 'Restoran Seri Damai',
      orderDate: DateTime(2026, 4, 18),
      status: OrderStatus.packed,
      requiresApproval: false,
      notes: 'Deliver before noon',
      createdBy: 'Hakim',
      createdAt: DateTime(2026, 4, 18, 10, 15),
      items: [
        _line('C-007', 'Air Mineral 1.5L', 'SKU-AIR-15L', 15, 1),
        _line('C-010', 'Biskut Kraker 300g', 'SKU-BISKUT-300G', 10, 1),
      ],
      statusHistory: [
        OrderStatusHistory(id: 's-2a', status: OrderStatus.submitted, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 18, 10, 15)),
        OrderStatusHistory(id: 's-2b', status: OrderStatus.packed, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 18, 12, 40)),
      ],
    ),
    SalesOrder(
      id: 'so-3',
      orderNumber: 'SO-2026-0003',
      customerName: 'Cafe Sentral',
      orderDate: DateTime(2026, 4, 16),
      status: OrderStatus.shipped,
      requiresApproval: true,
      createdBy: 'Irfan',
      createdAt: DateTime(2026, 4, 16, 9, 5),
      items: [
        _line('C-008', 'Sardin Tin 425g', 'SKU-SARDIN-425G', 18, 2),
        _line('C-009', 'Kopi O 200g', 'SKU-KOPI-200G', 8, 2),
      ],
      statusHistory: [
        OrderStatusHistory(id: 's-3a', status: OrderStatus.pendingApproval, changedBy: 'Irfan', changedAt: DateTime(2026, 4, 16, 9, 5)),
        OrderStatusHistory(id: 's-3b', status: OrderStatus.submitted, changedBy: 'Nadia', changedAt: DateTime(2026, 4, 16, 9, 45)),
        OrderStatusHistory(id: 's-3c', status: OrderStatus.packed, changedBy: 'Nadia', changedAt: DateTime(2026, 4, 16, 11, 15)),
        OrderStatusHistory(id: 's-3d', status: OrderStatus.inTransit, changedBy: 'Nadia', changedAt: DateTime(2026, 4, 16, 12, 30)),
        OrderStatusHistory(id: 's-3e', status: OrderStatus.shipped, changedBy: 'Nadia', changedAt: DateTime(2026, 4, 16, 15, 0)),
      ],
    ),
  ];

  @override
  Future<List<DeliveryOrder>> getDeliveryOrders({required bool active}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _deliveryOrders.where((o) => o.status.isActive == active).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<SalesOrder>> getSalesOrders({required bool active}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _salesOrders.where((o) => o.status.isActive == active).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<DeliveryOrder?> getDeliveryOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    for (final order in _deliveryOrders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<SalesOrder?> getSalesOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    for (final order in _salesOrders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<DeliveryOrder> saveDeliveryOrder(DeliveryOrder order) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _deliveryOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      final current = _deliveryOrders[index];
      final saved = order.copyWith(
        orderNumber: current.orderNumber,
        createdBy: current.createdBy,
        createdAt: current.createdAt,
        statusHistory: _moved(current.statusHistory, current.status, order.status),
      );
      _deliveryOrders[index] = saved;
      return saved;
    }
    final now = DateTime.now();
    final saved = order.copyWith(
      orderNumber: 'DO-${now.year}-${(_deliveryOrders.length + 1).toString().padLeft(4, '0')}',
      createdBy: userName,
      createdAt: now,
      statusHistory: [OrderStatusHistory(id: '${order.id}-0', status: order.status, changedBy: userName, changedAt: now)],
    );
    _deliveryOrders.insert(0, saved);
    return saved;
  }

  @override
  Future<SalesOrder> saveSalesOrder(SalesOrder order) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _salesOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      final current = _salesOrders[index];
      final saved = order.copyWith(
        orderNumber: current.orderNumber,
        createdBy: current.createdBy,
        createdAt: current.createdAt,
        statusHistory: _moved(current.statusHistory, current.status, order.status),
      );
      _salesOrders[index] = saved;
      return saved;
    }
    final now = DateTime.now();
    final saved = order.copyWith(
      orderNumber: 'SO-${now.year}-${(_salesOrders.length + 1).toString().padLeft(4, '0')}',
      createdBy: userName,
      createdAt: now,
      statusHistory: [OrderStatusHistory(id: '${order.id}-0', status: order.status, changedBy: userName, changedAt: now)],
    );
    _salesOrders.insert(0, saved);
    return saved;
  }

  @override
  Future<void> updateOrderStatus({required OrderKind kind, required String id, required OrderStatus status}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (kind == OrderKind.delivery) {
      final index = _deliveryOrders.indexWhere((o) => o.id == id);
      if (index == -1) return;
      final current = _deliveryOrders[index];
      _deliveryOrders[index] = current.copyWith(status: status, statusHistory: _moved(current.statusHistory, current.status, status));
      return;
    }
    final index = _salesOrders.indexWhere((o) => o.id == id);
    if (index == -1) return;
    final current = _salesOrders[index];
    _salesOrders[index] = current.copyWith(status: status, statusHistory: _moved(current.statusHistory, current.status, status));
  }

  List<OrderStatusHistory> _moved(List<OrderStatusHistory> history, OrderStatus from, OrderStatus to) => from == to
      ? history
      : [
          ...history,
          OrderStatusHistory(id: 'h-${DateTime.now().microsecondsSinceEpoch}', status: to, changedBy: userName, changedAt: DateTime.now()),
        ];

  @override
  Future<List<OrderLocation>> getPickLocations() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _bins;
  }

  @override
  Future<List<CatalogItem>> searchItems(String term) async {
    final query = term.trim().toLowerCase();
    return [
      for (final item in sampleOrderCatalog)
        if (query.isEmpty || item.name.toLowerCase().contains(query) || item.sku.toLowerCase().contains(query)) item,
    ];
  }

  @override
  Future<CatalogItem?> findItem(String code) async {
    for (final item in sampleOrderCatalog) {
      if (item.sku == code.trim()) return item;
    }
    return null;
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  throw UnimplementedError('ordersRepositoryProvider not overridden');
});

/// Read again for each new order and whenever the warehouse changes, so a pull or a switch never leaves old bins behind.
final pickLocationsProvider = FutureProvider.autoDispose<List<OrderLocation>>((ref) {
  ref.watch(authNotifierProvider.select((auth) => auth.valueOrNull?.warehouseId));
  return ref.watch(ordersRepositoryProvider).getPickLocations();
});

final orderCatalogSearchProvider = FutureProvider.autoDispose.family<List<CatalogItem>, String>(
  (ref, term) => ref.watch(ordersRepositoryProvider).searchItems(term),
);
