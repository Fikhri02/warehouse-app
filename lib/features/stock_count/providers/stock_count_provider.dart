import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/models/count_session.dart';
import '../../../data/local/app_database.dart' as db;
import '../../../data/repositories/stock_count_repository.dart';

export '../../../data/repositories/stock_count_repository.dart'
    show stockCountRepositoryProvider;

class StockCountNotifier extends Notifier<CountSession?> {
  bool _resumeChecked = false;

  @override
  CountSession? build() => null;

  Future<void> startSession({
    required String location,
    String? label,
  }) async {
    final session = CountSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      location: location,
      label: label,
      startedAt: DateTime.now(),
      status: CountSessionStatus.inProgress,
    );
    final dao = ref.read(db.appDatabaseProvider).countSessionDao;
    await dao.createSession(
      db.CountSessionsCompanion.insert(
        id: session.id,
        location: session.location,
        status: _statusToDb(session.status),
        startedAt: session.startedAt,
        label: Value(session.label),
      ),
    );
    state = session;
  }

  Future<void> addItem(CountItem item) async {
    final current = state;
    if (current == null) return;
    final dao = ref.read(db.appDatabaseProvider).countSessionDao;
    await dao.addItem(
      db.CountItemsCompanion.insert(
        id: item.id,
        sessionId: current.id,
        itemCode: item.itemCode,
        itemName: item.itemName,
        expectedQty: item.expected,
        actualQty: item.counted,
        entryMethod: Value(item.entryMethod.name),
      ),
    );
    state = current.copyWith(items: [...current.items, item]);
  }

  Future<void> removeItem(String itemId) async {
    final current = state;
    if (current == null) return;
    await ref.read(db.appDatabaseProvider).countSessionDao.deleteItem(itemId);
    state = current.copyWith(
      items: current.items.where((i) => i.id != itemId).toList(),
    );
  }

  Future<void> updateItemQty(String itemId, int newQty) async {
    final current = state;
    if (current == null) return;
    await ref
        .read(db.appDatabaseProvider)
        .countSessionDao
        .updateItemQty(itemId, newQty);
    state = current.copyWith(
      items: current.items
          .map((i) => i.id == itemId ? i.copyWith(counted: newQty) : i)
          .toList(),
    );
  }

  Future<void> submitSession() async {
    final current = state;
    if (current == null) return;
    final toSubmit = current.copyWith(status: CountSessionStatus.submitted);
    await ref.read(stockCountRepositoryProvider).submitSession(toSubmit);
    await ref
        .read(db.appDatabaseProvider)
        .countSessionDao
        .submitSession(current.id);
    state = null;
  }

  Future<CountSession?> loadInProgressSession() async {
    final dao = ref.read(db.appDatabaseProvider).countSessionDao;
    final sessionRow = await dao.getLatestInProgressSession();
    return _hydrateSession(sessionRow);
  }

  Future<CountSession?> loadSessionById(String sessionId) async {
    final dao = ref.read(db.appDatabaseProvider).countSessionDao;
    final sessionRow = await dao.getSessionById(sessionId);
    return _hydrateSession(sessionRow);
  }

  Future<CountSession?> tryResumeSession() async {
    if (_resumeChecked) return state;
    _resumeChecked = true;
    return loadInProgressSession();
  }

  CountItem _itemFromDb(db.CountItem data) => CountItem(
        id: data.id,
        itemCode: data.itemCode,
        itemName: data.itemName,
        expected: data.expectedQty,
        counted: data.actualQty,
        entryMethod: _entryMethodFromDb(data.entryMethod),
      );

  Future<CountSession?> _hydrateSession(db.CountSession? sessionRow) async {
    if (sessionRow == null) {
      state = null;
      return null;
    }

    final itemRows = await ref
        .read(db.appDatabaseProvider)
        .countSessionDao
        .getItemsForSession(sessionRow.id);
    final session = CountSession(
      id: sessionRow.id,
      location: sessionRow.location,
      label: sessionRow.label,
      startedAt: sessionRow.startedAt,
      status: _statusFromDb(sessionRow.status),
      items: itemRows.map(_itemFromDb).toList(),
      locationId: sessionRow.locationId,
      assignedWorkerId: sessionRow.assignedWorkerId,
      deadline: sessionRow.deadline,
      zoneAisle: sessionRow.zoneAisle,
    );
    state = session;
    return session;
  }

  CountSessionStatus _statusFromDb(String status) {
    switch (status) {
      case 'draft':
        return CountSessionStatus.draft;
      case 'submitted':
        return CountSessionStatus.submitted;
      case 'approved':
        return CountSessionStatus.approved;
      case 'in_progress':
      default:
        return CountSessionStatus.inProgress;
    }
  }

  String _statusToDb(CountSessionStatus status) {
    switch (status) {
      case CountSessionStatus.draft:
        return 'draft';
      case CountSessionStatus.submitted:
        return 'submitted';
      case CountSessionStatus.approved:
        return 'approved';
      case CountSessionStatus.inProgress:
        return 'in_progress';
    }
  }

  CountEntryMethod _entryMethodFromDb(String entryMethod) =>
      entryMethod == CountEntryMethod.typed.name
          ? CountEntryMethod.typed
          : CountEntryMethod.scanned;
}

final stockCountNotifierProvider =
    NotifierProvider<StockCountNotifier, CountSession?>(StockCountNotifier.new);
