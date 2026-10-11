enum UserRole { worker, supervisor }

/// A warehouse the person may use, and their role there (spec §2: Worker or Supervisor per warehouse).
class WarehouseMembership {
  const WarehouseMembership({required this.warehouseId, required this.code, required this.name, required this.role});

  final String warehouseId;
  final String code;
  final String name;
  final UserRole role;
}

class UserSession {
  final String userId;
  final String name;
  final String email;
  final String site;
  final UserRole role;
  final String token;
  final String? warehouseId;
  final List<WarehouseMembership> warehouses;

  const UserSession({
    required this.userId,
    required this.name,
    required this.email,
    required this.site,
    required this.role,
    required this.token,
    this.warehouseId,
    this.warehouses = const [],
  });

  /// Signed in to the server with several warehouses and none chosen yet.
  bool get needsWarehouse => warehouseId == null && warehouses.isNotEmpty;

  UserSession copyWith({
    String? userId,
    String? name,
    String? email,
    String? site,
    UserRole? role,
    String? token,
    String? warehouseId,
    List<WarehouseMembership>? warehouses,
  }) =>
      UserSession(
        userId: userId ?? this.userId,
        name: name ?? this.name,
        email: email ?? this.email,
        site: site ?? this.site,
        role: role ?? this.role,
        token: token ?? this.token,
        warehouseId: warehouseId ?? this.warehouseId,
        warehouses: warehouses ?? this.warehouses,
      );

  @override
  bool operator ==(Object other) =>
      other is UserSession &&
      other.userId == userId &&
      other.token == token &&
      other.warehouseId == warehouseId;

  @override
  int get hashCode => Object.hash(userId, token, warehouseId);
}
