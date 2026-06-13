class ApiConstants {
  ApiConstants._();

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
