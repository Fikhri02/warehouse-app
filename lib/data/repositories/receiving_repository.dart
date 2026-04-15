import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';

abstract class ReceivingRepository {
  Future<List<PurchaseOrder>> getPurchaseOrders();
  Future<void> submitReceive(PurchaseOrder order);
}

final receivingRepositoryProvider = Provider<ReceivingRepository>((ref) {
  throw UnimplementedError('receivingRepositoryProvider not overridden');
});
