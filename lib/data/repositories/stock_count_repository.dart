import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';

abstract class StockCountRepository {
  /// The item a barcode belongs to, or null when nobody knows it.
  Future<CatalogItemRef?> lookupItemByBarcode(String barcode);

  /// Items whose SKU or name contains [term], for counting without a barcode.
  Future<List<CatalogItemRef>> searchItems(String term);

  /// Where counts can happen in the current warehouse.
  Future<List<CountLocation>> getLocations();

  /// This person's latest counts: waiting to send, refused, or reviewed.
  Future<List<CountSummary>> getRecentCounts();

  /// Hands a finished count over for sending (queued until the server has it).
  Future<void> submitSession(CountSession session);

  /// Submitted counts in the current warehouse that nobody has decided on yet (supervisors).
  Future<List<CountSummary>> getCountsToReview();

  /// The count with live stock figures. Needs a connection.
  Future<CountReview> getCountReview(String sessionId);

  Future<void> approveCount(String sessionId);

  Future<void> rejectCount(String sessionId, String reason);
}

final stockCountRepositoryProvider = Provider<StockCountRepository>((ref) {
  throw UnimplementedError('stockCountRepositoryProvider not overridden');
});

final recentCountsProvider = FutureProvider.autoDispose<List<CountSummary>>(
  (ref) => ref.watch(stockCountRepositoryProvider).getRecentCounts(),
);

final countLocationsProvider = FutureProvider.autoDispose<List<CountLocation>>(
  (ref) => ref.watch(stockCountRepositoryProvider).getLocations(),
);
