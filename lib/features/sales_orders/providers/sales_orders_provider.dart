import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';

final salesOrdersProvider =
    FutureProvider.family<List<SalesOrder>, bool>((ref, active) {
  return ref.watch(ordersRepositoryProvider).getSalesOrders(active: active);
});

final salesOrderDetailProvider =
    FutureProvider.family<SalesOrder?, int>((ref, id) {
  return ref.watch(ordersRepositoryProvider).getSalesOrderById(id);
});
