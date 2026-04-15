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
    await into(countSessions).insertOnConflictUpdate(session);
    return session.id.value;
  }

  Future<void> addItem(CountItemsCompanion item) =>
      into(countItems).insertOnConflictUpdate(item);

  Future<List<CountItem>> getItemsForSession(String sessionId) =>
      (select(countItems)..where((i) => i.sessionId.equals(sessionId))).get();

  Future<void> submitSession(String sessionId) =>
      (update(countSessions)..where((s) => s.id.equals(sessionId))).write(
        CountSessionsCompanion(
          status: const Value('submitted'),
          submittedAt: Value(DateTime.now()),
        ),
      );
}
