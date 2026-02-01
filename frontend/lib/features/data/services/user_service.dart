import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:frontend/features/data/models/user.dart';

class UserService {
  final ApiClient _client;

  UserService(this._client);

  Future<void> createUser({
    required String username,
    required String password,
    String? email,
  }) async {
    final response = await _client.dio.post(
      Endpoints.signup,
      data: {"username": username, "password": password, "email": ?email},
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create new user");
    }
  }

  Future<User> getUserInfo() async {
    final response = await _client.dio.get(Endpoints.me);

    if (response.statusCode != 200) {
      throw Exception("Failed to get user info");
    }

    return User.fromJson(response.data);
  }

  Future<UserSimple> getUserInfoFromUser(int userId) async {
    final response = await _client.dio.get(Endpoints.user(userId));

    if (response.statusCode != 200) {
      throw Exception("Failed to get user info from user (ID=$userId)");
    }

    return UserSimple.fromJson(response.data);
  }

  Future<String> getToken(String username, String password) async {
    final response = await _client.dio.post(
      Endpoints.getToken,
      data:
          "grant_type=password&username=$username&password=$password&client_id=cooking_app&client_secret=",
      options: Options(contentType: "application/x-www-form-urlencoded"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to get token for user");
    }

    return response.data["access_token"];
  }

  Future<User> updateUserInfo(UserPatch patch) async {
    final response = await _client.dio.patch(
      Endpoints.me,
      data: patch.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update user info");
    }

    return User.fromJson(response.data);
  }

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final response = await _client.dio.patch(
      Endpoints.changePassword,
      data: {"current_password": currentPassword, "new_password": newPassword},
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to update password");
    }
  }

  Future<void> deleteUser() async {
    final response = await _client.dio.delete(Endpoints.me);

    if (response.statusCode != 200) {
      throw Exception("Failed to delete this user");
    }
  }
}
