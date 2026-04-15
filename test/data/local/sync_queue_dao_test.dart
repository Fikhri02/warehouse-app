import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('enqueue adds a pending item', () async {
    await db.syncQueueDao.enqueue(
      operationType: 'count_submit',
      referenceId: 'session-1',
      payload: '{"sessionId":"session-1"}',
    );

    final pending = await db.syncQueueDao.getPendingItems();
    expect(pending.length, 1);
    expect(pending.first.operationType, 'count_submit');
    expect(pending.first.synced, isFalse);
  });

  test('markSynced updates synced flag', () async {
    final id = await db.syncQueueDao.enqueue(
      operationType: 'receive_submit',
      referenceId: 'po-1',
      payload: '{"poId":"po-1"}',
    );

    await db.syncQueueDao.markSynced(id);
    final pending = await db.syncQueueDao.getPendingItems();
    expect(pending, isEmpty);
  });

  test('countPending returns correct count', () async {
    await db.syncQueueDao.enqueue(
      operationType: 'count_submit',
      referenceId: 's-1',
      payload: '{}',
    );
    await db.syncQueueDao.enqueue(
      operationType: 'count_submit',
      referenceId: 's-2',
      payload: '{}',
    );

    expect(await db.syncQueueDao.countPending(), 2);
  });
}
