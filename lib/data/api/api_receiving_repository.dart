import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide CountItem, CountSession, PoLineItem, PurchaseOrder, UserSession;
import 'package:warehouse_app/data/repositories/receiving_repository.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

/// Receiving against the server. Orders come from the phone's copy, with receipts still waiting to be sent already
/// counted in, so the same goods are not received twice. Finished receipts and signatures go through the outbox.
class ApiReceivingRepository implements ReceivingRepository {
  ApiReceivingRepository({required AppDatabase db, required UserSession? Function() session, required void Function() onQueued})
      : _db = db,
        _session = session,
        _onQueued = onQueued;

  final AppDatabase _db;
  final UserSession? Function() _session;
  final void Function() _onQueued;

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final dao = _db.serverMirrorDao;
    final waiting = await _waitingToSend(warehouseId);
    final orders = <PurchaseOrder>[];
    for (final order in await dao.purchaseOrders(warehouseId)) {
      final lines = <PoLineItem>[];
      for (final line in await dao.poLinesFor(order.id)) {
        final item = await dao.itemById(line.itemId);
        final received = line.received.round() + (waiting[line.id] ?? 0);
        lines.add(PoLineItem(
          lineId: line.id,
          itemId: line.itemId,
          itemCode: item?.sku ?? 'Unknown item',
          itemName: item?.name ?? 'Item no longer in the catalogue',
          expected: line.ordered.round(),
          received: received == 0 ? null : received,
          alreadyReceived: received,
          barcodes: await dao.barcodesFor(line.itemId),
          lineStatus: received > 0 ? PoLineItemStatus.confirmed : PoLineItemStatus.pending,
        ));
      }
      orders.add(PurchaseOrder(
        id: order.id,
        number: order.number,
        supplier: order.supplier,
        status: _status(lines),
        dueDate: order.expectedDate,
        lineItems: lines,
      ));
    }
    return orders;
  }

  @override
  Future<List<CountLocation>> getPutAwayLocations() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final locations = [
      for (final l in await _db.serverMirrorDao.locationsFor(warehouseId)) CountLocation(id: l.id, code: l.code, kind: l.type),
    ];
    locations.sort((a, b) => (a.kind == 'Dock' ? 0 : 1).compareTo(b.kind == 'Dock' ? 0 : 1)); // stable: codes stay in order
    return locations;
  }

  @override
  Future<void> submitReceive(PurchaseOrder order, {Uint8List? signature, String? locationId}) async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) throw StateError('No warehouse chosen.');
    if (locationId == null) throw StateError('Choose where the goods are put away.');
    final lines = <Map<String, Object?>>[];
    for (final line in order.lineItems) {
      if (line.lineId == null) continue; // the server only takes lines of the order
      final adding = line.receivingNow;
      if (adding <= 0) continue;
      final left = line.expected - line.alreadyReceived;
      if (adding > left) throw StateError('${line.itemName}: only $left more can be received on ${order.displayNumber}.');
      lines.add({'poLineId': line.lineId, 'locationId': locationId, 'quantity': adding});
    }
    if (lines.isEmpty) throw StateError('Nothing new to receive.');

    final receiptId = const Uuid().v4();
    final queue = _db.syncQueueDao;
    await queue.enqueue(
      operationType: SyncOps.receiptCreate,
      referenceId: receiptId,
      warehouseId: warehouseId,
      payload: jsonEncode({'purchaseOrderId': order.id, 'lines': lines, 'receivedAt': DateTime.now().toUtc().toIso8601String()}),
    );
    if (signature != null) {
      // The PNG travels in the command, so a retry sends exactly the same bytes under the same key.
      await queue.enqueue(
        operationType: SyncOps.receiptSignature,
        referenceId: receiptId,
        warehouseId: warehouseId,
        payload: jsonEncode({'png': base64Encode(signature)}),
      );
    }
    _onQueued();
  }

  /// Quantities in receipts the phone's copy of the orders doesn't show yet, by order line: those not sent, and those
  /// sent after the latest complete pull began.
  Future<Map<String, int>> _waitingToSend(String warehouseId) async {
    final totals = <String, int>{};
    final caughtUpThrough = await _db.serverMirrorDao.caughtUpThrough(warehouseId);
    for (final item in await _db.syncQueueDao.notYetInCopy(SyncOps.receiptCreate, warehouseId: warehouseId, caughtUpThrough: caughtUpThrough)) {
      final payload = jsonDecode(item.payload) as Map<String, dynamic>;
      for (final line in (payload['lines'] as List).cast<Map<String, dynamic>>()) {
        final id = line['poLineId'] as String;
        totals[id] = (totals[id] ?? 0) + (line['quantity'] as num).round();
      }
    }
    return totals;
  }

  PoStatus _status(List<PoLineItem> lines) {
    if (lines.isNotEmpty && lines.every((l) => l.alreadyReceived >= l.expected)) return PoStatus.received;
    return lines.any((l) => l.alreadyReceived > 0) ? PoStatus.inProgress : PoStatus.pending;
  }
}
