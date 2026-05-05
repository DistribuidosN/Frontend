import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:imageflow_flutter/core/api/api_config.dart';
import 'package:imageflow_flutter/core/api/api_exception.dart';
import 'package:imageflow_flutter/features/upload/domain/upload_file_item.dart';

class ApiClient {
  ApiClient(this._config, {http.Client? httpClient, this.onUnauthenticated})
    : _httpClient = httpClient ?? http.Client();

  final ApiConfig _config;
  final http.Client _httpClient;
  final void Function()? onUnauthenticated;

  /// The resolved API configuration (base URL etc.) used by this client.
  ApiConfig get config => _config;

  Uri _uri(String path) {
    final String normalizedPath = path.startsWith('/') ? path : '/$path';

    // Si la ruta ya es absoluta, no la procesamos
    if (path.startsWith('http')) {
      return Uri.parse(path);
    }

    final bool isAdminRoute = normalizedPath.startsWith('/admin/') ||
        normalizedPath.startsWith('/metrics') ||
        normalizedPath.startsWith('/logs') ||
        normalizedPath.startsWith('/nodes');
    final String baseUrl = isAdminRoute
        ? _config.adminProxyBaseUrl
        : _config.baseUrl;
    final Uri baseUri = Uri.parse('$baseUrl$normalizedPath');
    if (kDebugMode) {
      debugPrint(
        '[API CLIENT] path=$normalizedPath admin=$isAdminRoute base=$baseUrl final=$baseUri',
      );
    }
    if (!baseUri.host.contains('ngrok-free.app')) {
      return baseUri;
    }

    final Map<String, String> query = <String, String>{
      ...baseUri.queryParameters,
      'ngrok-skip-browser-warning': 'true',
    };
    return baseUri.replace(queryParameters: query);
  }

  Map<String, String> _headers(String? token, {bool isJson = true, String? path}) {
    final bool isMinioImage = path != null && 
        (path.contains('enfok-images') || path.contains('exports'));

    final Map<String, String> headers = <String, String>{
      if (isJson) 'Content-Type': 'application/json',
    };

    if (!isMinioImage) {
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      headers['ngrok-skip-browser-warning'] = 'true';
    }

    return headers;
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final http.Response response = await _httpClient.post(
      _uri(path),
      headers: _headers(token, path: path),
      body: jsonEncode(body),
    );

    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final http.Response response = await _httpClient.put(
      _uri(path),
      headers: _headers(token, path: path),
      body: jsonEncode(body),
    );

    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> deleteJson(String path, {String? token}) async {
    final http.Response response = await _httpClient.delete(
      _uri(path),
      headers: _headers(token, isJson: false, path: path),
    );

    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> getJson(String path, {String? token}) async {
    final http.Response response = await _httpClient.get(
      _uri(path),
      headers: _headers(token, isJson: false, path: path),
    );

    return _decodeJsonResponse(response);
  }

  Future<dynamic> getDecoded(String path, {String? token}) async {
    final http.Response response = await _httpClient.get(
      _uri(path),
      headers: _headers(token, isJson: false, path: path),
    );

    return _decodeResponse(response);
  }

  Future<dynamic> getDecodedFromAbsoluteUrl(String url, {String? token}) async {
    final http.Response response = await _httpClient.get(
      _uri(url), // _uri ya maneja absolutas
      headers: _headers(token, isJson: false, path: url),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required List<UploadFileItem> files,
    required List<String> filters,
    String? token,
  }) async {
    final Uri uri = _uri(path);
    final String boundary =
        '----DartFormBoundary${DateTime.now().millisecondsSinceEpoch}';
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'multipart/form-data; boundary=$boundary',
      'ngrok-skip-browser-warning': 'true',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final List<int> bodyBytes = <int>[];

    void addField(String name, String value) {
      bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
      bodyBytes.addAll(
        utf8.encode('Content-Disposition: form-data; name="$name"\r\n\r\n'),
      );
      bodyBytes.addAll(utf8.encode('$value\r\n'));
    }

    void addFile(String name, String filename, List<int> bytes) {
      bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
      bodyBytes.addAll(
        utf8.encode(
          'Content-Disposition: form-data; name="$name"; filename="$filename"\r\n',
        ),
      );
      bodyBytes.addAll(
        utf8.encode('Content-Type: application/octet-stream\r\n\r\n'),
      );
      bodyBytes.addAll(bytes);
      bodyBytes.addAll(utf8.encode('\r\n'));
    }

    for (final String filter in filters) {
      addField('filters', filter);
    }

    for (final UploadFileItem file in files) {
      addFile('images', file.name, file.bytes);
    }

    bodyBytes.addAll(utf8.encode('--$boundary--\r\n'));

    final http.Request request = http.Request('POST', uri)
      ..headers.addAll(headers)
      ..bodyBytes = bodyBytes;

    final http.StreamedResponse streamed = await request.send();
    final http.Response response = await http.Response.fromStream(streamed);
    return _decodeJsonResponse(response);
  }

  Future<List<int>> getBytes(String path, {String? token}) async {
    final http.Response response = await _httpClient.get(
      _uri(path),
      headers: _headers(token, isJson: false, path: path),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Download failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    return response.bodyBytes;
  }

  Future<List<int>> getBytesFromAbsoluteUrl(String url, {String? token}) async {
    final http.Response response = await _httpClient.get(
      _uri(url),
      headers: _headers(token, isJson: false, path: url),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Download failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    return response.bodyBytes;
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic payload = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        onUnauthenticated?.call();
      }
      final String message = payload is Map<String, dynamic>
          ? (payload['error'] as String?) ??
                (payload['message'] as String?) ??
                'Request failed with status ${response.statusCode}'
          : 'Request failed with status ${response.statusCode}';
      throw ApiException(message, statusCode: response.statusCode);
    }

    return payload;
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    final dynamic payload = _decodeResponse(response);

    final Map<String, dynamic> json = payload is Map<String, dynamic>
        ? payload
        : <String, dynamic>{'data': payload};

    return json;
  }

  void dispose() {
    _httpClient.close();
  }
}
