import 'dart:async';
import 'dart:convert';

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

/// Syncs when the phone comes back online and whenever a warehouse is chosen (sign-in, restart, switch).
/// Attach this provider in WarehouseApp.build() to activate it.
final syncWatcherProvider = Provider<void>((ref) {
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
              _ => 'Change not accepted',
            },
            message: item.lastError == null
                ? 'WareTrack refused this change.'
                : ApiException.fromJson(jsonDecode(item.lastError!) as Map<String, dynamic>).message,
          ),
      ]);
});
