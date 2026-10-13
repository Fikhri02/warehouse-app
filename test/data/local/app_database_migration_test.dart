import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/data/local/app_database.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('waretrack_db_'));
  tearDown(() => dir.deleteSync(recursive: true));

  /// The database a phone on schema 5 has: none of the tables or columns 6 and 7 added.
  Future<File> schema5Database() async {
    final file = File('${dir.path}/app.db');
    final db = AppDatabase.forTesting(NativeDatabase(file));
    await db.customSelect('SELECT 1').get();
    for (final table in [
      'catalog_items', 'catalog_barcodes', 'warehouse_locations', 'remote_count_sessions', 'remote_count_lines',
      'sync_cursors', 'remote_purchase_orders', 'remote_po_lines', 'remote_orders', 'remote_order_lines',
      'remote_tasks', 'remote_alerts', 'warehouse_members',
    ]) {
      await db.customStatement('DROP TABLE $table');
    }
    for (final (table, column) in [
      ('count_items', 'item_id'), ('sync_queue', 'idempotency_key'), ('sync_queue', 'status'),
      ('sync_queue', 'attempts'), ('sync_queue', 'last_error'), ('sync_queue', 'warehouse_id'),
    ]) {
      await db.customStatement('ALTER TABLE $table DROP COLUMN $column');
    }
    await db.customStatement('PRAGMA user_version = 5');
    await db.close();
    return file;
  }

  test('a phone on schema 5 upgrades to the current schema and pulls from the start', () async {
    final db = AppDatabase.forTesting(NativeDatabase(await schema5Database()));
    addTearDown(db.close);

    expect(await db.serverMirrorDao.cursorFor('w1'), 0);
    expect(await db.serverMirrorDao.purchaseOrders('w1'), isEmpty);
    expect(await db.customSelect('SELECT mirror_version FROM sync_cursors').get(), isEmpty);
  });

  test('a phone on schema 7 gains the order tables and pulls from the start', () async {
    final file = File('${dir.path}/app7.db');
    final old = AppDatabase.forTesting(NativeDatabase(file));
    await old.serverMirrorDao.saveCursor('w1', 40);
    await old.customStatement('DROP TABLE remote_orders');
    await old.customStatement('DROP TABLE remote_order_lines');
    for (final table in ['remote_tasks', 'remote_alerts', 'warehouse_members']) {
      await old.customStatement('DROP TABLE $table');
    }
    await old.customStatement('UPDATE sync_cursors SET mirror_version = 2');
    await old.customStatement('PRAGMA user_version = 7');
    await old.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    expect(await db.serverMirrorDao.orders('w1', kind: 'Delivery'), isEmpty);
    expect(await db.serverMirrorDao.cursorFor('w1'), 0); // the 3b copy never kept orders: read the feed again
  });

  test('a phone on schema 8 swaps the old task and alert tables for the server copies and pulls from the start', () async {
    final file = File('${dir.path}/app8.db');
    final old = AppDatabase.forTesting(NativeDatabase(file));
    await old.serverMirrorDao.saveCursor('w1', 90);
    for (final table in ['remote_tasks', 'remote_alerts', 'warehouse_members']) {
      await old.customStatement('DROP TABLE $table');
    }
    await old.customStatement(
        'CREATE TABLE alerts (id TEXT NOT NULL PRIMARY KEY, type TEXT NOT NULL, title TEXT NOT NULL, body TEXT NOT NULL, '
        'created_at INTEGER NOT NULL, is_read INTEGER NOT NULL DEFAULT 0)');
    await old.customStatement(
        'CREATE TABLE staff_tasks (id TEXT NOT NULL PRIMARY KEY, type TEXT NOT NULL, location TEXT NOT NULL, '
        'due_at INTEGER NOT NULL, status TEXT NOT NULL, assigned_to TEXT NOT NULL)');
    await old.customStatement('UPDATE sync_cursors SET mirror_version = 3');
    await old.customStatement('PRAGMA user_version = 8');
    await old.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    expect(await db.serverMirrorDao.tasks('w1'), isEmpty);
    expect(await db.serverMirrorDao.alerts('w1'), isEmpty);
    expect(await db.serverMirrorDao.members('w1'), isEmpty);
    expect(await db.customSelect("SELECT name FROM sqlite_master WHERE name IN ('alerts', 'staff_tasks')").get(), isEmpty);
    expect(await db.serverMirrorDao.cursorFor('w1'), 0); // the 3c copy never kept tasks or alerts: read the feed again
  });
}
