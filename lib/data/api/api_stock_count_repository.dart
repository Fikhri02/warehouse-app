import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide CountItem, CountSession, UserSession; // its generated row clashes with the model
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

import 'api_client.dart';
import 'api_exception.dart';

final _guid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

/// Counts against the server: the catalogue and locations from the phone's copy, finished counts through the outbox.
class ApiStockCountRepository implements StockCountRepository {
  ApiStockCountRepository({
    required ApiClient client,
    required AppDatabase db,
    required UserSession? Function() session,
    required void Function() onQueued,
  })  : _client = client,
        _db = db,
        _session = session,
        _onQueued = onQueued;

  final ApiClient _client;
  final AppDatabase _db;
  final UserSession? Function() _session;
  final void Function() _onQueued;

  @override
  Future<CatalogItemRef?> lookupItemByBarcode(String barcode) async {
    final known = await _db.serverMirrorDao.itemByBarcode(barcode);
    if (known != null) return CatalogItemRef(id: known.id, sku: known.sku, name: known.name);
    try {
      // A code added on the server since the last pull (spec §3: online lookup for barcodes not yet cached).
      final found = await _client.get('/catalog/barcodes/${Uri.encodeComponent(barcode)}') as Map<String, dynamic>;
      final item = found['item'] as Map<String, dynamic>;
      return CatalogItemRef(id: item['id'] as String, sku: item['sku'] as String, name: item['name'] as String);
    } on ApiException {
      return null; // 404: nobody knows this code
    } on ApiOfflineException {
      return null; // offline and not in the copy: the counter can pick the item by name instead
    }
  }

  @override
  Future<List<CatalogItemRef>> searchItems(String term) async => [
        for (final item in await _db.serverMirrorDao.searchItems(term)) CatalogItemRef(id: item.id, sku: item.sku, name: item.name),
      ];

  @override
  Future<List<CountLocation>> getLocations() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    return [
      for (final location in await _db.serverMirrorDao.locationsFor(warehouseId))
        CountLocation(id: location.id, code: location.code, kind: location.type),
    ];
  }

  @override
  Future<void> submitSession(CountSession session) async {
    final locationId = session.locationId;
    if (locationId == null) throw StateError('Choose where you are counting first.');
    // The count belongs to the warehouse its location is in, even if the person switched warehouse meanwhile.
    final location = await _db.serverMirrorDao.locationById(locationId);
    final warehouseId = location?.warehouseId ?? _session()?.warehouseId;
    if (warehouseId == null) throw StateError('No warehouse chosen.');

    // The server takes each item once per location: entries of the same item are added up.
    final totals = <String, int>{};
    for (final item in session.items) {
      final itemId = item.itemId;
      if (itemId == null) throw StateError('${item.itemName} is not in the catalogue.');
      totals[itemId] = (totals[itemId] ?? 0) + item.counted;
    }
    final label = session.label?.trim();
    await _db.syncQueueDao.enqueue(
      operationType: SyncOps.countSubmit,
      referenceId: _guid.hasMatch(session.id) ? session.id : const Uuid().v4(),
      warehouseId: warehouseId,
      payload: jsonEncode({
        'label': label == null || label.isEmpty ? session.location : label,
        'lines': [
          for (final entry in totals.entries) {'itemId': entry.key, 'locationId': locationId, 'counted': entry.value},
        ],
      }),
    );
    _onQueued();
  }

  @override
  Future<List<CountSummary>> getRecentCounts() async {
    final session = _session();
    final warehouseId = session?.warehouseId;
    if (session == null || warehouseId == null) return const [];
    final summaries = <CountSummary>[
      for (final item in await _db.syncQueueDao.itemsFor(SyncOps.countSubmit, warehouseId: warehouseId)) _queued(item),
    ];
    for (final row in await _db.serverMirrorDao.countSessions(warehouseId: warehouseId, createdBy: session.userId, limit: 10)) {
      summaries.add(CountSummary(
        id: row.id,
        title: row.label ?? 'Count',
        lineCount: (await _db.serverMirrorDao.linesFor(row.id)).length,
        progress: switch (row.status) {
          'Approved' => CountProgress.approved,
          'Rejected' => CountProgress.rejected,
          _ => CountProgress.waitingReview,
        },
        submittedAt: row.submittedAt,
        note: row.rejectReason,
      ));
    }
    return summaries;
  }

  @override
  Future<List<CountSummary>> getCountsToReview() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final decided = {
      for (final op in [SyncOps.countApprove, SyncOps.countReject])
        for (final item in await _db.syncQueueDao.itemsFor(op)) item.referenceId,
    };
    return [
      for (final row in await _db.serverMirrorDao.countSessions(warehouseId: warehouseId, status: 'Submitted', limit: 100))
        if (!decided.contains(row.id))
          CountSummary(
            id: row.id,
            title: row.label ?? 'Count',
            lineCount: (await _db.serverMirrorDao.linesFor(row.id)).length,
            progress: CountProgress.waitingReview,
            submittedAt: row.submittedAt,
          ),
    ];
  }

  @override
  Future<CountReview> getCountReview(String sessionId) async {
    final warehouseId = _session()?.warehouseId;
    final json = await _client.get('/warehouses/$warehouseId/count-reviews/$sessionId') as Map<String, dynamic>;
    return CountReview(
      id: json['id'] as String,
      title: json['label'] as String? ?? 'Count',
      countedBy: json['createdByName'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String).toLocal(),
      status: json['status'] as String,
      lines: [
        for (final l in (json['lines'] as List).cast<Map<String, dynamic>>())
          CountReviewLine(
            itemName: l['itemName'] as String,
            sku: l['sku'] as String,
            locationCode: l['locationCode'] as String,
            counted: (l['counted'] as num).toDouble(),
            systemAtSubmit: (l['systemAtSubmit'] as num).toDouble(),
            current: (l['current'] as num).toDouble(),
            difference: (l['difference'] as num).toDouble(),
          ),
      ],
    );
  }

  @override
  Future<void> approveCount(String sessionId) => _decide(SyncOps.countApprove, sessionId, const {});

  @override
  Future<void> rejectCount(String sessionId, String reason) => _decide(SyncOps.countReject, sessionId, {'reason': reason});

  Future<void> _decide(String op, String sessionId, Map<String, Object?> body) async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) throw StateError('No warehouse chosen.');
    await _db.syncQueueDao.enqueue(operationType: op, referenceId: sessionId, warehouseId: warehouseId, payload: jsonEncode(body));
    _onQueued();
  }

  CountSummary _queued(SyncQueueData item) {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    final refused = item.status != 'pending';
    return CountSummary(
      id: item.referenceId,
      title: payload['label'] as String? ?? 'Count',
      lineCount: (payload['lines'] as List).length,
      progress: refused ? CountProgress.notAccepted : CountProgress.sending,
      submittedAt: item.queuedAt,
      note: refused && item.lastError != null
          ? ApiException.fromJson(jsonDecode(item.lastError!) as Map<String, dynamic>).message
          : null,
    );
  }
}
