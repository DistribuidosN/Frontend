import 'package:flutter/foundation.dart';

const String _defaultLocalBaseUrl = 'http://localhost:50021/api/v1';
const String _defaultWebBaseUrl = 'http://10.152.164.62:50021/api/v1';
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
            : fromEnvironment,
      );
    }

    final String resolvedDefaultBaseUrl = kIsWeb
        ? _defaultWebBaseUrl
        : _defaultLocalBaseUrl;

    if (defaultTargetPlatform == TargetPlatform.android) {
      const String androidBaseUrl = 'http://10.0.2.2:50021/api/v1';
      return ApiConfig(
        baseUrl: androidBaseUrl,
        adminProxyBaseUrl: androidBaseUrl,
      );
    }

    return ApiConfig(
      baseUrl: resolvedDefaultBaseUrl,
      adminProxyBaseUrl: resolvedDefaultBaseUrl,
    );
  }
}
