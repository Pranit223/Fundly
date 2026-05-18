class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.email,
  });

  final String accessToken;
  final String tokenType;
  final String email;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;

    return AuthSession(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      email: user['email'] as String,
    );
  }
}
