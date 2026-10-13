import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/router/auth_redirect.dart';

const sa1 = WarehouseMembership(warehouseId: 'sa1', code: 'SA1', name: 'Shah Alam DC', role: UserRole.supervisor);
const kp1 = WarehouseMembership(warehouseId: 'kp1', code: 'KP1', name: 'Klang Port Store', role: UserRole.worker);

UserSession session({String? warehouseId, List<WarehouseMembership> warehouses = const [], UserRole role = UserRole.worker}) => UserSession(
      userId: 'u1',
      name: 'Hafiz Rahman',
      email: 'hafiz@waretrack.local',
      site: '',
      role: role,
      token: 't',
      warehouseId: warehouseId,
      warehouses: warehouses,
    );

void main() {
  test('nobody signed in goes to welcome, except on the sign-in screens', () {
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.dashboard), AppRoutes.welcome);
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.login), isNull);
  });

  test('a person with several warehouses chooses one before anything else', () {
    final waiting = AsyncData<UserSession?>(session(warehouses: [sa1, kp1]));
    expect(authRedirect(auth: waiting, location: AppRoutes.dashboard), AppRoutes.chooseWarehouse);
    expect(authRedirect(auth: waiting, location: AppRoutes.chooseWarehouse), isNull);
  });

  test('switching is allowed with several warehouses, not with one', () {
    expect(authRedirect(auth: AsyncData(session(warehouseId: 'sa1', warehouses: [sa1, kp1])), location: AppRoutes.chooseWarehouse), isNull);
    expect(authRedirect(auth: AsyncData(session(warehouseId: 'sa1', warehouses: [sa1])), location: AppRoutes.chooseWarehouse), AppRoutes.dashboard);
  });

  test('workers stay out of supervisor screens', () {
    final worker = AsyncData<UserSession?>(session(warehouseId: 'kp1', warehouses: [kp1]));
    expect(authRedirect(auth: worker, location: AppRoutes.pendingReview), AppRoutes.dashboard);
    expect(authRedirect(auth: worker, location: AppRoutes.pendingReviewDetail), AppRoutes.dashboard);
    expect(authRedirect(auth: worker, location: AppRoutes.taskNew), AppRoutes.dashboard);
  });

  test('Sample-mode sessions (no warehouses) go straight in', () {
    expect(authRedirect(auth: AsyncData(session()), location: AppRoutes.login), AppRoutes.dashboard);
  });

  test('a locked session waits on the sign-in screen for a fingerprint', () {
    final locked = session(warehouseId: 'sa1', warehouses: [sa1]);
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.dashboard, locked: locked), AppRoutes.login);
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.welcome, locked: locked), AppRoutes.login);
    expect(authRedirect(auth: const AsyncData(null), location: AppRoutes.login, locked: locked), isNull);
  });
}
