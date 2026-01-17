import 'package:dio/dio.dart';
import 'package:frontend/config/app_config.dart';

class ApiClient {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {"Content-Type": "application/json"},
    ),
  );

  String? _accessToken;

  ApiClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        // FIXME: Not sure if this is safe to delete
        //onError: (error, handler) {
        //  if (error.response?.statusCode == 401) {
        //    clearToken();
        //  }
        //  handler.next(error);
        //},
      ),
    );
  }

  void setToken(String token) {
    _accessToken = token;
  }

  void clearToken() {
    _accessToken = null;
  }
}
