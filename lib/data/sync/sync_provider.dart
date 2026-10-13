import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/config/app_config.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/core/providers/connectivity_provider.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/api/api_providers.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_coordinator.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SyncService(db: db, sender: ref.watch(useApiProvider) ? CommandSender(ref.watch(apiClientProvider)) : null);
});

final changeFeedPullerProvider = Provider<ChangeFeedPuller?>((ref) {
  if (!ref.watch(useApiProvider)) return null;
  return ChangeFeedPuller(client: ref.watch(apiClientProvider), db: ref.watch(appDatabaseProvider));
});

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) => SyncCoordinator(
      outbox: ref.watch(syncServiceProvider),
      puller: ref.watch(changeFeedPullerProvider),
      warehouseId: () => ref.read(authNotifierProvider).valueOrNull?.warehouseId,
    ));

/// Tries again while changes wait. A dead zone or a busy server often brings no connectivity event, so a paused
/// outbox would otherwise wait for one forever.
class SyncRetry {
  SyncRetry({required Future<int> Function() pending, required Future<void> Function() sync})
      : _pending = pending,
        _sync = sync;

  final Future<int> Function() _pending;
  final Future<void> Function() _sync;

  Future<void> tick() async {
    if (await _pending() > 0) await _sync();
  }
}

/// Syncs when the phone comes back online, when the app returns to the foreground, every minute while changes
/// wait, and whenever a warehouse is chosen (sign-in, restart, switch).
/// Attach this provider in WarehouseApp.build() to activate it.
final syncWatcherProvider = Provider<void>((ref) {
  final retry = SyncRetry(
    pending: () => ref.read(appDatabaseProvider).syncQueueDao.countPending(),
    sync: () => ref.read(syncCoordinatorProvider).syncNow(),
  );
  final timer = Timer.periodic(const Duration(minutes: 1), (_) => unawaited(retry.tick()));
  final lifecycle = AppLifecycleListener(onResume: () => unawaited(ref.read(syncCoordinatorProvider).syncNow()));
  ref.onDispose(() {
    timer.cancel();
    lifecycle.dispose();
  });

  ref.listen<bool>(isOnlineProvider, (previous, next) {
    if (previous == false && next) unawaited(ref.read(syncCoordinatorProvider).syncNow());
  });
  ref.listen<String?>(
    authNotifierProvider.select((auth) => auth.valueOrNull?.warehouseId),
    (previous, next) {
      if (next != null && next != previous) unawaited(ref.read(syncCoordinatorProvider).syncNow());
    },
    fireImmediately: true,
  );
});

final pendingChangesProvider = StreamProvider<int>((ref) => ref.watch(appDatabaseProvider).syncQueueDao.watchPendingCount());

/// A command the server did not accept, with its reason.
class SyncIssue {
  const SyncIssue({required this.id, required this.title, required this.message});

  final int id;
  final String title;
  final String message;
}

final syncIssuesProvider = StreamProvider<List<SyncIssue>>((ref) {
  return ref.watch(appDatabaseProvider).syncQueueDao.watchIssues().map((items) => [
        for (final item in items)
          SyncIssue(
            id: item.id,
            title: switch (item.operationType) {
              SyncOps.countSubmit => 'Count not accepted',
              SyncOps.countApprove => 'Approval not accepted',
              SyncOps.countReject => 'Rejection not accepted',
              SyncOps.receiptCreate => 'Receipt not accepted',
              SyncOps.receiptSignature => 'Signature not sent',
              SyncOps.orderSave => 'Order not saved',
              SyncOps.orderStatus => 'Status change not accepted',
              SyncOps.taskCreate => 'Task not created',
              SyncOps.taskAssign => 'Assignment not accepted',
              SyncOps.taskStart => 'Start not accepted',
              SyncOps.taskComplete => 'Task not finished',
              SyncOps.alertRead => 'Alert not marked read',
              _ => 'Change not accepted',
            },
            message: _naming(
              item,
              item.lastError == null
                  ? 'WareTrack refused this change.'
                  : ApiException.fromJson(jsonDecode(item.lastError!) as Map<String, dynamic>).message,
            ),
          ),
      ]);
});

/// Puts the order's number (and where it goes), or the task's title, in front of the reason, so the person knows what to
/// redo.
String _naming(SyncQueueData item, String message) {
  if (SyncOps.taskCommands.contains(item.operationType)) {
    // The server's conflict sentences already quote the title; don't say it twice.
    final title = (jsonDecode(item.payload) as Map<String, dynamic>)['title'] as String?;
    return title == null || message.contains(title) ? message : '$title: $message';
  }
  if (item.operationType != SyncOps.orderSave && item.operationType != SyncOps.orderStatus) return message;
  final payload = jsonDecode(item.payload) as Map<String, dynamic>;
  final body = payload['body'] as Map<String, dynamic>?;
  final number = (body?['number'] ?? payload['number']) as String?;
  if (number == null) return message;
  final to = (body?['destination'] ?? body?['customerName']) as String?;
  return to == null ? '$number: $message' : '$number ($to): $message';
}
