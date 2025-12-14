import 'package:dio/dio.dart';
import 'package:frontend/config/app_config.dart';

class ApiClient {
  final Dio dio;

  ApiClient() :
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          "Content-Type": "application/json",
        }
      ),
    );
}