import 'package:drift/drift.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/local/tables/count_session_table.dart';

part 'count_session_dao.g.dart';

@DriftAccessor(tables: [CountSessions, CountItems])
class CountSessionDao extends DatabaseAccessor<AppDatabase>
    with _$CountSessionDaoMixin {
  CountSessionDao(super.db);

  Future<List<CountSession>> getAllSessions() => select(countSessions).get();

  Future<String> createSession(CountSessionsCompanion session) async {
    await saveOrUpdateDraft(session);
    return session.id.value;
  }

  Future<void> addItem(CountItemsCompanion item) =>
      into(countItems).insertOnConflictUpdate(item);

  Future<void> replaceItemsForSession(
    String sessionId,
    List<CountItemsCompanion> items,
  ) async {
    await transaction(() async {
      await (delete(countItems)..where((i) => i.sessionId.equals(sessionId)))
          .go();
      if (items.isNotEmpty) {
        await batch(
            (batch) => batch.insertAllOnConflictUpdate(countItems, items));
      }
    });
  }

  Future<List<CountItem>> getItemsForSession(String sessionId) =>
      (select(countItems)..where((i) => i.sessionId.equals(sessionId))).get();

  Future<CountSession?> getLatestInProgressSession() {
    final query = select(countSessions)
      ..where((s) => s.status.equals('in_progress'))
      ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<CountSession?> getSessionById(String sessionId) =>
      (select(countSessions)..where((s) => s.id.equals(sessionId)))
          .getSingleOrNull();

  Future<void> deleteItem(String itemId) =>
      (delete(countItems)..where((i) => i.id.equals(itemId))).go();

  Future<void> updateItemQty(String itemId, int qty) =>
      (update(countItems)..where((i) => i.id.equals(itemId))).write(
        CountItemsCompanion(actualQty: Value(qty)),
      );

  Future<void> submitSession(String sessionId) =>
      (update(countSessions)..where((s) => s.id.equals(sessionId))).write(
        CountSessionsCompanion(
          status: const Value('submitted'),
          submittedAt: Value(DateTime.now()),
        ),
      );

  Future<void> saveOrUpdateDraft(CountSessionsCompanion session) =>
      into(countSessions).insertOnConflictUpdate(session);

  Future<List<CountSession>> getInProgressByLocation(String locationId) =>
      (select(countSessions)
            ..where(
              (s) =>
                  s.status.equals('in_progress') &
                  s.locationId.equals(locationId),
            ))
          .get();

  Future<void> discardSession(String sessionId) async {
    await transaction(() async {
      await (delete(countItems)..where((i) => i.sessionId.equals(sessionId)))
          .go();
      await (delete(countSessions)..where((s) => s.id.equals(sessionId))).go();
    });
  }
}
