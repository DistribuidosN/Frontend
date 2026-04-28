import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imageflow_flutter/core/api/api_client.dart';
import 'package:imageflow_flutter/core/api/api_config.dart';
import 'package:imageflow_flutter/core/files/pick_images.dart';
import 'package:imageflow_flutter/core/files/save_bytes.dart';
import 'package:imageflow_flutter/features/admin/domain/admin_audit_log.dart';
import 'package:imageflow_flutter/features/admin/domain/admin_node_metric.dart';
import 'package:imageflow_flutter/features/auth/domain/auth_session.dart';
import 'package:imageflow_flutter/features/history/domain/history_request.dart';
import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';
import 'package:imageflow_flutter/features/nodes/domain/worker_node.dart';
import 'package:imageflow_flutter/features/results/domain/batch_gallery_image.dart';
import 'package:imageflow_flutter/features/upload/domain/upload_batch_result.dart';
import 'package:imageflow_flutter/features/upload/domain/upload_file_item.dart';
import 'package:imageflow_flutter/features/user/domain/user_activity_event.dart';
import 'package:imageflow_flutter/features/user/domain/user_statistics.dart';

class WorkspaceController extends ChangeNotifier {
  WorkspaceController({ApiClient? apiClient}) {
    _apiClient = apiClient ?? ApiClient(
      ApiConfig.resolve(),
      onUnauthenticated: _handleUnauthenticated,
    );
  }

  static const String _defaultAdminNodeId = 'node-1';
  static const String _defaultAdminImageUuid =
      'ab1df2d2-255c-409b-94c1-855a590e77b9';

  late final ApiClient _apiClient;
  final Random _random = Random();

  void _handleUnauthenticated() {
    if (_session != null) {
      _clearSessionLocally();
      notifyListeners();
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final roleId = prefs.getInt('auth_role');
    final identity = prefs.getString('auth_identity');
    final userUuid = prefs.getString('auth_uuid');
    final username = prefs.getString('auth_username');
    
    if (token != null && identity != null && roleId != null) {
      _session = AuthSession(
        token: token,
        roleId: roleId,
        identity: identity,
        userUuid: userUuid,
        username: username,
      );
      try {
        await _refreshProfile(notify: false);
      } catch (_) {}
      notifyListeners();
    }
  }

  Future<void> _saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', session.token);
    await prefs.setInt('auth_role', session.roleId);
    await prefs.setString('auth_identity', session.identity);
    if (session.userUuid != null) await prefs.setString('auth_uuid', session.userUuid!);
    if (session.username != null) await prefs.setString('auth_username', session.username!);
  }

  Future<void> _clearSessionLocally() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_role');
    await prefs.remove('auth_identity');
    await prefs.remove('auth_uuid');
    await prefs.remove('auth_username');
  }

  AuthSession? _session;
  final List<UploadFileItem> _selectedFiles = <UploadFileItem>[];
  final Set<String> _selectedFilters = <String>{};
  final List<HistoryRequest> _historyRequests = <HistoryRequest>[];
  final List<LogEntry> _logs = <LogEntry>[];
  final List<AdminAuditLog> _adminLogs = <AdminAuditLog>[];
  final List<AdminNodeMetric> _adminNodeMetrics = <AdminNodeMetric>[];
  final List<BatchGalleryImage> _latestBatchImages = <BatchGalleryImage>[];
  final List<UserActivityEvent> _userActivity = <UserActivityEvent>[];
  UserStatistics _userStatistics = UserStatistics.empty();
  String? _lastSelectionMessage;
  String _adminMetricNodeId = _defaultAdminNodeId;
  String? _adminLogImageUuid;
  UploadBatchResult? _latestBatch;

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;
  bool get isAdmin => _session?.isAdmin ?? false;
  List<UploadFileItem> get selectedFiles =>
      List<UploadFileItem>.unmodifiable(_selectedFiles);
  Set<String> get selectedFilters => Set<String>.unmodifiable(_selectedFilters);
  UploadBatchResult? get latestBatch => _latestBatch;
  List<BatchGalleryImage> get latestBatchImages =>
      List<BatchGalleryImage>.unmodifiable(_latestBatchImages);
  String get apiBaseUrl => ApiConfig.resolve().baseUrl;
  String? get lastSelectionMessage => _lastSelectionMessage;
  List<HistoryRequest> get historyRequests =>
      List<HistoryRequest>.unmodifiable(_historyRequests);
  List<LogEntry> get logs => List<LogEntry>.unmodifiable(_logs);
  List<AdminAuditLog> get adminLogs =>
      List<AdminAuditLog>.unmodifiable(_adminLogs);
  List<AdminNodeMetric> get adminNodeMetrics =>
      List<AdminNodeMetric>.unmodifiable(_adminNodeMetrics);
  List<UserActivityEvent> get userActivity =>
      List<UserActivityEvent>.unmodifiable(_userActivity);
  UserStatistics get userStatistics => _userStatistics;
  String get adminMetricNodeId => _adminMetricNodeId;
  String? get adminLogImageUuid => _adminLogImageUuid;

  /// HTTP headers to attach to authenticated image requests (Image.network).
  Map<String, String> get authHeaders {
    final String? token = _session?.token;
    if (token == null || token.isEmpty) {
      return const <String, String>{
        'ngrok-skip-browser-warning': 'true',
      };
    }
    return <String, String>{
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  /// Returns true if [url] is a valid, renderable URL (used by Image.network).
  bool isReachablePreviewUrl(String url) => _isReachablePreviewUrl(url);

  List<WorkerNode> get workerNodes {
    if (_adminNodeMetrics.isNotEmpty) {
      return _adminNodeMetrics.map((AdminNodeMetric metric) {
        return WorkerNode(
          id: metric.id,
          address: metric.address,
          active: metric.active,
          load: metric.load,
          currentJobs: metric.currentJobs,
          totalProcessed: metric.totalProcessed,
          lastHeartbeat: metric.lastHeartbeat,
          uptime: metric.uptime,
          busyWorkers: metric.busyWorkers,
          ramUsage: metric.ramUsage,
        );
      }).toList();
    }

    return const <WorkerNode>[];
  }


  Future<void> login({required String email, required String password}) async {
    final Map<String, dynamic> json = await _apiClient.postJson(
      '/auth/login',
      body: <String, dynamic>{'email': email, 'password': password},
    );

    final String token = json['token'] as String? ?? '';
    final int roleId = (json['role_id'] as num?)?.toInt() ?? 0;
    final String? userUuid = (json['user_uuid'] as String?) ?? (json['uuid'] as String?);
    final String? username = json['username'] as String?;

    _session = AuthSession(
      token: token,
      roleId: roleId,
      identity: email,
      userUuid: userUuid,
      username: username,
    );
    await _saveSession(_session!);

    // Si faltan datos en el login, intentar obtenerlos de validate
    if (_session!.userUuid == null || _session!.userUuid!.isEmpty || _session!.username == null) {
      try {
        final Map<String, dynamic> validation = await _apiClient.getJson(
          '/auth/validate',
          token: _session!.token,
        );
                int? valRole = (validation['role'] as num?)?.toInt();
        if (valRole == null && validation['role'] is String) {
          valRole = int.tryParse(validation['role'] as String);
        }
        valRole ??= (validation['role_id'] as num?)?.toInt() ?? (validation['user']?['role_id'] as num?)?.toInt();
        if (valRole == 0) valRole = null;

        _session = _session!.copyWith(
          userUuid: (validation['user_uuid'] as String?) ?? (validation['uuid'] as String?) ?? (validation['user']?['uuid'] as String?),
          username: (validation['username'] as String?) ?? (validation['user']?['username'] as String?),
          roleId: valRole,
        );
        await _saveSession(_session!);
      } catch (e) {
        _appendLog(
          level: LogLevel.warning,
          source: 'auth',
          message: 'Token validated, but identity info could not be fully resolved.',
          job: '-',
        );
      }
    }
    _appendLog(
      level: LogLevel.success,
      source: 'auth',
      message: 'Signed in as $email.',
      job: '-',
    );
    // Fetch profile to enrich session with user_uuid/username if login did not provide them.
    try {
      await _refreshProfile(notify: false);
    } catch (_) {
      _appendLog(
        level: LogLevel.warning,
        source: 'auth',
        message: 'Signed in, but profile details could not be loaded yet.',
        job: '-',
      );
    }
    try {
      await refreshHistory(notify: false);
    } catch (_) {
      _appendLog(
        level: LogLevel.warning,
        source: 'history',
        message: 'Signed in, but remote history could not be loaded yet.',
        job: '-',
      );
    }
    try {
      await refreshUserStatistics(notify: false);
    } catch (_) {
      _appendLog(
        level: LogLevel.warning,
        source: 'telemetry',
        message: 'Signed in, but user statistics endpoint is not reachable yet.',
        job: '-',
      );
    }
    try {
      await refreshUserActivity(notify: false);
    } catch (_) {
      _appendLog(
        level: LogLevel.warning,
        source: 'telemetry',
        message: 'Signed in, but user activity endpoint is not reachable yet.',
        job: '-',
      );
    }
    if (isAdmin) {
      try {
        await refreshAdminMetrics(notify: false);
      } catch (_) {
        _appendLog(
          level: LogLevel.warning,
          source: 'admin',
          message: 'Admin metrics endpoint is not reachable right now.',
          job: '-',
        );
      }
      try {
        await refreshAdminLogs(notify: false);
      } catch (_) {
        _appendLog(
          level: LogLevel.warning,
          source: 'admin',
          message: 'Admin logs endpoint is not reachable right now.',
          job: '-',
        );
      }
    }
    notifyListeners();
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    int roleId = 2,
  }) async {
    await _apiClient.postJson(
      '/auth/register',
      body: <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'role_id': roleId,
      },
    );
    _appendLog(
      level: LogLevel.success,
      source: 'auth',
      message: 'Created ${roleId == 1 ? 'admin' : 'operator'} account for $email.',
      job: '-',
    );
  }

  Future<void> forgetPassword({
    required String email,
    required String newPassword,
  }) async {
    await _apiClient.postJson(
      '/auth/forget-password',
      body: <String, dynamic>{'email': email, 'newPassword': newPassword},
    );
    _appendLog(
      level: LogLevel.info,
      source: 'auth',
      message: 'Password reset requested for $email.',
      job: '-',
    );
  }

  Future<void> resetPassword({required String newPassword}) async {
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in before resetting your password.');
    }
    await _apiClient.postJson(
      '/auth/reset-password',
      body: <String, dynamic>{'newPassword': newPassword},
      token: _session!.token,
    );
    _appendLog(
      level: LogLevel.success,
      source: 'auth',
      message: 'Password has been reset successfully.',
      job: '-',
    );
  }

  Future<void> logout() async {
    if (_session != null && _session!.token.isNotEmpty) {
      try {
        await _apiClient.postJson('/auth/logout', body: <String, dynamic>{}, token: _session!.token);
      } catch (e) {
        _appendLog(
          level: LogLevel.warning,
          source: 'auth',
          message: 'Remote logout failed, clearing local session anyway: $e',
          job: '-',
        );
      }
    }
    await _clearSessionLocally();
    _selectedFiles.clear();
    _selectedFilters.clear();
    _historyRequests.clear();
    _latestBatchImages.clear();
    _adminLogs.clear();
    _adminNodeMetrics.clear();
    _userActivity.clear();
    _userStatistics = UserStatistics.empty();
    _adminMetricNodeId = _defaultAdminNodeId;
    _adminLogImageUuid = null;
    _latestBatch = null;
    _appendLog(
      level: LogLevel.info,
      source: 'auth',
      message: 'Workspace session closed.',
      job: '-',
    );
    notifyListeners();
  }

  Future<bool> pickFiles() async {
    final List<PickedImageData> pickedImages = await pickImages();
    if (pickedImages.isEmpty) {
      _lastSelectionMessage = null;
      return false;
    }

    int remainingBytes = kMaxBatchUploadBytes -
        _selectedFiles.fold<int>(
          0,
          (int sum, UploadFileItem file) => sum + file.sizeBytes,
        );
    int optimizedCount = 0;
    int skippedCount = 0;

    final List<UploadFileItem> incoming = pickedImages
        .where((PickedImageData file) {
          final bool fits = file.sizeBytes <= remainingBytes;
          if (fits) {
            remainingBytes -= file.sizeBytes;
            if (file.wasOptimized) {
              optimizedCount += 1;
            }
          } else {
            skippedCount += 1;
          }
          return fits;
        })
        .map(
          (PickedImageData file) => UploadFileItem(
            id:
                file.identifier ??
                '${file.name}-${file.sizeBytes}-${_random.nextInt(1 << 32)}',
            name: file.name,
            sizeLabel: _formatBytes(file.sizeBytes),
            sizeBytes: file.sizeBytes,
            bytes: file.bytes,
          ),
        )
        .toList();

    if (incoming.isEmpty) {
      _lastSelectionMessage =
          'The selected images exceed the upload limit of ${_formatBytes(kMaxBatchUploadBytes)} for one batch.';
      return false;
    }

    _selectedFiles.addAll(incoming);
    final List<String> parts = <String>[
      '${incoming.length} file(s) added to the batch.',
    ];
    if (optimizedCount > 0) {
      parts.add('$optimizedCount optimized to avoid server size limits.');
    }
    if (skippedCount > 0) {
      parts.add('$skippedCount skipped because the batch would exceed ${_formatBytes(kMaxBatchUploadBytes)}.');
    }
    _lastSelectionMessage = parts.join(' ');
    _appendLog(
      level: LogLevel.info,
      source: 'upload',
      message: 'Selected ${incoming.length} file(s) for the next batch.',
      job: '-',
    );
    notifyListeners();
    return true;
  }

  void removeFile(String fileId) {
    _selectedFiles.removeWhere((UploadFileItem item) => item.id == fileId);
    _appendLog(
      level: LogLevel.warning,
      source: 'upload',
      message: 'Removed one file from the staged batch.',
      job: '-',
    );
    notifyListeners();
  }

  void clearFiles() {
    _selectedFiles.clear();
    _appendLog(
      level: LogLevel.warning,
      source: 'upload',
      message: 'Cleared all staged files.',
      job: '-',
    );
    notifyListeners();
  }

  void setSelectedFilters(Iterable<String> filters) {
    _selectedFilters
      ..clear()
      ..addAll(filters.where((String filter) => filter.trim().isNotEmpty));
    notifyListeners();
  }

  Future<void> uploadSingleImage({
    required String base64Data,
    required String fileName,
    required List<String> transformations,
  }) async {
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in to upload images.');
    }

    await _apiClient.postJson(
      '/node/upload',
      body: <String, dynamic>{
        'imageData': base64Data,
        'fileName': fileName,
        'transformations': transformations,
      },
      token: _session!.token,
    );

    _appendLog(
      level: LogLevel.success,
      source: 'node',
      message: 'Image $fileName uploaded successfully for synchronous processing.',
      job: '-',
    );
  }

  Future<UploadBatchResult> submitBatch() async {
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in before sending a batch.');
    }
    if (_selectedFiles.isEmpty) {
      throw StateError('Select at least one image before starting processing.');
    }

    _lastSelectionMessage = 'Submitting batch...';
    notifyListeners();

    try {
      final int totalBytes = _selectedFiles.fold<int>(
        0,
        (int sum, UploadFileItem file) => sum + file.sizeBytes,
      );
      if (totalBytes > kMaxBatchUploadBytes) {
        throw StateError(
          'This batch is too large to upload. Keep it under ${_formatBytes(kMaxBatchUploadBytes)} or use fewer images.',
        );
      }

      final Map<String, dynamic> json = await _apiClient.postMultipart(
        '/node/batch',
        files: _selectedFiles,
        filters: _selectedFilters.toList(),
        token: _session!.token,
      );

      final UploadBatchResult result = UploadBatchResult(
        requestId:
            (json['batch_uuid'] as String?) ??
            (json['batchId'] as String?) ??
            (json['jobId'] as String?) ??
            _buildRequestId(),
        status: (json['status'] as String?) ?? 'accepted',
        message: (json['message'] as String?) ?? 'Batch submitted successfully.',
        fileCount: _selectedFiles.length,
        filters: _selectedFilters.toList(),
        fileNames: _selectedFiles.map((file) => file.name).toList(),
      );

      _latestBatch = result;
      _latestBatchImages.clear();
      _lastSelectionMessage = 'Batch submitted: ${result.requestId}';
      
      _appendLog(
        level: LogLevel.success,
        source: 'api',
        message:
            'Submitted batch ${result.requestId} with ${result.fileCount} image(s).',
        job: result.requestId,
      );

      try {
        await refreshHistory(notify: false);
        await refreshLatestBatchImages(notify: false);
      } catch (_) {}

      notifyListeners();
      return result;
    } catch (e) {
      _lastSelectionMessage = 'Error submitting batch: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshBatchStatus({bool notify = true}) async {
    final UploadBatchResult? batch = _latestBatch;
    if (batch == null || _session == null || _session!.token.isEmpty) {
      return;
    }

    try {
      final Map<String, dynamic> json = await _apiClient.getJson(
        '/node/batch/${batch.requestId}/status',
        token: _session!.token,
      );

      final String newStatus = (json['status'] as String?) ?? batch.status;
      if (newStatus != batch.status) {
        _latestBatch = UploadBatchResult(
          requestId: batch.requestId,
          status: newStatus,
          message: (json['message'] as String?) ?? batch.message,
          fileCount: batch.fileCount,
          filters: batch.filters,
          fileNames: batch.fileNames,
        );
        
        _appendLog(
          level: LogLevel.info,
          source: 'api',
          message: 'Batch ${batch.requestId} status updated: $newStatus',
          job: batch.requestId,
        );

        if (notify) {
          notifyListeners();
        }
      }
    } catch (e) {
      _appendLog(
        level: LogLevel.warning,
        source: 'api',
        message: 'Could not refresh batch status: $e',
        job: batch.requestId,
      );
    }
  }

  Future<void> refreshHistory({bool notify = true}) async {
    if (_session == null || _session!.token.isEmpty) {
      return;
    }

    dynamic payload;
    try {
      payload = await _apiClient.getDecoded(
        '/bd/batches',
        token: _session!.token,
      );
    } catch (e) {
      _appendLog(
        level: LogLevel.warning,
        source: 'history',
        message: 'Remote history unavailable: $e',
        job: '-',
      );
      if (notify) notifyListeners();
      return;
    }

    final List<dynamic> rows = payload is List<dynamic>
        ? payload
        : (payload is Map<String, dynamic> && payload['batches'] is List<dynamic>)
            ? payload['batches'] as List<dynamic>
            : <dynamic>[];

    _historyRequests
      ..clear()
      ..addAll(
        rows.map((dynamic row) {
          final Map<String, dynamic> item =
              row is Map<String, dynamic> ? row : <String, dynamic>{};

          final Map<String, dynamic> batch =
              (item['batch'] is Map<String, dynamic>)
                  ? item['batch'] as Map<String, dynamic>
                  : item;

          final String batchUuid =
              (batch['batch_uuid'] as String?) ??
              (batch['uuid'] as String?) ??
              (batch['id'] as String?) ??
              _buildRequestId();

          final String rawStatus =
              ((batch['status'] as String?) ?? 'PENDING').toUpperCase();

          final String date = ((batch['request_time'] as String?) ??
                               (batch['created_at'] as String?) ??
                               '').trim();

          final int images = (batch['image_count'] as num?)?.toInt() ??
              (batch['total_images'] as num?)?.toInt() ??
              0;

          String? coverUrl =
              (item['cover_image_url'] as String?) ?? (batch['cover_url'] as String?);
          if (coverUrl != null && coverUrl.isNotEmpty) {
            if (!coverUrl.startsWith('http') && !coverUrl.startsWith('data:')) {
              coverUrl = _resolveRelativeUrl(coverUrl);
            } else if (coverUrl.contains('.ngrok-free.app') || coverUrl.contains('localhost')) {
              // Patch for backend sending old ngrok domains or localhost in pre-signed URLs
              final Uri currentUri = Uri.parse(_apiClient.config.baseUrl);
              final Uri badUri = Uri.parse(coverUrl);
              String patched = coverUrl.replaceFirst(badUri.host, currentUri.host);
              if (badUri.hasPort && !currentUri.hasPort) {
                patched = patched.replaceFirst(':${badUri.port}', '');
              }
              coverUrl = patched;
            }
          }

          return HistoryRequest(
            id: batchUuid,
            date: date.isEmpty ? 'Remote batch' : date,
            images: images,
            transforms: (batch['filters'] is List)
                ? (batch['filters'] as List).cast<String>()
                : const <String>['Remote pipeline'],
            status: HistoryRequest.statusFromString(rawStatus),
            duration: (batch['duration'] as String?) ?? 'Pending',
            nodes: (batch['node_count'] as num?)?.toInt() ?? 0,
            coverImageUrl: coverUrl,
          );
        }),
      );

    if (_latestBatch == null && _historyRequests.isNotEmpty) {
      final HistoryRequest first = _historyRequests.first;
      _latestBatch = UploadBatchResult(
        requestId: first.id,
        status: first.status.name,
        message: 'Loaded from remote history.',
        fileCount: first.images,
        filters: first.transforms,
        fileNames: const <String>[],
      );
      await refreshLatestBatchImages(notify: false);
    }

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> selectHistoryBatch(String batchId) async {
    final HistoryRequest request = _historyRequests.firstWhere(
      (HistoryRequest item) => item.id == batchId,
      orElse: () => throw StateError('Batch $batchId not found in history.'),
    );
    _latestBatch = UploadBatchResult(
      requestId: request.id,
      status: request.status.name,
      message: 'Loaded from processing history.',
      fileCount: request.images,
      filters: request.transforms,
      fileNames: const <String>[],
    );
    _latestBatchImages.clear();
    await refreshLatestBatchImages();
  }

  Future<void> refreshLatestBatchImages({bool notify = true}) async {
    final UploadBatchResult? batch = _latestBatch;
    if (batch == null || _session == null || _session!.token.isEmpty) {
      return;
    }
    await _loadGalleryForBatch(batch.requestId, notify: notify);
  }

  Future<void> _loadGalleryForBatch(String batchId, {bool notify = true}) async {
    if (_session == null || _session!.token.isEmpty) return;

    dynamic payload;
    bool isFallback = false;
    try {
      payload = await _apiClient.getDecoded(
        '/bd/gallery?batchUuid=${Uri.encodeQueryComponent(batchId)}&page=1&limit=100',
        token: _session!.token,
      );
    } catch (_) {
      try {
        payload = await _apiClient.getDecoded(
          '/node/batch/$batchId/results',
          token: _session!.token,
        );
        isFallback = true;
      } catch (e2) {
        _appendLog(
          level: LogLevel.warning,
          source: 'gallery',
          message: 'Could not load batch results: $e2',
          job: batchId,
        );
        if (notify) notifyListeners();
        return;
      }
    }

    final Map<String, dynamic> json = payload is Map<String, dynamic>
        ? payload
        : <String, dynamic>{};

    List<dynamic> images = <dynamic>[];
    if (payload is List<dynamic>) {
      images = payload;
    } else if (isFallback) {
      images = json['images'] as List<dynamic>? ??
          json['results'] as List<dynamic>? ??
          <dynamic>[];
    } else {
      images = json['images'] as List<dynamic>? ??
          json['data'] as List<dynamic>? ??
          json['results'] as List<dynamic>? ??
          json['items'] as List<dynamic>? ??
          json['gallery'] as List<dynamic>? ??
          json['content'] as List<dynamic>? ??
          <dynamic>[];
    }

    _latestBatchImages
      ..clear()
      ..addAll(
        images.map((dynamic row) {
          final Map<String, dynamic> item =
              row is Map<String, dynamic> ? row : <String, dynamic>{};

          if (isFallback) {
            final String base64Data =
                (item['base64'] as String?) ?? (item['imageData'] as String?) ?? '';
            return BatchGalleryImage(
              imageUuid: (item['id'] as String?) ?? (item['uuid'] as String?) ?? '',
              batchUuid: batchId,
              originalName:
                  (item['name'] as String?) ?? (item['fileName'] as String?) ?? 'result',
              resultUrl: base64Data.isNotEmpty
                  ? 'data:image/png;base64,$base64Data'
                  : '',
              status: (item['status'] as String?) ?? 'COMPLETED',
              nodeId: (item['nodeId'] as String?) ?? '-',
            );
          }

          return BatchGalleryImage.fromJson(
            item,
            fallbackBatchUuid: batchId,
            resolveUrl: _resolveRelativeUrl,
          );
        }),
      );

    if (_adminLogImageUuid == null && _latestBatchImages.isNotEmpty) {
      final String candidate = _latestBatchImages.first.imageUuid.trim();
      if (candidate.isNotEmpty) {
        _adminLogImageUuid = candidate;
      }
    }

    final UploadBatchResult? batch = _latestBatch;
    if (batch != null) {
      final int detectedCount = _latestBatchImages.isNotEmpty
          ? _latestBatchImages.length
          : ((json['total_count'] as num?)?.toInt() ?? 0);
      final int totalFiles = batch.fileCount > 0 ? batch.fileCount : detectedCount;
      final bool completed = totalFiles > 0 && detectedCount >= totalFiles;
      _latestBatch = UploadBatchResult(
        requestId: batch.requestId,
        status: completed
            ? 'completed'
            : detectedCount > 0
                ? 'processing'
                : batch.status,
        message: completed
            ? 'Batch outputs are ready.'
            : detectedCount > 0
                ? 'Batch is generating outputs.'
                : batch.message,
        fileCount: totalFiles,
        filters: batch.filters,
        fileNames: _latestBatchImages.isNotEmpty
            ? _latestBatchImages.map((BatchGalleryImage img) => img.originalName).toList()
            : batch.fileNames,
      );
    }

    if (notify) notifyListeners();
  }

  Future<Map<String, dynamic>> getBatchStatus(String jobId) async {
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in to check batch status.');
    }

    final dynamic payload = await _apiClient.getDecoded(
      '/node/batch/$jobId/status',
      token: _session!.token,
    );

    return payload is Map<String, dynamic> ? payload : <String, dynamic>{};
  }

  Future<void> _refreshProfile({bool notify = true}) async {
    if (_session == null || _session!.token.isEmpty) {
      return;
    }
    final dynamic payload = await _apiClient.getDecoded(
      '/user/profile',
      token: _session!.token,
    );
    final Map<String, dynamic> json =
        payload is Map<String, dynamic> ? payload : <String, dynamic>{};

    final Map<String, dynamic> user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    final String? uuid = (user['user_uuid'] as String?) ??
        (user['uuid'] as String?) ??
        (user['id'] as String?);
    final String? username = user['username'] as String?;
    final int? roleId = (user['role_id'] as num?)?.toInt();

    if (uuid != null || username != null || roleId != null) {
      _session = _session!.copyWith(
        userUuid: uuid,
        username: username,
        roleId: roleId,
      );
    }

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> updateProfile({required String username, int status = 1}) async {
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in to update your profile.');
    }

    await _apiClient.putJson(
      '/user/profile',
      body: <String, dynamic>{'username': username, 'status': status},
      token: _session!.token,
    );

    _session = _session!.copyWith(username: username);
    _appendLog(
      level: LogLevel.success,
      source: 'user',
      message: 'Profile updated: $username.',
      job: '-',
    );
    await _refreshProfile();
  }

  Future<void> deleteAccount() async {
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in to delete your account.');
    }

    await _apiClient.deleteJson(
      '/user/account',
      token: _session!.token,
    );

    await logout();
    _appendLog(
      level: LogLevel.info,
      source: 'user',
      message: 'Account deleted successfully.',
      job: '-',
    );
  }

  Future<void> searchUser(String uid) async {
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in to search users.');
    }

    final Map<String, dynamic> result = await _apiClient.getJson(
      '/user/search?uid=${Uri.encodeComponent(uid)}',
      token: _session!.token,
    );

    _appendLog(
      level: LogLevel.info,
      source: 'user',
      message: 'Found user: ${result['username'] ?? uid}',
      job: '-',
    );
  }

  Future<void> refreshUserStatisticsByUuid(String uuid, {bool notify = true}) async {
    if (_session == null || _session!.token.isEmpty) {
      return;
    }

    final Map<String, dynamic> json = await _apiClient.getJson(
      '/users/$uuid/statistics',
      token: _session!.token,
    );

    _userStatistics = UserStatistics.fromJson(json);

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> refreshUserActivityByUuid(String uuid, {bool notify = true}) async {
    if (_session == null || _session!.token.isEmpty) {
      return;
    }

    final List<dynamic> json = await _apiClient.getDecoded(
      '/users/$uuid/activity',
      token: _session!.token,
    );

    _userActivity
      ..clear()
      ..addAll(
        json.map((dynamic item) {
          final Map<String, dynamic> map =
              item is Map<String, dynamic> ? item : <String, dynamic>{};
          return UserActivityEvent.fromJson(map);
        }),
      );

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> refreshUserStatistics({bool notify = true}) async {
    if (_session == null || _session!.token.isEmpty) {
      return;
    }

    // Spec says /users/:uuid/statistics OR /user/statistics
    final String? uuid = _session!.userUuid;
    final String path = (uuid != null && uuid.isNotEmpty)
        ? '/users/$uuid/statistics'
        : '/user/statistics';

    dynamic payload;
    try {
      payload = await _apiClient.getDecoded(path, token: _session!.token);
    } catch (e) {
      // Fallback to generic endpoint if UUID variant is not supported by proxy
      if (path != '/user/statistics') {
        try {
          payload = await _apiClient.getDecoded('/user/statistics', token: _session!.token);
        } catch (_) {
          _appendLog(
            level: LogLevel.warning,
            source: 'telemetry',
            message: 'Failed to load user statistics: $e',
            job: '-',
          );
          if (notify) notifyListeners();
          return;
        }
      } else {
        _appendLog(
          level: LogLevel.warning,
          source: 'telemetry',
          message: 'Failed to load user statistics: $e',
          job: '-',
        );
        if (notify) notifyListeners();
        return;
      }
    }

    final Map<String, dynamic> json =
        payload is Map<String, dynamic> ? payload : <String, dynamic>{};
    _userStatistics = UserStatistics.fromJson(json);

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> refreshUserActivity({bool notify = true}) async {
    if (_session == null || _session!.token.isEmpty) {
      return;
    }

    // Spec says /users/:uuid/activity OR /user/activity
    final String? uuid = _session!.userUuid;
    final String path = (uuid != null && uuid.isNotEmpty)
        ? '/users/$uuid/activity'
        : '/user/activity';

    dynamic payload;
    try {
      payload = await _apiClient.getDecoded(path, token: _session!.token);
    } catch (e) {
      // Fallback to generic endpoint if UUID variant is not supported by proxy
      if (path != '/user/activity') {
        try {
          payload = await _apiClient.getDecoded('/user/activity', token: _session!.token);
        } catch (_) {
          _appendLog(
            level: LogLevel.warning,
            source: 'telemetry',
            message: 'Failed to load user activity: $e',
            job: '-',
          );
          if (notify) notifyListeners();
          return;
        }
      } else {
        _appendLog(
          level: LogLevel.warning,
          source: 'telemetry',
          message: 'Failed to load user activity: $e',
          job: '-',
        );
        if (notify) notifyListeners();
        return;
      }
    }


    final List<dynamic> rows = switch (payload) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map => map['activity'] is List<dynamic>
          ? map['activity'] as List<dynamic>
          : map['activities'] is List<dynamic>
              ? map['activities'] as List<dynamic>
              : map['events'] is List<dynamic>
                  ? map['events'] as List<dynamic>
                  : map['data'] is List<dynamic>
                      ? map['data'] as List<dynamic>
                      : <dynamic>[],
      _ => <dynamic>[],
    };

    _userActivity
      ..clear()
      ..addAll(
        rows.map((dynamic row) {
          final Map<String, dynamic> item =
              row is Map<String, dynamic> ? row : <String, dynamic>{};
          return UserActivityEvent.fromJson(item);
        }),
      );

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> refreshAdminMetrics({
    String? nodeId,
    bool notify = true,
  }) async {
    if (_session == null || _session!.token.isEmpty || !isAdmin) {
      return;
    }

    final String targetNodeId = (nodeId ?? _adminMetricNodeId).trim().isEmpty
        ? _defaultAdminNodeId
        : (nodeId ?? _adminMetricNodeId).trim();

    final dynamic payload = await _apiClient.getDecoded(
      '/admin/metrics/$targetNodeId',
      token: _session!.token,
    );

    _adminMetricNodeId = targetNodeId;
    _adminNodeMetrics
      ..clear()
      ..addAll(
        switch (payload) {
          final List<dynamic> rows => rows
              .map(
                (dynamic row) => AdminNodeMetric.maybeFromJson(
                  row,
                  fallbackNodeId: targetNodeId,
                ),
              )
              .whereType<AdminNodeMetric>(),
          _ => <AdminNodeMetric>[
              if (AdminNodeMetric.maybeFromJson(
                    payload,
                    fallbackNodeId: targetNodeId,
                  ) !=
                  null)
                AdminNodeMetric.maybeFromJson(
                  payload,
                  fallbackNodeId: targetNodeId,
                )!,
            ],
        },
      );

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> refreshAdminLogs({
    String? imageUuid,
    bool notify = true,
  }) async {
    if (_session == null || _session!.token.isEmpty || !isAdmin) {
      return;
    }

    final String candidateImageUuid = _resolveAdminImageUuid(imageUuid);
    final dynamic payload = await _apiClient.getDecoded(
      '/admin/logs/$candidateImageUuid',
      token: _session!.token,
    );

    _adminLogImageUuid = candidateImageUuid;
    final List<dynamic> rows = payload is List<dynamic> ? payload : <dynamic>[];
    _adminLogs
      ..clear()
      ..addAll(
        rows.map((dynamic row) {
          final Map<String, dynamic> item =
              row is Map<String, dynamic> ? row : <String, dynamic>{};
          return AdminAuditLog.fromJson(item);
        }),
      );

    if (notify) {
      notifyListeners();
    }
  }

  Future<String> downloadLatestBatchArchive() async {
    final UploadBatchResult? batch = _latestBatch;
    if (batch == null) {
      throw StateError('No batch is available for download yet.');
    }
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in before downloading files.');
    }

    List<int> bytes;
    String fileName = '${batch.requestId}-results.zip';

    try {
      bytes = await _apiClient.getBytes(
        '/download-batch/${batch.requestId}',
        token: _session!.token,
      );
      _appendLog(
        level: LogLevel.success,
        source: 'api',
        message: 'Downloaded archive for ${batch.requestId} from backend.',
        job: batch.requestId,
      );
    } catch (error) {
      _appendLog(
        level: LogLevel.warning,
        source: 'api',
        message:
            'Backend download unavailable for ${batch.requestId}; refusing to export original staged files as a fake ZIP.',
        job: batch.requestId,
      );
      throw StateError(
        'The backend ZIP download failed for ${batch.requestId}. The app stopped instead of exporting the original local files without filters. Details: $error',
      );
    }

    final SavedFile saved = await saveBytes(
      suggestedName: fileName,
      bytes: bytes,
      mimeType: 'application/zip',
    );
    notifyListeners();
    return saved.location;
  }

  Future<String> downloadResultImage(String fileName) async {
    final UploadFileItem? localFile = _selectedFiles.cast<UploadFileItem?>().firstWhere(
      (UploadFileItem? item) => item?.name == fileName,
      orElse: () => null,
    );

    if (localFile != null) {
      final SavedFile saved = await saveBytes(
        suggestedName: localFile.name,
        bytes: localFile.bytes,
        mimeType: _mimeTypeForFile(localFile.name),
      );
      _appendLog(
        level: LogLevel.info,
        source: 'demo',
        message: 'Saved demo asset $fileName to ${saved.location}.',
        job: _latestBatch?.requestId ?? '-',
      );
      notifyListeners();
      return saved.location;
    }

    final BatchGalleryImage? remoteImage = _latestBatchImages.cast<BatchGalleryImage?>().firstWhere(
      (BatchGalleryImage? item) => item?.originalName == fileName,
      orElse: () => null,
    );
    if (remoteImage == null || !_isReachablePreviewUrl(remoteImage.resultUrl)) {
      throw StateError('This image is only available as a remote placeholder right now.');
    }

    final List<int> bytes = await _apiClient.getBytesFromAbsoluteUrl(
      remoteImage.resultUrl,
    );
    final SavedFile saved = await saveBytes(
      suggestedName: fileName,
      bytes: bytes,
      mimeType: _mimeTypeForFile(fileName),
    );
    _appendLog(
      level: LogLevel.info,
      source: 'api',
      message: 'Saved asset $fileName to ${saved.location}.',
      job: _latestBatch?.requestId ?? '-',
    );
    notifyListeners();
    return saved.location;
  }



  void _appendLog({
    required LogLevel level,
    required String source,
    required String message,
    required String job,
  }) {
    _logs.insert(
      0,
      LogEntry(
        time: _timestampLabel(DateTime.now()),
        level: level,
        source: source,
        message: message,
        job: job,
      ),
    );
  }

  String _buildRequestId() {
    final DateTime now = DateTime.now();
    return 'req-${now.millisecondsSinceEpoch}-${_random.nextInt(900) + 100}';
  }

  String _formatBytes(int bytes) {
    const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int index = 0;
    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index += 1;
    }
    final int decimals = index == 0 ? 0 : 1;
    return '${size.toStringAsFixed(decimals)} ${units[index]}';
  }

  String _timestampLabel(DateTime time) {
    final String hh = time.hour.toString().padLeft(2, '0');
    final String mm = time.minute.toString().padLeft(2, '0');
    final String ss = time.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _mimeTypeForFile(String fileName) {
    final String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'tif':
      case 'tiff':
        return 'image/tiff';
      default:
        return 'application/octet-stream';
    }
  }


  bool _isReachablePreviewUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return false;
    }
    return true; // Permitimos todas las URLs válidas, incluyendo localhost en desarrollo
  }

  String _resolveAdminImageUuid(String? requestedImageUuid) {
    final String direct = (requestedImageUuid ?? '').trim();
    if (direct.isNotEmpty) {
      return direct;
    }
    final String current = (_adminLogImageUuid ?? '').trim();
    if (current.isNotEmpty) {
      return current;
    }
    if (_latestBatchImages.isNotEmpty) {
      final String latest = _latestBatchImages.first.imageUuid.trim();
      if (latest.isNotEmpty) {
        return latest;
      }
    }
    return _defaultAdminImageUuid;
  }

  /// Converts a relative path (e.g. `/uploads/img.webp`) to an absolute URL
  /// based on the configured backend host (without the `/api/v1` prefix so that
  /// static assets are reachable).
  String _resolveRelativeUrl(String path) {
    try {
      final Uri baseUri = Uri.parse(_apiClient.config.baseUrl);
      // Use scheme + host only (strip /api/v1 path prefix for static files)
      final String origin = '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}';
      if (path.startsWith('/')) {
        return '$origin$path';
      }
      return '$origin/$path';
    } catch (_) {
      return path;
    }
  }

  /// Downloads the ZIP archive for any batch by its ID (not just the latest).
  Future<String> downloadBatchById(String batchId) async {
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in to download a batch.');
    }
    if (batchId.isEmpty) {
      throw StateError('No batch ID provided for download.');
    }

    _appendLog(
      level: LogLevel.info,
      source: 'download',
      message: 'Requesting ZIP archive for batch $batchId...',
      job: batchId,
    );

    try {
      final List<int> bytes = await _apiClient.getBytes(
        '/download-batch/$batchId',
        token: _session!.token,
      );
      final SavedFile saved = await saveBytes(
        suggestedName: '$batchId-results.zip',
        bytes: bytes,
        mimeType: 'application/zip',
      );
      final String location = saved.location;
      _appendLog(
        level: LogLevel.success,
        source: 'download',
        message: 'Batch $batchId archive saved to $location.',
        job: batchId,
      );
      return location;
    } catch (e) {
      _appendLog(
        level: LogLevel.error,
        source: 'download',
        message: 'Failed to download batch $batchId: $e',
        job: batchId,
      );
      rethrow;
    }
  }

  @override

  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
