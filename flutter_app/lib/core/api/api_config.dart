import 'package:flutter/foundation.dart';

const String _defaultLocalBaseUrl = 'http://localhost:50021/api/v1';
const String _defaultWebBaseUrl = 'http://172.24.14.205:50021/api/v1';

class ApiConfig {
  const ApiConfig({required this.baseUrl, required this.adminProxyBaseUrl});

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
            : (kIsWeb ? _defaultWebBaseUrl : _defaultLocalBaseUrl),
      );
    }

    final String resolvedDefaultBaseUrl = kIsWeb
        ? _defaultWebBaseUrl
        : _defaultLocalBaseUrl;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return ApiConfig(
        baseUrl: resolvedDefaultBaseUrl,
        adminProxyBaseUrl: resolvedDefaultBaseUrl,
      );
    }

    return ApiConfig(
      baseUrl: resolvedDefaultBaseUrl,
      adminProxyBaseUrl: resolvedDefaultBaseUrl,
    );
  }
}
