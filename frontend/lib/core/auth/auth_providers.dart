import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_service.dart';
import 'package:frontend/core/auth/auth_state.dart';
import 'package:frontend/core/auth/secure_storage.dart';
import 'package:frontend/core/network/api_client_provider.dart';

final authServiceProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthService(client);
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final _authService = ref.read(authServiceProvider);
  late final _storage = ref.watch(secureStorageProvider);

  @override
  AuthState build() {
    return AuthState.loggedOut();
  }

  Future<void> login(String username, String password) async {
    try {
      String token = await _authService.getToken(username, password);

      state = AuthState.fromToken(token);

      ref.read(apiClientProvider).setToken(token);
      await _storage.write(key: "access_token", value: token);
    } on DioException catch (e) {
      state = AuthState.loggedOut(
        e.response?.statusCode == 401
            ? AuthFailure.invalidCredentials
            : AuthFailure.networkError,
      );
    }
  }

  Future<void> logout() async {
    state = AuthState.loggedOut();
    ref.read(apiClientProvider).clearToken();
    await _storage.delete(key: "access_token");
  }

  Future<void> init() async {
    final token = await _storage.read(key: "access_token");

    if (token != null) {
      final isValid = await _authService.validateToken(token);

      if (isValid) {
        state = AuthState.fromToken(token);
        ref.read(apiClientProvider).setToken(token);
      } else {
        state = AuthState.loggedOut(AuthFailure.sessionExpired);
        await _storage.delete(key: "access_token");
      }
    }
  }

  void continueAsGuest() {
    state = AuthState.guest();
  }
}
