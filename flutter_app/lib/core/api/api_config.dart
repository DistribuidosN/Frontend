import 'package:flutter/foundation.dart';

const String _defaultBaseUrl = 'https://ea47-181-55-22-220.ngrok-free.app/api/v1';

class ApiConfig {
  const ApiConfig({required this.baseUrl});

  final String baseUrl;

  static ApiConfig resolve() {
    const String fromEnvironment = String.fromEnvironment('API_BASE_URL');
    
    if (fromEnvironment.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('[API CONFIG] env baseUrl=$fromEnvironment');
      }
      return ApiConfig(baseUrl: fromEnvironment);
    }

    if (kDebugMode) {
      debugPrint('[API CONFIG] default baseUrl=$_defaultBaseUrl');
    }
    
    return ApiConfig(baseUrl: _defaultBaseUrl);
  }
}
