import 'dart:convert';

import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

/// Delivery and sales orders against the server. Orders come from the phone's copy, with this phone's saves and status
/// changes that the copy doesn't show yet laid on top, oldest first. Saves and status changes go through the outbox.
class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository({required AppDatabase db, required UserSession? Function() session, required void Function() onQueued})
      : _db = db,
        _session = session,
        _onQueued = onQueued;

  final AppDatabase _db;
  final UserSession? Function() _session;
  final void Function() _onQueued;

  @override
  Future<List<DeliveryOrder>> getDeliveryOrders({required bool active}) async => [
        for (final o in await _orders(OrderKind.delivery))
          if (o.status.isActive == active) _delivery(o),
      ];

  @override
  Future<List<SalesOrder>> getSalesOrders({required bool active}) async => [
        for (final o in await _orders(OrderKind.sales))
          if (o.status.isActive == active) _sales(o),
      ];

  @override
  Future<DeliveryOrder?> getDeliveryOrderById(String id) async {
    final o = _find(await _orders(OrderKind.delivery), id);
    return o == null ? null : _delivery(o);
  }

  @override
  Future<SalesOrder?> getSalesOrderById(String id) async {
    final o = _find(await _orders(OrderKind.sales), id);
    return o == null ? null : _sales(o);
  }

  @override
  Future<DeliveryOrder> saveDeliveryOrder(DeliveryOrder order) async {
    await _save(OrderKind.delivery, order.id, order.status, {
      'number': order.orderNumber.isEmpty ? _number('DO', order.id) : order.orderNumber,
      'destination': order.destination.trim(),
      'deliveryDate': _day(order.deliveryDate),
      'requiresApproval': order.requiresApproval,
      'notes': order.notes,
      'lines': _lines(order.items),
    });
    return (await getDeliveryOrderById(order.id))!;
  }

  @override
  Future<SalesOrder> saveSalesOrder(SalesOrder order) async {
    await _save(OrderKind.sales, order.id, order.status, {
      'number': order.orderNumber.isEmpty ? _number('SO', order.id) : order.orderNumber,
      'customerName': order.customerName.trim(),
      'orderDate': _day(order.orderDate),
      'requiresApproval': order.requiresApproval,
      'notes': order.notes,
      'lines': _lines(order.items),
    });
    return (await getSalesOrderById(order.id))!;
  }

  @override
  Future<void> updateOrderStatus({required OrderKind kind, required String id, required OrderStatus status}) async {
    final session = _session();
    final warehouseId = session?.warehouseId;
    if (session == null || warehouseId == null) throw StateError('No warehouse chosen.');
    final current = _find(await _orders(kind), id);
    if (current == null) throw StateError('This order is no longer on the phone.');
    if (current.status == OrderStatus.pendingApproval && status == OrderStatus.submitted && session.role != UserRole.supervisor) {
      throw StateError('Only a supervisor can approve this order.');
    }
    await _queueStatus(kind, id, warehouseId, status, current.number);
    _onQueued();
  }

  @override
  Future<List<OrderLocation>> getPickLocations() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final locations = [
      for (final l in await _db.serverMirrorDao.locationsFor(warehouseId)) OrderLocation(id: l.id, name: l.code, type: l.type),
    ];
    locations.sort((a, b) => (a.type == 'Bin' ? 0 : 1).compareTo(b.type == 'Bin' ? 0 : 1)); // stable: codes stay in order
    return locations;
  }

  @override
  Future<List<CatalogItem>> searchItems(String term) async => [
        for (final i in await _db.serverMirrorDao.searchItems(term)) CatalogItem(id: i.id, name: i.name, sku: i.sku),
      ];

  @override
  Future<CatalogItem?> findItem(String code) async {
    final dao = _db.serverMirrorDao;
    final trimmed = code.trim();
    var row = await dao.itemByBarcode(trimmed);
    if (row == null) {
      for (final candidate in await dao.searchItems(trimmed)) {
        if (candidate.sku.toLowerCase() == trimmed.toLowerCase()) row = candidate;
      }
    }
    return row == null ? null : CatalogItem(id: row.id, name: row.name, sku: row.sku);
  }

  Future<void> _save(OrderKind kind, String id, OrderStatus target, Map<String, Object?> body) async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) throw StateError('No warehouse chosen.');
    final current = _find(await _orders(kind), id);
    if (current != null && current.status != OrderStatus.draft) throw StateError('Only a draft order can be changed.');
    if (current != null && current.requiresApproval && body['requiresApproval'] == false && _session()?.role != UserRole.supervisor) {
      throw StateError('Only a supervisor can take approval off this order.');
    }
    final save = await _db.syncQueueDao.enqueue(
      operationType: SyncOps.orderSave,
      referenceId: id,
      warehouseId: warehouseId,
      payload: jsonEncode({'kind': kind.serverName, 'body': body}),
    );
    if (target != OrderStatus.draft) await _queueStatus(kind, id, warehouseId, target, body['number'] as String, afterSave: save);
    _onQueued();
  }

  /// [afterSave] is the save queued with this change: if the server refuses that save, this change is held too.
  Future<void> _queueStatus(OrderKind kind, String id, String warehouseId, OrderStatus status, String number, {int? afterSave}) =>
      _db.syncQueueDao.enqueue(
        operationType: SyncOps.orderStatus,
        referenceId: id,
        warehouseId: warehouseId,
        payload: jsonEncode({
          'kind': kind.serverName,
          'status': status.serverName,
          'changedAt': DateTime.now().toUtc().toIso8601String(),
          'number': number,
          if (afterSave != null) 'afterSave': afterSave,
        }),
      );

  List<Map<String, Object?>> _lines(List<OrderItem> items) {
    final lines = <Map<String, Object?>>[];
    for (final item in items) {
      if (item.locationId == null) throw StateError('${item.itemName}: choose the bin to pick it from.');
      if (item.quantity <= 0) throw StateError('${item.itemName}: the quantity must be more than 0.');
      lines.add({'itemId': item.itemId, 'locationId': item.locationId, 'quantity': item.quantity});
    }
    if (lines.isEmpty) throw StateError('Add at least one item.');
    return lines;
  }

  /// The server's copy, with this phone's changes it doesn't show yet laid on top in the order they were made.
  Future<List<_Order>> _orders(OrderKind kind) async {
    final session = _session();
    final warehouseId = session?.warehouseId;
    if (session == null || warehouseId == null) return const [];
    final dao = _db.serverMirrorDao;
    final byId = <String, _Order>{};
    for (final row in await dao.orders(warehouseId, kind: kind.serverName)) {
      byId[row.id] = _Order(
        id: row.id,
        number: row.number,
        destination: row.destination,
        customerName: row.customerName,
        date: row.orderDate,
        status: OrderStatus.fromServer(row.status),
        requiresApproval: row.requiresApproval,
        notes: row.notes,
        createdBy: row.createdByName,
        createdAt: row.createdAt,
        items: [for (final l in await dao.orderLinesFor(row.id)) await _item(l.itemId, l.locationId, l.quantity.round())],
        history: [
          for (final h in (jsonDecode(row.statusHistory) as List).cast<Map<String, dynamic>>())
            OrderStatusHistory(
              id: '${row.id}-${h['changedAt']}',
              status: OrderStatus.fromServer(h['status'] as String),
              changedBy: h['changedByName'] as String,
              changedAt: DateTime.parse(h['changedAt'] as String).toLocal(),
            ),
        ],
      );
    }

    final queue = _db.syncQueueDao;
    final caughtUp = await dao.caughtUpThrough(warehouseId);
    final waiting = [
      ...await queue.notYetInCopy(SyncOps.orderSave, warehouseId: warehouseId, caughtUpThrough: caughtUp),
      ...await queue.notYetInCopy(SyncOps.orderStatus, warehouseId: warehouseId, caughtUpThrough: caughtUp),
    ]..sort((a, b) => a.id.compareTo(b.id));
    for (final command in waiting) {
      final payload = jsonDecode(command.payload) as Map<String, dynamic>;
      if (payload['kind'] != kind.serverName) continue;
      if (command.operationType == SyncOps.orderSave) {
        final body = payload['body'] as Map<String, dynamic>;
        final items = [
          for (final l in (body['lines'] as List).cast<Map<String, dynamic>>())
            await _item(l['itemId'] as String, l['locationId'] as String, (l['quantity'] as num).round()),
        ];
        final existing = byId[command.referenceId];
        final saved = _Order(
          id: command.referenceId,
          number: body['number'] as String,
          destination: body['destination'] as String?,
          customerName: body['customerName'] as String?,
          date: DateTime.parse((body['deliveryDate'] ?? body['orderDate']) as String),
          status: existing?.status ?? OrderStatus.draft,
          requiresApproval: body['requiresApproval'] as bool,
          notes: body['notes'] as String?,
          createdBy: existing?.createdBy ?? session.name,
          createdAt: existing?.createdAt ?? command.queuedAt,
          items: items,
          history: existing?.history ??
              [OrderStatusHistory(id: 'q${command.id}', status: OrderStatus.draft, changedBy: session.name, changedAt: command.queuedAt)],
        );
        byId[command.referenceId] = saved;
      } else {
        final o = byId[command.referenceId];
        final status = OrderStatus.fromServer(payload['status'] as String);
        if (o == null || o.status == status) continue; // already in the copy
        o.status = status;
        o.history.add(OrderStatusHistory(
          id: 'q${command.id}',
          status: status,
          changedBy: session.name,
          changedAt: DateTime.parse(payload['changedAt'] as String).toLocal(),
        ));
      }
    }
    return byId.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<OrderItem> _item(String itemId, String locationId, int quantity) async {
    final dao = _db.serverMirrorDao;
    final item = await dao.itemById(itemId);
    final bin = await dao.locationById(locationId);
    return OrderItem(
      itemId: itemId,
      itemName: item?.name ?? 'Item no longer in the catalogue',
      itemSku: item?.sku ?? 'Unknown item',
      quantity: quantity,
      locationId: locationId,
      locationCode: bin?.code ?? 'Unknown bin',
    );
  }

  static _Order? _find(List<_Order> orders, String id) {
    for (final o in orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _day(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  /// DO-yyMMdd-XXXXXXXX: the date and the start of the order's own id (32 random bits), so phones don't pick the same number.
  static String _number(String prefix, String id) {
    final d = DateTime.now();
    return '$prefix-${_two(d.year % 100)}${_two(d.month)}${_two(d.day)}-${id.replaceAll('-', '').substring(0, 8).toUpperCase()}';
  }

  static DeliveryOrder _delivery(_Order o) => DeliveryOrder(
        id: o.id,
        orderNumber: o.number,
        destination: o.destination ?? '',
        deliveryDate: o.date,
        status: o.status,
        requiresApproval: o.requiresApproval,
        notes: o.notes,
        createdBy: o.createdBy,
        createdAt: o.createdAt,
        items: o.items,
        statusHistory: List.unmodifiable(o.history),
      );

  static SalesOrder _sales(_Order o) => SalesOrder(
        id: o.id,
        orderNumber: o.number,
        customerName: o.customerName ?? '',
        orderDate: o.date,
        status: o.status,
        requiresApproval: o.requiresApproval,
        notes: o.notes,
        createdBy: o.createdBy,
        createdAt: o.createdAt,
        items: o.items,
        statusHistory: List.unmodifiable(o.history),
      );
}

/// One order while the copy and the waiting commands are combined.
class _Order {
  _Order({
    required this.id,
    required this.number,
    required this.destination,
    required this.customerName,
    required this.date,
    required this.status,
    required this.requiresApproval,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.items,
    required this.history,
  });

  final String id;
  final String number;
  final String? destination;
  final String? customerName;
  final DateTime date;
  OrderStatus status;
  final bool requiresApproval;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<OrderStatusHistory> history;
}
