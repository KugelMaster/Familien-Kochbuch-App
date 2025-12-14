class AppConfig {
  static const String baseUrl = String.fromEnvironment("BASE_URL", defaultValue: "http://10.0.2.2:8000");

  // Maybe later with Api Versions?

  static String get apiUrl => baseUrl;
}