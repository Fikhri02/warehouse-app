import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/features/sales_orders/providers/sales_orders_provider.dart';

class CreateSalesOrderState {
  final int? editingOrderId;
  final String customerName;
  final DateTime? orderDate;
  final bool requiresApproval;
  final String notes;
  final List<OrderItem> items;
  final Map<String, String> errors;
  final bool isSubmitting;

  const CreateSalesOrderState({
    this.editingOrderId,
    this.customerName = '',
    this.orderDate,
    this.requiresApproval = false,
    this.notes = '',
    this.items = const [],
    this.errors = const {},
    this.isSubmitting = false,
  });

  CreateSalesOrderState copyWith({
    Object? editingOrderId = _sentinel,
    String? customerName,
    Object? orderDate = _sentinel,
    bool? requiresApproval,
    String? notes,
    List<OrderItem>? items,
    Map<String, String>? errors,
    bool? isSubmitting,
  }) {
    return CreateSalesOrderState(
      editingOrderId: editingOrderId == _sentinel
          ? this.editingOrderId
          : editingOrderId as int?,
      customerName: customerName ?? this.customerName,
      orderDate:
          orderDate == _sentinel ? this.orderDate : orderDate as DateTime?,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class CreateSalesOrderNotifier extends Notifier<CreateSalesOrderState> {
  @override
  CreateSalesOrderState build() {
    return CreateSalesOrderState(orderDate: DateTime.now());
  }

  void loadFromOrder(SalesOrder order) {
    state = CreateSalesOrderState(
      editingOrderId: order.id,
      customerName: order.customerName,
      orderDate: order.orderDate,
      requiresApproval: order.requiresApproval,
      notes: order.notes ?? '',
      items: order.items,
    );
  }

  void setCustomerName(String value) {
    state = state.copyWith(
      customerName: value,
      errors: {...state.errors}..remove('customerName'),
    );
  }

  void setDate(DateTime? value) {
    state = state.copyWith(
      orderDate: value,
      errors: {...state.errors}..remove('orderDate'),
    );
  }

  void toggleApproval(bool value) {
    state = state.copyWith(requiresApproval: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void addItem(CatalogItem item) {
    final existingIndex =
        state.items.indexWhere((element) => element.itemId == item.id);
    if (existingIndex != -1) {
      final updated = [...state.items];
      updated[existingIndex] = updated[existingIndex]
          .copyWith(quantity: updated[existingIndex].quantity + 1);
      state = state.copyWith(
          items: updated, errors: {...state.errors}..remove('items'));
      return;
    }

    state = state.copyWith(
      items: [
        ...state.items,
        OrderItem(
          itemId: item.id,
          itemName: item.name,
          itemSku: item.sku,
          quantity: 1,
        ),
      ],
      errors: {...state.errors}..remove('items'),
    );
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.itemId != itemId).toList(),
    );
  }

  void updateQty(String itemId, int qty) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.itemId == itemId)
            item.copyWith(quantity: qty.clamp(1, 999))
          else
            item,
      ],
    );
  }

  void setItems(List<OrderItem> items) {
    state = state.copyWith(
      items: items,
      errors: {...state.errors}..remove('items'),
    );
  }

  bool validateStep1() {
    final errors = <String, String>{};
    if (state.customerName.trim().isEmpty) {
      errors['customerName'] = 'Customer name is required';
    }
    if (state.orderDate == null) {
      errors['orderDate'] = 'Order date is required';
    }
    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }

  bool validateStep2() {
    final errors = {...state.errors};
    if (state.items.isEmpty) {
      errors['items'] = 'Add at least one item';
    } else {
      errors.remove('items');
    }
    state = state.copyWith(errors: errors);
    return !errors.containsKey('items');
  }

  Future<SalesOrder> submit({required bool asDraft}) async {
    final repository = ref.read(ordersRepositoryProvider);
    state = state.copyWith(isSubmitting: true);
    try {
      final now = DateTime.now();
      final status = asDraft
          ? OrderStatus.draft
          : (state.requiresApproval
              ? OrderStatus.pendingApproval
              : OrderStatus.submitted);
      final order = SalesOrder(
        id: state.editingOrderId ?? 0,
        orderNumber: '',
        customerName: state.customerName.trim(),
        orderDate: state.orderDate ?? now,
        status: status,
        requiresApproval: state.requiresApproval,
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        createdBy: 'Hasan',
        createdAt: now,
        items: state.items,
        statusHistory: const [],
      );
      final saved = await repository.createSalesOrder(
        order,
        existingOrderId: state.editingOrderId,
      );
      ref.invalidate(salesOrdersProvider(true));
      ref.invalidate(salesOrdersProvider(false));
      ref.invalidate(salesOrderDetailProvider(saved.id));
      return saved;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final createSalesOrderNotifierProvider =
    NotifierProvider<CreateSalesOrderNotifier, CreateSalesOrderState>(
  CreateSalesOrderNotifier.new,
);

const Object _sentinel = Object();
