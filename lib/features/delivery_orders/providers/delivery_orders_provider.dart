import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';

export 'package:warehouse_app/data/repositories/orders_repository.dart'
    show ordersRepositoryProvider;

final deliveryOrdersProvider =
    FutureProvider.family<List<DeliveryOrder>, bool>((ref, active) {
  return ref.watch(ordersRepositoryProvider).getDeliveryOrders(active: active);
});

final deliveryOrderDetailProvider =
    FutureProvider.family<DeliveryOrder?, int>((ref, id) {
  return ref.watch(ordersRepositoryProvider).getDeliveryOrderById(id);
});

final locationsProvider = FutureProvider<List<OrderLocation>>((ref) {
  return ref.watch(ordersRepositoryProvider).getLocations();
});
