import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';

final salesOrdersProvider =
    FutureProvider.family<List<SalesOrder>, bool>((ref, active) {
  // Another warehouse or another person: another list.
  ref.watch(authNotifierProvider.select((auth) => (auth.valueOrNull?.userId, auth.valueOrNull?.warehouseId)));
  return ref.watch(ordersRepositoryProvider).getSalesOrders(active: active);
});

final salesOrderDetailProvider =
    FutureProvider.family<SalesOrder?, String>((ref, id) {
  // Another warehouse or another person: another list.
  ref.watch(authNotifierProvider.select((auth) => (auth.valueOrNull?.userId, auth.valueOrNull?.warehouseId)));
  return ref.watch(ordersRepositoryProvider).getSalesOrderById(id);
});
