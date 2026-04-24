class AuthSession {
  const AuthSession({
    required this.token,
    required this.roleId,
    required this.identity,
    this.userUuid,
    this.username,
  });

  final String token;
  final int roleId;
  final String identity;
  final String? userUuid;
  final String? username;

  bool get isAdmin => roleId == 1;

  AuthSession copyWith({
    String? token,
    int? roleId,
    String? identity,
    String? userUuid,
    String? username,
  }) {
    return AuthSession(
      token: token ?? this.token,
      roleId: roleId ?? this.roleId,
      identity: identity ?? this.identity,
      userUuid: userUuid ?? this.userUuid,
      username: username ?? this.username,
    );
  }
}
