class AuthSession {
  const AuthSession({
    required this.token,
    required this.roleId,
    required this.identity,
  });

  final String token;
  final int roleId;
  final String identity;
}
