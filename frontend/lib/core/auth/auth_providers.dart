import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_state.dart';
import 'package:frontend/core/auth/secure_storage.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/user.dart';
import 'package:frontend/features/providers/user_providers.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final _userService = ref.read(userServiceProvider);
  late final _storage = ref.watch(secureStorageProvider);

  @override
  AuthState build() {
    return AuthState.loggedOut();
  }

  Future<void> init() async {
    final token = await _storage.read(key: "access_token");

    if (token != null) {
      try {
        ref.read(apiClientProvider).setToken(token);
        final userInfo = await _userService.getUserInfo();
        state = AuthState.fromTokenWithData(token, userInfo);
      } on DioException {
        state = AuthState.loggedOut(AuthFailure.sessionExpired);
        await _storage.delete(key: "access_token");
      }
    }
  }

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      state = AuthState.loggedOut(AuthFailure.invalidCredentials);
      return;
    }

    try {
      final token = await _userService.getToken(username, password);
      ref.read(apiClientProvider).setToken(token);

      final userInfo = await _userService.getUserInfo();
      state = AuthState.fromTokenWithData(token, userInfo);

      await _storage.write(key: "access_token", value: token);
    } on DioException catch (e) {
      state = AuthState.loggedOut(
        e.response?.statusCode == 401
            ? AuthFailure.invalidCredentials
            : AuthFailure.networkError,
      );
    }
  }

  void continueAsGuest() {
    state = AuthState.guest();
  }

  Future<String?> createUser({
    required String username,
    required String password,
    String? email,
  }) async {
    try {
      await _userService.createUser(
        username: username,
        password: password,
        email: email,
      );
      return null;
    } on DioException catch (e) {
      return e.response?.data["code"];
    }
  }

  Future<void> logout() async {
    state = AuthState.loggedOut();
    ref.read(apiClientProvider).clearToken();
    await _storage.delete(key: "access_token");
  }

  Future<String?> updateProfile({
    String? name,
    String? email,
    int? avatarId,
  }) async {
    if (state.token == null) {
      logout();
      return null;
    }

    try {
      final updated = await _userService.updateUserInfo(
        UserPatch(username: name, email: email, avatarId: avatarId),
      );

      state = AuthState.fromTokenWithData(state.token!, updated);
      return null;
    } on DioException catch (e) {
      return e.response?.data["code"];
    }
  }

  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _userService.updatePassword(currentPassword, newPassword);
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return false;
      rethrow;
    }
  }

  Future<void> deleteProfile() async {
    if (!state.isAuthenticated) return;

    await _userService.deleteUser();

    state = AuthState.loggedOut(AuthFailure.userDeleted);
    ref.read(apiClientProvider).clearToken();
    await _storage.delete(key: "access_token");
  }
}
