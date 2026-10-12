import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/purchase_order.dart';
import '../../../data/repositories/receiving_repository.dart';

export '../../../data/repositories/receiving_repository.dart'
    show receivingRepositoryProvider;

class PurchaseOrdersNotifier extends AsyncNotifier<List<PurchaseOrder>> {
  @override
  Future<List<PurchaseOrder>> build() async {
    return ref.watch(receivingRepositoryProvider).getPurchaseOrders();
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
  PurchaseOrdersNotifier.new,
);

class ActiveReceiveNotifier extends Notifier<PurchaseOrder?> {
  @override
  PurchaseOrder? build() => null;

  void startReceive(PurchaseOrder order) {
    state = order;
  }

  bool scanItem(String barcode) {
    if (state == null) return false;
    final idx = state!.lineItems.indexWhere((i) => i.matches(barcode));
    if (idx == -1) return false;
    final item = state!.lineItems[idx];
    state = _withUpdatedItem(
      idx,
      item.copyWith(
        received: (item.received ?? 0) + 1,
        lineStatus: PoLineItemStatus.confirmed,
      ),
    );
    return true;
  }

  void confirmItem({required String itemCode, required int received}) {
    if (state == null) return;
    final idx = state!.lineItems.indexWhere((i) => i.matches(itemCode));
    if (idx == -1) return;
    state = _withUpdatedItem(
      idx,
      state!.lineItems[idx].copyWith(
        received: received,
        lineStatus: PoLineItemStatus.confirmed,
      ),
    );
  }

  void flagItemWithReason({
    required String itemCode,
    required String reason,
  }) {
    if (state == null) return;
    final idx = state!.lineItems.indexWhere((i) => i.matches(itemCode));
    if (idx == -1) return;
    state = _withUpdatedItem(
      idx,
      state!.lineItems[idx].copyWith(
        flagged: true,
        flagReason: reason,
        lineStatus: PoLineItemStatus.flagged,
      ),
    );
  }

  void flagItem({required String itemCode}) {
    flagItemWithReason(itemCode: itemCode, reason: '');
  }

  void addUnknownItem({
    required String itemCode,
    required String itemName,
    required int qty,
  }) {
    if (state == null) return;
    state = PurchaseOrder(
      id: state!.id,
      number: state!.number,
      supplier: state!.supplier,
      status: state!.status,
      dueDate: state!.dueDate,
      receivedAt: state!.receivedAt,
      lineItems: [
        ...state!.lineItems,
        PoLineItem(
          itemCode: itemCode,
          itemName: itemName,
          expected: 0,
          received: qty,
          lineStatus: PoLineItemStatus.confirmed,
        ),
      ],
    );
  }

  Future<void> submitReceive({Uint8List? signature, String? locationId}) async {
    if (state == null) return;
    await ref.read(receivingRepositoryProvider).submitReceive(state!, signature: signature, locationId: locationId);
    await ref.read(purchaseOrdersNotifierProvider.notifier).refresh();
    state = null;
  }

  PurchaseOrder _withUpdatedItem(int idx, PoLineItem updated) {
    final newItems = List<PoLineItem>.from(state!.lineItems);
    newItems[idx] = updated;
    return PurchaseOrder(
      id: state!.id,
      number: state!.number,
      supplier: state!.supplier,
      status: state!.status,
      dueDate: state!.dueDate,
      receivedAt: state!.receivedAt,
      lineItems: newItems,
    );
  }
}

final activeReceiveNotifierProvider =
    NotifierProvider<ActiveReceiveNotifier, PurchaseOrder?>(
  ActiveReceiveNotifier.new,
);
