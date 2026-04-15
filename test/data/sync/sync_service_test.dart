import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

void main() {
  late AppDatabase db;
  late SyncService syncService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    syncService = SyncService(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('flushQueue marks all pending items as synced', () async {
    await db.syncQueueDao.enqueue(
      operationType: 'count_submit',
      referenceId: 's-1',
      payload: '{"sessionId":"s-1"}',
    );
    await db.syncQueueDao.enqueue(
      operationType: 'receive_submit',
      referenceId: 'po-1',
      payload: '{"poId":"po-1"}',
    );

    expect(await db.syncQueueDao.countPending(), 2);

    await syncService.flushQueue();

    expect(await db.syncQueueDao.countPending(), 0);
  });

  test('flushQueue is a no-op when queue is empty', () async {
    expect(await db.syncQueueDao.countPending(), 0);
    await syncService.flushQueue();
    expect(await db.syncQueueDao.countPending(), 0);
  });
}
