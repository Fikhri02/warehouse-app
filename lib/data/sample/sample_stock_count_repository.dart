import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';

class SampleStockCountRepository implements StockCountRepository {
  static const _catalogue = {
    'WH-00142': 'Aluminium Sheet 2mm',
    'WH-00089': 'Steel Bolt M8',
    'WH-00210': 'Copper Wire 4mm',
    'WH-00301': 'PVC Pipe 20mm',
  };

  final List<CountSession> _sessions = [];

  @override
  Future<String?> lookupItemByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _catalogue[barcode];
  }

  @override
  Future<List<CountSession>> getRecentSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_sessions.reversed.take(10).toList());
  }

  @override
  Future<void> submitSession(CountSession session) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _sessions.add(session.copyWith(status: CountSessionStatus.submitted));
  }
}
