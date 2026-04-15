import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';

export 'package:warehouse_app/data/repositories/alerts_repository.dart'
    show alertsRepositoryProvider;

class PendingReviewNotifier extends AsyncNotifier<List<Alert>> {
  @override
  Future<List<Alert>> build() async {
    return ref.watch(alertsRepositoryProvider).getPendingReviews();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final pendingReviewProvider =
    AsyncNotifierProvider<PendingReviewNotifier, List<Alert>>(
  PendingReviewNotifier.new,
);
