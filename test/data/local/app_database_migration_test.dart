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
      'sync_cursors', 'remote_purchase_orders', 'remote_po_lines',
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
}
