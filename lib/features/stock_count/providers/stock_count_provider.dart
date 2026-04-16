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
  CountSession? build() {
    ref.watch(db.appDatabaseProvider);
    return null;
  }

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
    await _persistSession(session);
    state = session;
  }

  Future<void> addItem(CountItem item) async {
    final current = state;
    if (current == null) return;
    final updated = current.copyWith(items: [...current.items, item]);
    await _persistSession(updated);
    state = updated;
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
    if (sessionRow == null) {
      state = null;
      return null;
    }

    final itemRows = await dao.getItemsForSession(sessionRow.id);
    final session = CountSession(
      id: sessionRow.id,
      location: sessionRow.location,
      label: sessionRow.label,
      startedAt: sessionRow.startedAt,
      status: _statusFromDb(sessionRow.status),
      items: itemRows.map(_itemFromDb).toList(),
    );
    state = session;
    return session;
  }

  Future<CountSession?> tryResumeSession() async {
    if (_resumeChecked) return state;
    _resumeChecked = true;
    return loadInProgressSession();
  }

  Future<void> _persistSession(CountSession session) async {
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
    await dao.replaceItemsForSession(
      session.id,
      session.items.map((item) => _itemToCompanion(session.id, item)).toList(),
    );
  }

  db.CountItemsCompanion _itemToCompanion(String sessionId, CountItem item) =>
      db.CountItemsCompanion.insert(
        id: '${sessionId}_${item.itemCode}_${item.counted}_${item.entryMethod.name}',
        sessionId: sessionId,
        itemCode: item.itemCode,
        itemName: item.itemName,
        expectedQty: item.expected,
        actualQty: item.counted,
        entryMethod: Value(item.entryMethod.name),
      );

  CountItem _itemFromDb(db.CountItem data) => CountItem(
        itemCode: data.itemCode,
        itemName: data.itemName,
        expected: data.expectedQty,
        counted: data.actualQty,
        entryMethod: _entryMethodFromDb(data.entryMethod),
      );

  CountSessionStatus _statusFromDb(String status) => status == 'submitted'
      ? CountSessionStatus.submitted
      : CountSessionStatus.inProgress;

  String _statusToDb(CountSessionStatus status) =>
      status == CountSessionStatus.submitted ? 'submitted' : 'in_progress';

  CountEntryMethod _entryMethodFromDb(String entryMethod) =>
      entryMethod == CountEntryMethod.typed.name
          ? CountEntryMethod.typed
          : CountEntryMethod.scanned;
}

final stockCountNotifierProvider =
    NotifierProvider<StockCountNotifier, CountSession?>(StockCountNotifier.new);
