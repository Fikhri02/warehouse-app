import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/providers/connectivity_provider.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SyncService(db: db);
});

/// Watches connectivity and triggers flush when the app goes online.
/// Attach this provider in WarehouseApp.build() to activate it.
final syncWatcherProvider = Provider<void>((ref) {
  bool wasOffline = false;

  ref.listen<bool>(isOnlineProvider, (prev, next) {
    final comingOnline = (prev == false || wasOffline) && next == true;
    if (comingOnline) {
      final sync = ref.read(syncServiceProvider);
      sync.flushQueue().catchError((e) {
        // ignore: avoid_print
        print('[SyncWatcher] Flush failed: $e');
      });
    }
    wasOffline = !next;
  });
});
