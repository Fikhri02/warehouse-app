import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/data/local/app_database.dart';

RemoteAlertsCompanion alert(String id, String? warehouseId, DateTime at) => RemoteAlertsCompanion.insert(
      id: id,
      warehouseId: Value(warehouseId),
      type: 'LowStock',
      title: id,
      body: '',
      createdAt: at,
    );

WarehouseMembersCompanion member(String warehouseId, String userId, String name) => WarehouseMembersCompanion.insert(
      warehouseId: warehouseId,
      userId: userId,
      displayName: name,
      role: 'Worker',
      isActive: true,
    );

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test("a warehouse's alerts include those for no warehouse, not another warehouse's, newest first", () async {
    final dao = db.serverMirrorDao;
    await dao.upsertAlert(alert('mine-old', 'w1', DateTime(2026, 10, 13, 8)));
    await dao.upsertAlert(alert('anywhere', null, DateTime(2026, 10, 13, 9)));
    await dao.upsertAlert(alert('elsewhere', 'w2', DateTime(2026, 10, 13, 10)));
    await dao.upsertAlert(alert('mine-new', 'w1', DateTime(2026, 10, 13, 11)));

    expect((await dao.alerts('w1')).map((a) => a.id), ['mine-new', 'anywhere', 'mine-old']);
  });

  test("saving a warehouse's team replaces its list and leaves other warehouses alone", () async {
    final dao = db.serverMirrorDao;
    await dao.replaceMembers('w1', [member('w1', 'u1', 'Old Name'), member('w1', 'u2', 'Gone')]);
    await dao.replaceMembers('w2', [member('w2', 'u3', 'Elsewhere')]);

    await dao.replaceMembers('w1', [member('w1', 'u1', 'Arjun Nair')]);

    expect((await dao.members('w1')).map((m) => m.displayName), ['Arjun Nair']);
    expect((await dao.members('w2')).map((m) => m.displayName), ['Elsewhere']);
  });
}
