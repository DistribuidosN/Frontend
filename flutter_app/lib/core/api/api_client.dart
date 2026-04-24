import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:imageflow_flutter/core/api/api_config.dart';
import 'package:imageflow_flutter/core/api/api_exception.dart';
import 'package:imageflow_flutter/features/upload/domain/upload_file_item.dart';

class ApiClient {
  ApiClient(this._config, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final ApiConfig _config;
  final http.Client _httpClient;

  Uri _uri(String path) {
    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    final Uri baseUri = Uri.parse('${_config.baseUrl}$normalizedPath');
    if (!baseUri.host.contains('ngrok-free.app')) {
      return baseUri;
    }
    final Map<String, String> query = <String, String>{
      ...baseUri.queryParameters,
      'ngrok-skip-browser-warning': 'true',
    };
    return baseUri.replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final http.Response response = await _httpClient.post(
      _uri(path),
      headers: <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> getJson(String path, {String? token}) async {
    final http.Response response = await _httpClient.get(
      _uri(path),
      headers: <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    return _decodeJsonResponse(response);
  }

  Future<dynamic> getDecoded(String path, {String? token}) async {
    final http.Response response = await _httpClient.get(
      _uri(path),
      headers: <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    return _decodeResponse(response);
  }

  Future<dynamic> getDecodedFromAbsoluteUrl(String url, {String? token}) async {
    final http.Response response = await _httpClient.get(
      Uri.parse(url),
      headers: <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required List<UploadFileItem> files,
    required List<String> filters,
    String? token,
  }) async {
    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      _uri(path),
    );

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields['filters'] = filters.join('\n');
    request.files.addAll(
      files.map(
        (UploadFileItem file) => http.MultipartFile.fromBytes(
          'images',
          file.bytes,
          filename: file.name,
        ),
      ),
    );

    final http.StreamedResponse streamed = await request.send();
    final http.Response response = await http.Response.fromStream(streamed);
    return _decodeJsonResponse(response);
  }

  Future<List<int>> getBytes(String path, {String? token}) async {
    final http.Response response = await _httpClient.get(
      _uri(path),
      headers: <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Download failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    return response.bodyBytes;
  }

  Future<List<int>> getBytesFromAbsoluteUrl(String url) async {
    final Uri rawUri = Uri.parse(url);
    final Uri requestUri = rawUri.host.contains('ngrok-free.app')
        ? rawUri.replace(
            queryParameters: <String, String>{
              ...rawUri.queryParameters,
              'ngrok-skip-browser-warning': 'true',
            },
          )
        : rawUri;
    final http.Response response = await _httpClient.get(
      requestUri,
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
