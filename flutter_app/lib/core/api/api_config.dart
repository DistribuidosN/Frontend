import 'package:flutter/foundation.dart';

const String _defaultLocalBaseUrl = 'http://localhost:50021/api/v1';
const String _defaultWebBaseUrl = 'http://localhost:50021/api/v1';
const String _defaultLocalAdminProxyBaseUrl = 'http://127.0.0.1:8787';
const String _defaultWebAdminProxyBaseUrl = 'http://127.0.0.1:8787';

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
            : (kIsWeb
                  ? _defaultWebAdminProxyBaseUrl
                  : _defaultLocalAdminProxyBaseUrl),
      );
    }

    final String resolvedDefaultBaseUrl = kIsWeb
        ? _defaultWebBaseUrl
        : _defaultLocalBaseUrl;
    final String resolvedDefaultAdminProxyBaseUrl = kIsWeb
        ? _defaultWebAdminProxyBaseUrl
        : _defaultLocalAdminProxyBaseUrl;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return ApiConfig(
        baseUrl: 'http://10.0.2.2:50021/api/v1',
        adminProxyBaseUrl: 'http://10.0.2.2:8787',
      );
    }

    return ApiConfig(
      baseUrl: resolvedDefaultBaseUrl,
      adminProxyBaseUrl: resolvedDefaultAdminProxyBaseUrl,
    );
  }
}
