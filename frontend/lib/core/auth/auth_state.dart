import 'dart:convert';

enum AuthStatus {
  unknown, // E.g. app starting
  unauthenticated,
  authenticated,
}

enum AuthFailure {
  invalidCredentials,
  sessionExpired,
  networkError,
}

class AuthState {
  final String? token;
  final AuthStatus status;
  final AuthFailure? failure;

  final int? userId;
  final String? username;
  final bool? isAdmin;

  const AuthState({
    this.token,
    required this.status,
    this.failure,
    this.userId,
    this.username,
    this.isAdmin,
  });

  factory AuthState.unknown() => const AuthState(status: AuthStatus.unknown);

  factory AuthState.loggedOut([AuthFailure? failure]) =>
      AuthState(status: AuthStatus.unauthenticated, failure: failure);

  factory AuthState.fromToken(String token) {
    final splitToken = token.split(".");
    if (splitToken.length != 3) {
      throw FormatException("Invalid token");
    }
    try {
      final normalizedPayload = base64.normalize(splitToken[1]);
      final payloadString = utf8.decode(base64.decode(normalizedPayload));
      final claims = jsonDecode(payloadString);

      return AuthState(
        token: token,
        status: AuthStatus.authenticated,
        userId: claims["id"],
        username: claims["sub"],
        isAdmin: claims["is_admin"],
      );
    } catch (error) {
      throw FormatException("Invalid payload");
    }
  }
}
