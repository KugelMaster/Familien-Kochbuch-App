import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:frontend/core/utils/logger.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<void> createUser(
    String username,
    String password, [
    String? email,
  ]) async {
    final response = await _client.dio.post(
      Endpoints.signup,
      data: {"username": username, "password": password, "email": ?email},
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create new user");
    }
  }

  Future<bool> validateToken(String token) async {
    final response = await _client.dio.post(
      Endpoints.validateToken,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (response.statusCode == 200) return true;
    if (response.statusCode == 401) return false;

    logger.d(
      "Could not validate token: ${response.statusCode} ${response.statusMessage}",
    );
    return false;
  }

  Future<String> getToken(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: Endpoints.getToken),
        response: Response(
          requestOptions: RequestOptions(path: Endpoints.getToken),
          statusCode: 401,
          statusMessage: "Unauthorized",
        ),
      );
    }

    final response = await _client.dio.post(
      Endpoints.getToken,
      data:
          "grant_type=password&username=$username&password=$password&client_id=cooking_app&client_secret=",
      options: Options(contentType: "application/x-www-form-urlencoded"),
    );

    return response.data["access_token"];
  }
}
