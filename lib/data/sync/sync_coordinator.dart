import 'package:warehouse_app/data/api/api_exception.dart';

import 'change_feed_puller.dart';
import 'sync_service.dart';

/// Sends the outbox, then pulls what changed. Runs one at a time; asking during a run asks for one more run
/// afterwards, so nothing queued meanwhile waits for the next trigger.
class SyncCoordinator {
  SyncCoordinator({
    required SyncService outbox,
    required ChangeFeedPuller? puller,
    required String? Function() warehouseId,
    void Function()? onPulled,
  })  : _outbox = outbox,
        _puller = puller,
        _warehouseId = warehouseId,
        _onPulled = onPulled;

  final SyncService _outbox;
  final ChangeFeedPuller? _puller;
  final String? Function() _warehouseId;

  /// Called after every pull that reached the end of the feed.
  final void Function()? _onPulled;
  Future<void>? _running;
  bool _again = false;

  Future<void> syncNow() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      await _runOnce();
    } while (_again);
  }

  Future<void> _runOnce() async {
    final outcome = await _outbox.flushQueue();
    final warehouseId = _warehouseId();
    final puller = _puller;
    if (puller == null || warehouseId == null) return;
    if (outcome == FlushOutcome.offline || outcome == FlushOutcome.sessionExpired) return;
    try {
      await puller.pull(warehouseId);
      _onPulled?.call();
    } on ApiOfflineException {
      // Next reconnect.
    } on ApiException {
      // Server trouble: next run.
    } on SessionExpiredException {
      // The client has already sent the person back to sign-in.
    }
  }
}
