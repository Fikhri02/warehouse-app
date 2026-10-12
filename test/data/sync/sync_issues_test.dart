import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';

void main() {
  test('an order the server refused is named in Sync Issues', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final save = await db.syncQueueDao.enqueue(
      operationType: SyncOps.orderSave,
      referenceId: 'o1',
      warehouseId: 'w1',
      payload: jsonEncode({
        'kind': 'Delivery',
        'body': {'number': 'DO-261012-9F3C0000', 'destination': 'Outlet Cheras', 'deliveryDate': '2026-10-13', 'requiresApproval': false, 'notes': null, 'lines': []},
      }),
    );
    final status = await db.syncQueueDao.enqueue(
      operationType: SyncOps.orderStatus,
      referenceId: 'o1',
      warehouseId: 'w1',
      payload: jsonEncode({'kind': 'Delivery', 'status': 'Submitted', 'changedAt': '2026-10-12T02:00:00.000Z', 'number': 'DO-261012-9F3C0000', 'afterSave': save}),
    );
    await db.syncQueueDao.markFailed(save, const ApiException(status: 422, title: 'Location is not in this warehouse.'));
    await db.syncQueueDao.markFailed(status, const ApiException(status: 0, title: 'Status not sent: the order was not saved.'));
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    final issues = await container.read(syncIssuesProvider.future);

    expect(issues.map((i) => i.message), [
      'DO-261012-9F3C0000: Status not sent: the order was not saved.',
      'DO-261012-9F3C0000 (Outlet Cheras): Location is not in this warehouse.',
    ]);
  });
}
