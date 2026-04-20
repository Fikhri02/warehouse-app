import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/features/delivery_orders/providers/delivery_orders_provider.dart';

class CreateDeliveryOrderState {
  final int? editingOrderId;
  final OrderLocation? fromLocation;
  final OrderLocation? toLocation;
  final DateTime? deliveryDate;
  final bool requiresApproval;
  final String notes;
  final List<OrderItem> items;
  final Map<String, String> errors;
  final bool isSubmitting;

  const CreateDeliveryOrderState({
    this.editingOrderId,
    this.fromLocation,
    this.toLocation,
    this.deliveryDate,
    this.requiresApproval = false,
    this.notes = '',
    this.items = const [],
    this.errors = const {},
    this.isSubmitting = false,
  });

  CreateDeliveryOrderState copyWith({
    Object? editingOrderId = _sentinel,
    Object? fromLocation = _sentinel,
    Object? toLocation = _sentinel,
    Object? deliveryDate = _sentinel,
    bool? requiresApproval,
    String? notes,
    List<OrderItem>? items,
    Map<String, String>? errors,
    bool? isSubmitting,
  }) {
    return CreateDeliveryOrderState(
      editingOrderId: editingOrderId == _sentinel
          ? this.editingOrderId
          : editingOrderId as int?,
      fromLocation: fromLocation == _sentinel
          ? this.fromLocation
          : fromLocation as OrderLocation?,
      toLocation: toLocation == _sentinel
          ? this.toLocation
          : toLocation as OrderLocation?,
      deliveryDate: deliveryDate == _sentinel
          ? this.deliveryDate
          : deliveryDate as DateTime?,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class CreateDeliveryOrderNotifier extends Notifier<CreateDeliveryOrderState> {
  @override
  CreateDeliveryOrderState build() {
    return CreateDeliveryOrderState(deliveryDate: DateTime.now());
  }

  void loadFromOrder(DeliveryOrder order) {
    state = CreateDeliveryOrderState(
      editingOrderId: order.id,
      fromLocation: order.fromLocation,
      toLocation: order.toLocation,
      deliveryDate: order.deliveryDate,
      requiresApproval: order.requiresApproval,
      notes: order.notes ?? '',
      items: order.items,
    );
  }

  void setFromLocation(OrderLocation? value) {
    state = state.copyWith(
      fromLocation: value,
      errors: {...state.errors}..remove('fromLocation'),
    );
  }

  void setToLocation(OrderLocation? value) {
    state = state.copyWith(
      toLocation: value,
      errors: {...state.errors}..remove('toLocation'),
    );
  }

  void setDate(DateTime? value) {
    state = state.copyWith(
      deliveryDate: value,
      errors: {...state.errors}..remove('deliveryDate'),
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
    if (state.fromLocation == null) {
      errors['fromLocation'] = 'From location is required';
    }
    if (state.toLocation == null) {
      errors['toLocation'] = 'To location is required';
    }
    if (state.deliveryDate == null) {
      errors['deliveryDate'] = 'Delivery date is required';
    }
    if (state.fromLocation != null &&
        state.toLocation != null &&
        state.fromLocation!.id == state.toLocation!.id) {
      errors['toLocation'] = 'From and To locations must be different';
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

  Future<DeliveryOrder> submit({required bool asDraft}) async {
    final repository = ref.read(ordersRepositoryProvider);
    state = state.copyWith(isSubmitting: true);
    try {
      final now = DateTime.now();
      final status = asDraft
          ? OrderStatus.draft
          : (state.requiresApproval
              ? OrderStatus.pendingApproval
              : OrderStatus.submitted);
      final order = DeliveryOrder(
        id: state.editingOrderId ?? 0,
        orderNumber: '',
        fromLocation: state.fromLocation!,
        toLocation: state.toLocation!,
        deliveryDate: state.deliveryDate ?? now,
        status: status,
        requiresApproval: state.requiresApproval,
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        createdBy: 'Hasan',
        createdAt: now,
        items: state.items,
        statusHistory: const [],
      );
      final saved = await repository.createDeliveryOrder(
        order,
        existingOrderId: state.editingOrderId,
      );
      ref.invalidate(deliveryOrdersProvider(true));
      ref.invalidate(deliveryOrdersProvider(false));
      ref.invalidate(deliveryOrderDetailProvider(saved.id));
      return saved;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final createDeliveryOrderNotifierProvider =
    NotifierProvider<CreateDeliveryOrderNotifier, CreateDeliveryOrderState>(
  CreateDeliveryOrderNotifier.new,
);

const Object _sentinel = Object();
