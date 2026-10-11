import 'dart:convert';

import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/local/app_database.dart';

/// The commands the phone queues. 3b adds receiving, orders, tasks and alerts.
class SyncOps {
  SyncOps._();

  static const countSubmit = 'count.submit';
  static const countApprove = 'count.approve';
  static const countReject = 'count.reject';
}

/// Sends one queued command to its endpoint (spec §3 Commands) with the command's own Idempotency-Key.
class CommandSender {
  CommandSender(this._client);

  final ApiClient _client;

  Future<void> send(SyncQueueData item) async {
    final session = '/warehouses/${item.warehouseId}/count-sessions/${item.referenceId}';
    final key = item.idempotencyKey;
    switch (item.operationType) {
      case SyncOps.countSubmit:
        await _client.post('$session/submit', body: jsonDecode(item.payload), idempotencyKey: key);
      case SyncOps.countApprove:
        await _client.post('$session/approve', idempotencyKey: key);
      case SyncOps.countReject:
        await _client.post('$session/reject', body: jsonDecode(item.payload), idempotencyKey: key);
      default:
        throw UnsupportedError('Nothing sends "${item.operationType}" to the server.');
    }
  }
}
