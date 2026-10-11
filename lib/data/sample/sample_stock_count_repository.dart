import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/sample/sample_locations.dart';

class SampleStockCountRepository implements StockCountRepository {
  static const _catalogue = {
    'WH-00142': 'Aluminium Sheet 2mm',
    'WH-00089': 'Steel Bolt M8',
    'WH-00210': 'Copper Wire 4mm',
    'WH-00301': 'PVC Pipe 20mm',
  };

  final List<CountSession> _sessions = [];

  @override
  Future<CatalogItemRef?> lookupItemByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final name = _catalogue[barcode];
    return name == null ? null : CatalogItemRef(id: barcode, sku: barcode, name: name);
  }

  @override
  Future<List<CatalogItemRef>> searchItems(String term) async {
    final query = term.trim().toLowerCase();
    return [
      for (final entry in _catalogue.entries)
        if (entry.key.toLowerCase().contains(query) || entry.value.toLowerCase().contains(query))
          CatalogItemRef(id: entry.key, sku: entry.key, name: entry.value),
    ];
  }

  @override
  Future<List<CountLocation>> getLocations() async =>
      [for (final location in sampleLocations) CountLocation(id: location.id, code: location.name, kind: 'Area')];

  @override
  Future<List<CountSummary>> getRecentCounts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      for (final session in _sessions.reversed.take(10))
        CountSummary(
          id: session.id,
          title: session.label ?? session.location,
          lineCount: session.items.length,
          progress: CountProgress.waitingReview,
          submittedAt: session.startedAt,
        ),
    ];
  }

  @override
  Future<void> submitSession(CountSession session) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _sessions.add(session.copyWith(status: CountSessionStatus.submitted));
  }

  final List<CountSummary> _toReview = [
    CountSummary(id: 'sample-review-1', title: 'Aisle C', lineCount: 3, progress: CountProgress.waitingReview, submittedAt: DateTime(2026, 4, 18, 9)),
  ];

  @override
  Future<List<CountSummary>> getCountsToReview() async => List.unmodifiable(_toReview);

  @override
  Future<CountReview> getCountReview(String sessionId) async => CountReview(
        id: sessionId,
        title: 'Aisle C',
        countedBy: 'John Doe',
        submittedAt: DateTime(2026, 4, 18, 9),
        status: 'Submitted',
        lines: const [
          CountReviewLine(itemName: 'Steel Bolt M8', sku: 'WH-00089', locationCode: 'Aisle C', counted: 40, systemAtSubmit: 42, current: 42, difference: -2),
          CountReviewLine(itemName: 'Copper Wire 4mm', sku: 'WH-00210', locationCode: 'Aisle C', counted: 12, systemAtSubmit: 12, current: 12, difference: 0),
        ],
      );

  @override
  Future<void> approveCount(String sessionId) async => _toReview.removeWhere((c) => c.id == sessionId);

  @override
  Future<void> rejectCount(String sessionId, String reason) async => _toReview.removeWhere((c) => c.id == sessionId);
}
