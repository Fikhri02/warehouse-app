import 'package:flutter/material.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';

enum OrderStatus {
  draft,
  pendingApproval,
  submitted,
  packed,
  inTransit,
  shipped;

  factory OrderStatus.fromString(String value) {
    switch (value) {
      case 'draft':
        return OrderStatus.draft;
      case 'pending_approval':
        return OrderStatus.pendingApproval;
      case 'submitted':
        return OrderStatus.submitted;
      case 'packed':
        return OrderStatus.packed;
      case 'in_transit':
        return OrderStatus.inTransit;
      case 'shipped':
        return OrderStatus.shipped;
    }
    throw ArgumentError('Unsupported order status: $value');
  }

  String get value {
    switch (this) {
      case OrderStatus.draft:
        return 'draft';
      case OrderStatus.pendingApproval:
        return 'pending_approval';
      case OrderStatus.submitted:
        return 'submitted';
      case OrderStatus.packed:
        return 'packed';
      case OrderStatus.inTransit:
        return 'in_transit';
      case OrderStatus.shipped:
        return 'shipped';
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.pendingApproval:
        return 'Pending Approval';
      case OrderStatus.submitted:
        return 'Submitted';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.shipped:
        return 'Shipped';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.draft:
        return const Color(0xFF757575);
      case OrderStatus.pendingApproval:
        return const Color(0xFFF57F17);
      case OrderStatus.submitted:
        return AppColors.info;
      case OrderStatus.packed:
        return const Color(0xFFE65100);
      case OrderStatus.inTransit:
        return AppColors.warning;
      case OrderStatus.shipped:
        return AppColors.success;
    }
  }

  bool get isActive => this != OrderStatus.shipped;

  OrderStatus? get nextStatus {
    switch (this) {
      case OrderStatus.draft:
        return null;
      case OrderStatus.pendingApproval:
        return OrderStatus.submitted;
      case OrderStatus.submitted:
        return OrderStatus.packed;
      case OrderStatus.packed:
        return OrderStatus.inTransit;
      case OrderStatus.inTransit:
        return OrderStatus.shipped;
      case OrderStatus.shipped:
        return null;
    }
  }

  String? get nextActionLabel {
    switch (this) {
      case OrderStatus.submitted:
        return 'Mark as Packed';
      case OrderStatus.packed:
        return 'Mark as In Transit';
      case OrderStatus.inTransit:
        return 'Mark as Shipped';
      case OrderStatus.draft:
      case OrderStatus.pendingApproval:
      case OrderStatus.shipped:
        return null;
    }
  }
}

class OrderLocation {
  final String id;
  final String name;
  final String type;

  const OrderLocation({
    required this.id,
    required this.name,
    required this.type,
  });
}

class CatalogItem {
  final String id;
  final String name;
  final String sku;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.sku,
  });
}

class OrderItem {
  final String itemId;
  final String itemName;
  final String itemSku;
  final int quantity;

  const OrderItem({
    required this.itemId,
    required this.itemName,
    required this.itemSku,
    this.quantity = 1,
  });

  OrderItem copyWith({
    String? itemId,
    String? itemName,
    String? itemSku,
    int? quantity,
  }) {
    return OrderItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemSku: itemSku ?? this.itemSku,
      quantity: quantity ?? this.quantity,
    );
  }
}

class OrderStatusHistory {
  final String id;
  final OrderStatus status;
  final String changedBy;
  final DateTime changedAt;

  const OrderStatusHistory({
    required this.id,
    required this.status,
    required this.changedBy,
    required this.changedAt,
  });
}

class DeliveryOrder {
  final int id;
  final String orderNumber;
  final OrderLocation fromLocation;
  final OrderLocation toLocation;
  final DateTime deliveryDate;
  final OrderStatus status;
  final bool requiresApproval;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<OrderStatusHistory> statusHistory;

  const DeliveryOrder({
    required this.id,
    required this.orderNumber,
    required this.fromLocation,
    required this.toLocation,
    required this.deliveryDate,
    required this.status,
    required this.requiresApproval,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.items = const [],
    this.statusHistory = const [],
  });

  DeliveryOrder copyWith({
    int? id,
    String? orderNumber,
    OrderLocation? fromLocation,
    OrderLocation? toLocation,
    DateTime? deliveryDate,
    OrderStatus? status,
    bool? requiresApproval,
    Object? notes = _sentinel,
    String? createdBy,
    DateTime? createdAt,
    List<OrderItem>? items,
    List<OrderStatusHistory>? statusHistory,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      notes: notes == _sentinel ? this.notes : notes as String?,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

class SalesOrder {
  final int id;
  final String orderNumber;
  final String customerName;
  final DateTime orderDate;
  final OrderStatus status;
  final bool requiresApproval;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<OrderStatusHistory> statusHistory;

  const SalesOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.orderDate,
    required this.status,
    required this.requiresApproval,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.items = const [],
    this.statusHistory = const [],
  });

  SalesOrder copyWith({
    int? id,
    String? orderNumber,
    String? customerName,
    DateTime? orderDate,
    OrderStatus? status,
    bool? requiresApproval,
    Object? notes = _sentinel,
    String? createdBy,
    DateTime? createdAt,
    List<OrderItem>? items,
    List<OrderStatusHistory>? statusHistory,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      notes: notes == _sentinel ? this.notes : notes as String?,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

const Object _sentinel = Object();
