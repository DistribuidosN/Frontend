import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig({required this.baseUrl});

  final String baseUrl;

  static ApiConfig resolve() {
    const String fromEnvironment = String.fromEnvironment('API_BASE_URL');
    if (fromEnvironment.isNotEmpty) {
      return ApiConfig(baseUrl: fromEnvironment);
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return const ApiConfig(baseUrl: 'http://10.0.2.2:8081/api/v1');
    }

    return const ApiConfig(baseUrl: 'http://127.0.0.1:8081/api/v1');
  }
}
