import 'package:frontend/features/data/models/user.dart';

enum AuthStatus {
  unknown, // E.g. app starting
  guest, // Use the app without an account
  unauthenticated,
  authenticated,
}

enum AuthFailure { invalidCredentials, sessionExpired, userDeleted, networkError }

class AuthState {
  final String? token;
  final AuthStatus status;
  final AuthFailure? failure;

  final User? user;

  const AuthState({this.token, required this.status, this.failure, this.user});

  factory AuthState.unknown() => const AuthState(status: AuthStatus.unknown);

  factory AuthState.loggedOut([AuthFailure? failure]) =>
      AuthState(status: AuthStatus.unauthenticated, failure: failure);

  factory AuthState.fromTokenWithData(String token, User info) =>
      AuthState(token: token, status: AuthStatus.authenticated, user: info);

  factory AuthState.guest() => const AuthState(status: AuthStatus.guest);

  bool get isAuthenticated => status == AuthStatus.authenticated;
}
