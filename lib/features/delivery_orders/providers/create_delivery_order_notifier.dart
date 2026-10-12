import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/features/delivery_orders/providers/delivery_orders_provider.dart';

class CreateDeliveryOrderState {
  final String? editingOrderId;
  final String? editingOrderNumber;

  /// The bin new lines are picked from.
  final OrderLocation? pickFrom;
  final String destination;
  final DateTime? deliveryDate;
  final bool requiresApproval;
  final String notes;
  final List<OrderItem> items;
  final Map<String, String> errors;
  final bool isSubmitting;

  const CreateDeliveryOrderState({
    this.editingOrderId,
    this.editingOrderNumber,
    this.pickFrom,
    this.destination = '',
    this.deliveryDate,
    this.requiresApproval = false,
    this.notes = '',
    this.items = const [],
    this.errors = const {},
    this.isSubmitting = false,
  });

  CreateDeliveryOrderState copyWith({
    Object? pickFrom = _sentinel,
    String? destination,
    Object? deliveryDate = _sentinel,
    bool? requiresApproval,
    String? notes,
    List<OrderItem>? items,
    Map<String, String>? errors,
    bool? isSubmitting,
  }) {
    return CreateDeliveryOrderState(
      editingOrderId: editingOrderId,
      editingOrderNumber: editingOrderNumber,
      pickFrom: pickFrom == _sentinel ? this.pickFrom : pickFrom as OrderLocation?,
      destination: destination ?? this.destination,
      deliveryDate: deliveryDate == _sentinel ? this.deliveryDate : deliveryDate as DateTime?,
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
  CreateDeliveryOrderState build() => CreateDeliveryOrderState(deliveryDate: DateTime.now());

  void loadFromOrder(DeliveryOrder order) {
    final first = order.items.where((i) => i.locationId != null).firstOrNull;
    state = CreateDeliveryOrderState(
      editingOrderId: order.id,
      editingOrderNumber: order.orderNumber,
      pickFrom: first == null ? null : OrderLocation(id: first.locationId!, name: first.locationCode ?? '', type: 'Bin'),
      destination: order.destination,
      deliveryDate: order.deliveryDate,
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

  void setDestination(String value) {
    state = state.copyWith(destination: value, errors: {...state.errors}..remove('destination'));
  }

  void setDate(DateTime? value) {
    state = state.copyWith(deliveryDate: value, errors: {...state.errors}..remove('deliveryDate'));
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
    final destination = state.destination.trim();
    if (destination.isEmpty) {
      errors['destination'] = 'Destination is required';
    } else if (destination.length > 200) {
      errors['destination'] = 'Destination must be at most 200 characters';
    }
    if (state.deliveryDate == null) errors['deliveryDate'] = 'Delivery date is required';
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
      final status = asDraft ? OrderStatus.draft : (state.requiresApproval ? OrderStatus.pendingApproval : OrderStatus.submitted);
      final saved = await repository.saveDeliveryOrder(DeliveryOrder(
        id: state.editingOrderId ?? const Uuid().v4(),
        orderNumber: state.editingOrderNumber ?? '',
        destination: state.destination.trim(),
        deliveryDate: state.deliveryDate ?? DateTime.now(),
        status: status,
        requiresApproval: state.requiresApproval,
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        createdBy: '',
        createdAt: DateTime.now(),
        items: state.items,
      ));
      ref.invalidate(deliveryOrdersProvider(true));
      ref.invalidate(deliveryOrdersProvider(false));
      ref.invalidate(deliveryOrderDetailProvider(saved.id));
      return saved;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final createDeliveryOrderNotifierProvider = NotifierProvider<CreateDeliveryOrderNotifier, CreateDeliveryOrderState>(
  CreateDeliveryOrderNotifier.new,
);

const Object _sentinel = Object();
