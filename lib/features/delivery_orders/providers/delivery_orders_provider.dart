import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';

export 'package:warehouse_app/data/repositories/orders_repository.dart'
    show ordersRepositoryProvider;

final deliveryOrdersProvider =
    FutureProvider.family<List<DeliveryOrder>, bool>((ref, active) {
  // Another warehouse or another person: another list.
  ref.watch(authNotifierProvider.select((auth) => (auth.valueOrNull?.userId, auth.valueOrNull?.warehouseId)));
  return ref.watch(ordersRepositoryProvider).getDeliveryOrders(active: active);
});

final deliveryOrderDetailProvider =
    FutureProvider.autoDispose.family<DeliveryOrder?, String>((ref, id) {
  // Another warehouse or another person: another list.
  ref.watch(authNotifierProvider.select((auth) => (auth.valueOrNull?.userId, auth.valueOrNull?.warehouseId)));
  return ref.watch(ordersRepositoryProvider).getDeliveryOrderById(id);
});
