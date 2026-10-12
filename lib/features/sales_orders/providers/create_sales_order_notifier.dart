import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/features/sales_orders/providers/sales_orders_provider.dart';

class CreateSalesOrderState {
  final String? editingOrderId;
  final String? editingOrderNumber;

  /// The bin new lines are picked from.
  final OrderLocation? pickFrom;
  final String customerName;
  final DateTime? orderDate;
  final bool requiresApproval;
  final String notes;
  final List<OrderItem> items;
  final Map<String, String> errors;
  final bool isSubmitting;

  const CreateSalesOrderState({
    this.editingOrderId,
    this.editingOrderNumber,
    this.pickFrom,
    this.customerName = '',
    this.orderDate,
    this.requiresApproval = false,
    this.notes = '',
    this.items = const [],
    this.errors = const {},
    this.isSubmitting = false,
  });

  CreateSalesOrderState copyWith({
    Object? pickFrom = _sentinel,
    String? customerName,
    Object? orderDate = _sentinel,
    bool? requiresApproval,
    String? notes,
    List<OrderItem>? items,
    Map<String, String>? errors,
    bool? isSubmitting,
  }) {
    return CreateSalesOrderState(
      editingOrderId: editingOrderId,
      editingOrderNumber: editingOrderNumber,
      pickFrom: pickFrom == _sentinel ? this.pickFrom : pickFrom as OrderLocation?,
      customerName: customerName ?? this.customerName,
      orderDate: orderDate == _sentinel ? this.orderDate : orderDate as DateTime?,
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
  CreateSalesOrderState build() => CreateSalesOrderState(orderDate: DateTime.now());

  void loadFromOrder(SalesOrder order) {
    final first = order.items.where((i) => i.locationId != null).firstOrNull;
    state = CreateSalesOrderState(
      editingOrderId: order.id,
      editingOrderNumber: order.orderNumber,
      pickFrom: first == null ? null : OrderLocation(id: first.locationId!, name: first.locationCode ?? '', type: 'Bin'),
      customerName: order.customerName,
      orderDate: order.orderDate,
      requiresApproval: order.requiresApproval,
      notes: order.notes ?? '',
      items: order.items,
    );
  }

  /// Every line is picked from [value] from now on.
  void setPickFrom(OrderLocation? value) {
    state = state.copyWith(
      pickFrom: value,
      items: value == null ? null : [for (final item in state.items) item.copyWith(locationId: value.id, locationCode: value.name)],
      errors: {...state.errors}..remove('pickFrom'),
    );
  }

  void setCustomerName(String value) {
    state = state.copyWith(customerName: value, errors: {...state.errors}..remove('customerName'));
  }

  void setDate(DateTime? value) {
    state = state.copyWith(orderDate: value, errors: {...state.errors}..remove('orderDate'));
  }

  void toggleApproval(bool value) => state = state.copyWith(requiresApproval: value);

  void setNotes(String value) => state = state.copyWith(notes: value);

  /// Lines without a bin are picked from Pick From.
  void setItems(List<OrderItem> items) {
    final bin = state.pickFrom;
    state = state.copyWith(
      items: [
        for (final item in items)
          if (item.locationId == null && bin != null) item.copyWith(locationId: bin.id, locationCode: bin.name) else item,
      ],
      errors: {...state.errors}..remove('items'),
    );
  }

  bool validateStep1() {
    final errors = <String, String>{};
    if (state.pickFrom == null) errors['pickFrom'] = 'Choose the bin to pick from';
    final customer = state.customerName.trim();
    if (customer.isEmpty) {
      errors['customerName'] = 'Customer name is required';
    } else if (customer.length > 200) {
      errors['customerName'] = 'Customer name must be at most 200 characters';
    }
    if (state.orderDate == null) errors['orderDate'] = 'Order date is required';
    if (state.notes.trim().length > 1000) errors['notes'] = 'Notes must be at most 1000 characters';
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
      final status = asDraft ? OrderStatus.draft : (state.requiresApproval ? OrderStatus.pendingApproval : OrderStatus.submitted);
      final saved = await repository.saveSalesOrder(SalesOrder(
        id: state.editingOrderId ?? const Uuid().v4(),
        orderNumber: state.editingOrderNumber ?? '',
        customerName: state.customerName.trim(),
        orderDate: state.orderDate ?? DateTime.now(),
        status: status,
        requiresApproval: state.requiresApproval,
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        createdBy: '',
        createdAt: DateTime.now(),
        items: state.items,
      ));
      ref.invalidate(salesOrdersProvider(true));
      ref.invalidate(salesOrdersProvider(false));
      ref.invalidate(salesOrderDetailProvider(saved.id));
      return saved;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final createSalesOrderNotifierProvider = NotifierProvider<CreateSalesOrderNotifier, CreateSalesOrderState>(
  CreateSalesOrderNotifier.new,
);

const Object _sentinel = Object();
