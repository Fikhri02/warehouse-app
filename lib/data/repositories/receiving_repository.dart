import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';

abstract class ReceivingRepository {
  Future<List<PurchaseOrder>> getPurchaseOrders();

  /// Where received goods can be put away (server mode). Empty in Sample mode, which doesn't ask.
  Future<List<CountLocation>> getPutAwayLocations();

  /// Hands a finished receipt over for sending: what this session added, where it was put away, and the signature.
  Future<void> submitReceive(PurchaseOrder order, {Uint8List? signature, String? locationId});
}

final receivingRepositoryProvider = Provider<ReceivingRepository>((ref) {
  throw UnimplementedError('receivingRepositoryProvider not overridden');
});

final putAwayLocationsProvider = FutureProvider.autoDispose<List<CountLocation>>(
  (ref) => ref.watch(receivingRepositoryProvider).getPutAwayLocations(),
);
