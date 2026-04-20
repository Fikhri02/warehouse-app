import 'package:drift/drift.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/order_tables.dart';

part 'orders_dao.g.dart';

@DriftAccessor(
  tables: [
    LocationEntries,
    DeliveryOrderEntries,
    SalesOrderEntries,
    OrderItemEntries,
    OrderStatusHistoryEntries,
  ],
)
class OrdersDao extends DatabaseAccessor<AppDatabase> with _$OrdersDaoMixin {
  OrdersDao(super.db);

  Future<List<DeliveryOrderEntry>> watchDeliveryOrders(bool active) {
    final query = select(deliveryOrderEntries);
    if (active) {
      query.where((tbl) => tbl.status.isNotValue('shipped'));
    } else {
      query.where((tbl) => tbl.status.equals('shipped'));
    }
    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return query.get();
  }

  Future<List<SalesOrderEntry>> watchSalesOrders(bool active) {
    final query = select(salesOrderEntries);
    if (active) {
      query.where((tbl) => tbl.status.isNotValue('shipped'));
    } else {
      query.where((tbl) => tbl.status.equals('shipped'));
    }
    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return query.get();
  }

  Future<DeliveryOrderEntry?> getDeliveryOrderById(int id) {
    return (select(deliveryOrderEntries)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<SalesOrderEntry?> getSalesOrderById(int id) {
    return (select(salesOrderEntries)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<OrderItemEntry>> getItemsForOrder(int orderId, String orderType) {
    return (select(orderItemEntries)
          ..where(
            (tbl) =>
                tbl.orderId.equals(orderId) & tbl.orderType.equals(orderType),
          ))
        .get();
  }

  Future<List<OrderStatusHistoryEntry>> getHistoryForOrder(
    int orderId,
    String orderType,
  ) {
    return (select(orderStatusHistoryEntries)
          ..where(
            (tbl) =>
                tbl.orderId.equals(orderId) & tbl.orderType.equals(orderType),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.changedAt)]))
        .get();
  }

  Future<int> insertDeliveryOrder(DeliveryOrderEntriesCompanion entry) {
    return into(deliveryOrderEntries).insert(entry);
  }

  Future<int> insertSalesOrder(SalesOrderEntriesCompanion entry) {
    return into(salesOrderEntries).insert(entry);
  }

  Future<void> insertOrderItem(OrderItemEntriesCompanion entry) {
    return into(orderItemEntries).insert(entry);
  }

  Future<void> insertStatusHistory(OrderStatusHistoryEntriesCompanion entry) {
    return into(orderStatusHistoryEntries).insert(entry);
  }

  Future<void> updateDeliveryOrderStatus(int id, String status) {
    return (update(deliveryOrderEntries)..where((tbl) => tbl.id.equals(id)))
        .write(
      DeliveryOrderEntriesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateSalesOrderStatus(int id, String status) {
    return (update(salesOrderEntries)..where((tbl) => tbl.id.equals(id))).write(
      SalesOrderEntriesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
