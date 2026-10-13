import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart';

/// Brings the phone's copy up to date: reads `/warehouses/{w}/sync/changes` from the stored cursor until the server
/// says there is no more. Each page is applied, with its cursor, in one transaction, so an interrupted pull resumes
/// where it stopped.
class ChangeFeedPuller {
  ChangeFeedPuller({required ApiClient client, required AppDatabase db})
      : _client = client,
        _db = db;

  final ApiClient _client;
  final AppDatabase _db;

  Future<int> pull(String warehouseId) async {
    var applied = 0;
    final generation = _client.tokens.generation;
    // Whatever was sent before this pull began is in the server's answer by the time the pull reaches the end.
    final sentBefore = await _db.syncQueueDao.lastSyncedId();
    var cursor = await _db.serverMirrorDao.cursorFor(warehouseId);
    while (true) {
      final page = await _client.get(
        '/warehouses/$warehouseId/sync/changes',
        query: {'cursor': '$cursor', 'limit': '500'},
      ) as Map<String, dynamic>;
      final changes = (page['changes'] as List).cast<Map<String, dynamic>>();
      final next = (page['nextCursor'] as num).toInt();
      await _db.transaction(() async {
        // Signed out while this page was on its way: the wiped phone must stay wiped.
        if (_client.tokens.generation != generation) throw const SessionExpiredException();
        for (final change in changes) {
          await _apply(change);
        }
        await _db.serverMirrorDao.saveCursor(warehouseId, next);
        if (page['hasMore'] != true) await _db.serverMirrorDao.markCaughtUp(warehouseId, through: sentBefore);
      });
      applied += changes.length;
      cursor = next;
      if (page['hasMore'] != true) return applied;
    }
  }

  Future<void> _apply(Map<String, dynamic> change) async {
    final dao = _db.serverMirrorDao;
    final id = change['id'] as String;
    final data = change['deleted'] == true ? null : change['data'] as Map<String, dynamic>?;
    switch (change['entity']) {
      case 'item':
        if (data == null) return dao.deleteItem(id);
        return dao.upsertItem(CatalogItemsCompanion.insert(
          id: id,
          sku: data['sku'] as String,
          name: data['name'] as String,
          uom: data['uom'] as String,
          isActive: data['isActive'] as bool,
        ));
      case 'itemBarcode':
        if (data == null) return dao.deleteBarcode(id);
        return dao.upsertBarcode(CatalogBarcodesCompanion.insert(id: id, itemId: data['itemId'] as String, code: data['code'] as String));
      case 'location':
        if (data == null) return dao.deleteLocation(id);
        return dao.upsertLocation(WarehouseLocationsCompanion.insert(
          id: id,
          warehouseId: data['warehouseId'] as String,
          code: data['code'] as String,
          type: data['type'] as String,
        ));
      case 'countSession':
        if (data == null) return dao.deleteCountSession(id);
        return dao.upsertCountSession(
          RemoteCountSessionsCompanion.insert(
            id: id,
            warehouseId: data['warehouseId'] as String,
            createdByUserId: data['createdByUserId'] as String,
            label: Value(data['label'] as String?),
            status: data['status'] as String,
            submittedAt: DateTime.parse(data['submittedAt'] as String),
            reviewedAt: Value(data['reviewedAt'] == null ? null : DateTime.parse(data['reviewedAt'] as String)),
            rejectReason: Value(data['rejectReason'] as String?),
          ),
          [
            for (final line in (data['lines'] as List).cast<Map<String, dynamic>>())
              RemoteCountLinesCompanion.insert(
                id: line['id'] as String,
                sessionId: id,
                itemId: line['itemId'] as String,
                locationId: line['locationId'] as String,
                counted: (line['counted'] as num).toDouble(),
                systemAtSubmit: (line['systemAtSubmit'] as num).toDouble(),
                adjustment: Value((line['adjustment'] as num?)?.toDouble()),
              ),
          ],
        );
      case 'purchaseOrder':
        if (data == null) return dao.deletePurchaseOrder(id);
        return dao.upsertPurchaseOrder(
          RemotePurchaseOrdersCompanion.insert(
            id: id,
            warehouseId: data['warehouseId'] as String,
            number: data['number'] as String,
            supplier: data['supplier'] as String,
            expectedDate: Value(data['expectedDate'] == null ? null : DateTime.parse(data['expectedDate'] as String)),
            status: data['status'] as String,
          ),
          [
            for (final line in (data['lines'] as List).cast<Map<String, dynamic>>())
              RemotePoLinesCompanion.insert(
                id: line['id'] as String,
                purchaseOrderId: id,
                lineNo: (line['lineNo'] as num).toInt(),
                itemId: line['itemId'] as String,
                ordered: (line['ordered'] as num).toDouble(),
                received: (line['received'] as num).toDouble(),
              ),
          ],
        );
      case 'deliveryOrder':
      case 'salesOrder':
        if (data == null) return dao.deleteOrder(id);
        return dao.upsertOrder(
          RemoteOrdersCompanion.insert(
            id: id,
            warehouseId: data['warehouseId'] as String,
            kind: data['kind'] as String,
            number: data['number'] as String,
            destination: Value(data['destination'] as String?),
            customerName: Value(data['customerName'] as String?),
            orderDate: DateTime.parse(data['date'] as String),
            status: data['status'] as String,
            requiresApproval: data['requiresApproval'] as bool,
            notes: Value(data['notes'] as String?),
            createdByName: data['createdByName'] as String,
            createdAt: DateTime.parse(data['createdAt'] as String),
            statusHistory: jsonEncode([
              for (final h in (data['statusHistory'] as List).cast<Map<String, dynamic>>())
                {'status': h['status'], 'changedByName': h['changedByName'], 'changedAt': h['changedAt']},
            ]),
          ),
          [
            for (final line in (data['lines'] as List).cast<Map<String, dynamic>>())
              RemoteOrderLinesCompanion.insert(
                id: line['id'] as String,
                orderId: id,
                itemId: line['itemId'] as String,
                locationId: line['locationId'] as String,
                quantity: (line['quantity'] as num).toDouble(),
              ),
          ],
        );
      case 'staffTask':
        if (data == null) return dao.deleteTask(id);
        return dao.upsertTask(RemoteTasksCompanion.insert(
          id: id,
          warehouseId: data['warehouseId'] as String,
          title: data['title'] as String,
          type: data['type'] as String,
          locationId: Value(data['locationId'] as String?),
          assigneeUserId: Value(data['assigneeUserId'] as String?),
          status: data['status'] as String,
          dueAt: Value(_time(data['dueAt'])),
          createdByUserId: data['createdByUserId'] as String,
          completedAt: Value(_time(data['completedAt'])),
        ));
      case 'alert':
        if (data == null) return dao.deleteAlert(id);
        return dao.upsertAlert(RemoteAlertsCompanion.insert(
          id: id,
          warehouseId: Value(data['warehouseId'] as String?),
          type: data['type'] as String,
          title: data['title'] as String,
          body: data['body'] as String,
          payload: Value(data['payload'] == null ? null : jsonEncode(data['payload'])),
          createdAt: DateTime.parse(data['createdAt'] as String),
          readAt: Value(_time(data['readAt'])),
        ));
      default:
        // Warehouses and anything newer than this version of the app: nothing on the phone keeps them.
        return;
    }
  }

  static DateTime? _time(Object? value) => value == null ? null : DateTime.parse(value as String);
}
