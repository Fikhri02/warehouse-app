import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/purchase_order.dart';
import '../../../data/repositories/receiving_repository.dart';

// receivingRepositoryProvider is defined in receiving_repository.dart; export it here
export '../../../data/repositories/receiving_repository.dart'
    show receivingRepositoryProvider;

class PurchaseOrdersNotifier extends AsyncNotifier<List<PurchaseOrder>> {
  @override
  Future<List<PurchaseOrder>> build() async {
    return ref.read(receivingRepositoryProvider).getPurchaseOrders();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(receivingRepositoryProvider).getPurchaseOrders(),
    );
  }
}

final purchaseOrdersNotifierProvider =
    AsyncNotifierProvider<PurchaseOrdersNotifier, List<PurchaseOrder>>(
        PurchaseOrdersNotifier.new);

class ActiveReceiveNotifier extends Notifier<PurchaseOrder?> {

  @override
  PurchaseOrder? build() => null;

  void startReceive(PurchaseOrder order) {
    state = order;
  }

  void confirmItem({required String itemCode, required int received}) {
    if (state == null) return;
    state = PurchaseOrder(
      id: state!.id,
      supplier: state!.supplier,
      status: state!.status,
      lineItems: state!.lineItems.map((item) {
        if (item.itemCode != itemCode) return item;
        return item.copyWith(
          received: received,
          lineStatus: PoLineItemStatus.confirmed,
        );
      }).toList(),
    );
  }

  void flagItem({required String itemCode}) {
    if (state == null) return;
    state = PurchaseOrder(
      id: state!.id,
      supplier: state!.supplier,
      status: state!.status,
      lineItems: state!.lineItems.map((item) {
        if (item.itemCode != itemCode) return item;
        return item.copyWith(
          flagged: true,
          lineStatus: PoLineItemStatus.flagged,
        );
      }).toList(),
    );
  }

  Future<void> submitReceive({Uint8List? signature}) async {
    if (state == null) return;
    // signature will be forwarded to the repository when the backend endpoint is ready
    await ref.read(receivingRepositoryProvider).submitReceive(state!);
    await ref.read(purchaseOrdersNotifierProvider.notifier).refresh();
    state = null;
  }
}

final activeReceiveNotifierProvider =
    NotifierProvider<ActiveReceiveNotifier, PurchaseOrder?>(
        ActiveReceiveNotifier.new);
