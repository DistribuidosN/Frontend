import 'package:flutter/foundation.dart';

const String _defaultBaseUrl = 'http://localhost:50021/api/v1';

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
    if (fromEnvironment.isNotEmpty) {
      return ApiConfig(
        baseUrl: fromEnvironment,
        adminProxyBaseUrl: proxyFromEnvironment.isNotEmpty
            ? proxyFromEnvironment
            : _defaultBaseUrl,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return const ApiConfig(
        baseUrl: _defaultBaseUrl,
        adminProxyBaseUrl: _defaultBaseUrl,
      );
    }

    return const ApiConfig(
      baseUrl: _defaultBaseUrl,
      adminProxyBaseUrl: _defaultBaseUrl,
    );
  }
}
