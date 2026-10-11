import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';

class PendingReviewNotifier extends AsyncNotifier<List<CountSummary>> {
  @override
  Future<List<CountSummary>> build() => ref.watch(stockCountRepositoryProvider).getCountsToReview();

  /// Sends anything queued, pulls the latest counts, then reloads.
  Future<void> refresh() async {
    await ref.read(syncCoordinatorProvider).syncNow();
    ref.invalidateSelf();
  }
}

final pendingReviewProvider = AsyncNotifierProvider<PendingReviewNotifier, List<CountSummary>>(PendingReviewNotifier.new);

final countReviewProvider = FutureProvider.autoDispose.family<CountReview, String>(
  (ref, sessionId) => ref.watch(stockCountRepositoryProvider).getCountReview(sessionId),
);
