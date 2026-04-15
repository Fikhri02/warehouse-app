import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/count_session.dart';

abstract class StockCountRepository {
  Future<String?> lookupItemByBarcode(String barcode);
  Future<List<CountSession>> getRecentSessions();
  Future<void> submitSession(CountSession session);
}

final stockCountRepositoryProvider = Provider<StockCountRepository>((ref) {
  throw UnimplementedError('stockCountRepositoryProvider not overridden');
});
