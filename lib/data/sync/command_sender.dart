import 'dart:convert';

import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/local/app_database.dart';

/// The commands the phone queues.
class SyncOps {
  SyncOps._();

  static const countSubmit = 'count.submit';
  static const countApprove = 'count.approve';
  static const countReject = 'count.reject';
  static const receiptCreate = 'receipt.create';
  static const receiptSignature = 'receipt.signature';
  static const orderSave = 'order.save';
  static const orderStatus = 'order.status';
  static const taskCreate = 'task.create';
  static const taskAssign = 'task.assign';
  static const taskStart = 'task.start';
  static const taskComplete = 'task.complete';
  static const alertRead = 'alert.read';

  static const taskCommands = {taskCreate, taskAssign, taskStart, taskComplete};
}

/// Sends one queued command to its endpoint (spec §3 Commands) with the command's own Idempotency-Key.
class CommandSender {
  CommandSender(this._client);

  final ApiClient _client;

  Future<void> send(SyncQueueData item) async {
    final session = '/warehouses/${item.warehouseId}/count-sessions/${item.referenceId}';
    final key = item.idempotencyKey;
    // The phone's clock as it sends: the server shifts the times a command carries (counted at, received at) by how far
    // this clock is off.
    final clock = {'X-Client-Time': DateTime.now().toUtc().toIso8601String()};
    switch (item.operationType) {
      case SyncOps.countSubmit:
        await _client.post('$session/submit', body: jsonDecode(item.payload), idempotencyKey: key, headers: clock);
      case SyncOps.countApprove:
        await _client.post('$session/approve', idempotencyKey: key, headers: clock);
      case SyncOps.countReject:
        await _client.post('$session/reject', body: jsonDecode(item.payload), idempotencyKey: key, headers: clock);
      case SyncOps.receiptCreate:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.post(
          '/warehouses/${item.warehouseId}/purchase-orders/${payload['purchaseOrderId']}/receipts',
          body: {
            'receiptId': item.referenceId,
            'lines': payload['lines'],
            if (payload['receivedAt'] != null) 'receivedAt': payload['receivedAt'],
          },
          idempotencyKey: key,
          headers: clock,
        );
      case SyncOps.receiptSignature:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.putFile(
          '/warehouses/${item.warehouseId}/receipts/${item.referenceId}/signature',
          field: 'signature',
          filename: 'signature.png',
          bytes: base64Decode(payload['png'] as String),
          idempotencyKey: key,
          headers: clock,
        );
      case SyncOps.orderSave:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.put(_orderPath(item, payload), body: payload['body'], idempotencyKey: key, headers: clock);
      case SyncOps.orderStatus:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.post(
          '${_orderPath(item, payload)}/status',
          body: {'status': payload['status'], 'changedAt': payload['changedAt']},
          idempotencyKey: key,
          headers: clock,
        );
      case SyncOps.taskCreate:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.post('/warehouses/${item.warehouseId}/tasks', body: payload['body'], idempotencyKey: key, headers: clock);
      case SyncOps.taskAssign:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.post(
          '${_taskPath(item)}/assign',
          body: {'assigneeUserId': payload['assigneeUserId']},
          idempotencyKey: key,
          headers: clock,
        );
      case SyncOps.taskStart:
        await _client.post('${_taskPath(item)}/start', idempotencyKey: key, headers: clock);
      case SyncOps.taskComplete:
        await _client.post('${_taskPath(item)}/complete', idempotencyKey: key, headers: clock);
      case SyncOps.alertRead:
        await _client.post('/alerts/${item.referenceId}/read', idempotencyKey: key, headers: clock);
      default:
        throw UnsupportedError('Nothing sends "${item.operationType}" to the server.');
    }
  }

  String _taskPath(SyncQueueData item) => '/warehouses/${item.warehouseId}/tasks/${item.referenceId}';

  String _orderPath(SyncQueueData item, Map<String, dynamic> payload) =>
      '/warehouses/${item.warehouseId}/${payload['kind'] == 'Sales' ? 'sales' : 'delivery'}-orders/${item.referenceId}';
}
