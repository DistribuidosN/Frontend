import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    required this.adminProxyBaseUrl,
  });

  final String baseUrl;
  final String adminProxyBaseUrl;

  static ApiConfig resolve() {
    const String fromEnvironment = String.fromEnvironment('API_BASE_URL');
    const String proxyFromEnvironment = String.fromEnvironment(
      'ADMIN_PROXY_BASE_URL',
    );
    const String defaultProxy = 'https://c450-181-55-22-220.ngrok-free.app/api/v1';
    if (fromEnvironment.isNotEmpty) {
      return ApiConfig(
        baseUrl: fromEnvironment,
        adminProxyBaseUrl: proxyFromEnvironment.isNotEmpty
            ? proxyFromEnvironment
            : defaultProxy,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return const ApiConfig(
        baseUrl: 'https://c450-181-55-22-220.ngrok-free.app/api/v1',
        adminProxyBaseUrl: defaultProxy,
      );
    }

    return const ApiConfig(
      baseUrl: 'https://c450-181-55-22-220.ngrok-free.app/api/v1',
      adminProxyBaseUrl: defaultProxy,
    );
  }
}
