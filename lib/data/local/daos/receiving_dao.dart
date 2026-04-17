import 'package:drift/drift.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/purchase_order_table.dart';

part 'receiving_dao.g.dart';

@DriftAccessor(tables: [PurchaseOrders, PoLineItems])
class ReceivingDao extends DatabaseAccessor<AppDatabase>
    with _$ReceivingDaoMixin {
  ReceivingDao(super.db);

  Future<List<PurchaseOrder>> getAllPurchaseOrders() =>
      select(purchaseOrders).get();

  Future<List<PurchaseOrder>> getPendingPurchaseOrders() =>
      (select(purchaseOrders)..where((po) => po.status.equals('pending')))
          .get();

  Future<List<PurchaseOrder>> getInProgressPurchaseOrders() =>
      (select(purchaseOrders)..where((po) => po.status.equals('inProgress')))
          .get();

  Future<List<PurchaseOrder>> getReceivedPurchaseOrders() =>
      (select(purchaseOrders)..where((po) => po.status.equals('received')))
          .get();

  Future<PurchaseOrder?> getPoById(String id) =>
      (select(purchaseOrders)..where((po) => po.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsertPurchaseOrder(PurchaseOrdersCompanion po) =>
      into(purchaseOrders).insertOnConflictUpdate(po);

  Future<List<PoLineItem>> getLineItemsForPo(String poId) =>
      (select(poLineItems)..where((i) => i.poId.equals(poId))).get();

  Future<void> upsertLineItem(PoLineItemsCompanion item) =>
      into(poLineItems).insertOnConflictUpdate(item);

  Future<void> updateLineItemReceived(String itemId, int qty) =>
      (update(poLineItems)..where((i) => i.id.equals(itemId))).write(
        PoLineItemsCompanion(receivedQty: Value(qty)),
      );

  Future<void> updateLineItemFlagged(
    String itemId,
    bool flagged,
    String? reason,
  ) =>
      (update(poLineItems)..where((i) => i.id.equals(itemId))).write(
        PoLineItemsCompanion(
          flagged: Value(flagged),
          flagReason: Value(reason),
        ),
      );

  Future<void> submitReceive(String poId) =>
      (update(purchaseOrders)..where((po) => po.id.equals(poId))).write(
        PurchaseOrdersCompanion(
          status: const Value('received'),
          receivedAt: Value(DateTime.now()),
        ),
      );
}
