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
    const String defaultBaseUrl = 'http://localhost:50021/api/v1';
    if (fromEnvironment.isNotEmpty) {
      return ApiConfig(
        baseUrl: fromEnvironment,
        adminProxyBaseUrl: proxyFromEnvironment.isNotEmpty
            ? proxyFromEnvironment
            : defaultBaseUrl,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return const ApiConfig(
        baseUrl: defaultBaseUrl,
        adminProxyBaseUrl: defaultBaseUrl,
      );
    }

    return const ApiConfig(
      baseUrl: defaultBaseUrl,
      adminProxyBaseUrl: defaultBaseUrl,
    );
  }
}
