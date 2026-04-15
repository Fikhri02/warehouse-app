enum UserRole { worker, supervisor }

class UserSession {
  final String userId;
  final String name;
  final String email;
  final String site;
  final UserRole role;
  final String token;

  const UserSession({
    required this.userId,
    required this.name,
    required this.email,
    required this.site,
    required this.role,
    required this.token,
  });

  UserSession copyWith({
    String? userId,
    String? name,
    String? email,
    String? site,
    UserRole? role,
    String? token,
  }) =>
      UserSession(
        userId: userId ?? this.userId,
        name: name ?? this.name,
        email: email ?? this.email,
        site: site ?? this.site,
        role: role ?? this.role,
        token: token ?? this.token,
      );

  @override
  bool operator ==(Object other) =>
      other is UserSession &&
      other.userId == userId &&
      other.token == token;

  @override
  int get hashCode => Object.hash(userId, token);
}
