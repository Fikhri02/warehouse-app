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
      (select(purchaseOrders)..where((po) => po.status.equals('pending'))).get();

  Future<void> upsertPurchaseOrder(PurchaseOrdersCompanion po) =>
      into(purchaseOrders).insertOnConflictUpdate(po);

  Future<List<PoLineItem>> getLineItemsForPo(String poId) =>
      (select(poLineItems)..where((i) => i.poId.equals(poId))).get();

  Future<void> upsertLineItem(PoLineItemsCompanion item) =>
      into(poLineItems).insertOnConflictUpdate(item);

  Future<void> submitReceive(String poId) =>
      (update(purchaseOrders)..where((po) => po.id.equals(poId))).write(
        PurchaseOrdersCompanion(
          status: const Value('received'),
          receivedAt: Value(DateTime.now()),
        ),
      );
}
