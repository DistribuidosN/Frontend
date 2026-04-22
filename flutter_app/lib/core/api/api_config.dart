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
      return const ApiConfig(baseUrl: 'http://10.134.240.205:50021/api/v1');
    }

    return const ApiConfig(baseUrl: 'http://10.134.240.205:50021/api/v1');
  }
}
