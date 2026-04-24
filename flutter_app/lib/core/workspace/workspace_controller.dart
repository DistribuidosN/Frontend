import 'dart:math';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
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
  WorkspaceController({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(ApiConfig.resolve());

  static const String _defaultAdminNodeId = 'nodo-go-1';
  static const String _defaultAdminImageUuid =
      'ab1df2d2-255c-409b-94c1-855a590e77b9';

  final ApiClient _apiClient;
  final Random _random = Random();

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
  String get adminProxyBaseUrl => ApiConfig.resolve().adminProxyBaseUrl;
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
  List<WorkerNode> get workerNodes {
    final bool batchActive =
        _latestBatch != null &&
        _latestBatch!.status.toLowerCase() != 'finished' &&
        _latestBatch!.status.toLowerCase() != 'completed';
    return <WorkerNode>[
      WorkerNode(
        id: 'node-alpha',
        address: '127.0.0.1:50051',
        active: true,
        load: batchActive ? 72 : 34,
        currentJobs: batchActive ? 1 : 0,
        totalProcessed: _historyRequests.fold<int>(
          12,
          (int acc, HistoryRequest item) =>
              acc + (item.images > 0 ? item.images : 1),
        ),
        lastHeartbeat: _timestampLabel(DateTime.now()),
        uptime: '2h 14m',
      ),
      WorkerNode(
        id: 'node-beta',
        address: '127.0.0.1:50052',
        active: isAuthenticated,
        load: batchActive ? 58 : 18,
        currentJobs: batchActive ? 1 : 0,
        totalProcessed: _historyRequests.fold<int>(
          8,
          (int acc, HistoryRequest item) =>
              acc + ((item.images > 0 ? item.images : 1) ~/ 2),
        ),
        lastHeartbeat: _timestampLabel(
          DateTime.now().subtract(const Duration(seconds: 8)),
        ),
        uptime: '1h 49m',
      ),
      WorkerNode(
        id: 'node-gamma',
        address: '127.0.0.1:50053',
        active: _historyRequests.isNotEmpty,
        load: batchActive ? 41 : 0,
        currentJobs: batchActive ? 0 : 0,
        totalProcessed: _historyRequests.length * 3,
        lastHeartbeat: _historyRequests.isNotEmpty
            ? _timestampLabel(
                DateTime.now().subtract(const Duration(minutes: 1)),
              )
            : 'No heartbeat yet',
        uptime: _historyRequests.isNotEmpty ? '44m' : 'offline',
      ),
    ];
  }

  Future<void> login({required String email, required String password}) async {
    final Map<String, dynamic> json = await _apiClient.postJson(
      '/auth/login',
      body: <String, dynamic>{'email': email, 'password': password},
    );

    _session = AuthSession(
      token: json['token'] as String? ?? '',
      roleId: (json['role_id'] as num?)?.toInt() ?? 0,
      identity: email,
      userUuid: (json['user_uuid'] as String?) ?? (json['uuid'] as String?),
      username: json['username'] as String?,
    );
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

  void logout() {
    _session = null;
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

  Future<UploadBatchResult> submitBatch() async {
    if (_session == null || _session!.token.isEmpty) {
      throw StateError('You need to sign in before sending a batch.');
    }
    if (_selectedFiles.isEmpty) {
      throw StateError('Select at least one image before starting processing.');
    }
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
          (json['batchId'] as String?) ??
          (json['jobId'] as String?) ??
          _buildRequestId(),
      status: (json['status'] as String?) ?? 'accepted',
      message: (json['message'] as String?) ?? 'Batch submitted successfully.',
      fileCount: _selectedFiles.length,
      filters: _selectedFilters.toList(),
      fileNames: _selectedFiles
          .map((UploadFileItem file) => file.name)
          .toList(),
    );

    _latestBatch = result;
    _latestBatchImages.clear();
    _appendLog(
      level: LogLevel.success,
      source: 'api',
      message:
          'Submitted batch ${result.requestId} with ${result.fileCount} image(s).',
      job: result.requestId,
    );
    try {
      await refreshHistory(notify: false);
    } catch (_) {
      _appendLog(
        level: LogLevel.warning,
        source: 'history',
        message: 'Batch submitted, but remote history could not be refreshed.',
        job: result.requestId,
      );
    }
    try {
      await refreshLatestBatchImages(notify: false);
    } catch (_) {
      _appendLog(
        level: LogLevel.warning,
        source: 'gallery',
        message: 'Batch submitted, but the gallery is not reachable yet.',
        job: result.requestId,
      );
    }
    notifyListeners();
    return result;
  }

  Future<void> refreshHistory({bool notify = true}) async {
    if (_session == null || _session!.token.isEmpty) {
      return;
    }

    final dynamic payload = await _apiClient.getDecoded(
      '/bd/batches',
      token: _session!.token,
    );
    final List<dynamic> rows = payload is List<dynamic>
        ? payload
        : <dynamic>[];

    _historyRequests
      ..clear()
      ..addAll(
        rows.map((dynamic row) {
          final Map<String, dynamic> item =
              row is Map<String, dynamic> ? row : <String, dynamic>{};
          final Map<String, dynamic> batch =
              item['batch'] is Map<String, dynamic>
              ? item['batch'] as Map<String, dynamic>
              : <String, dynamic>{};
          final String batchUuid =
              (batch['batch_uuid'] as String?) ??
              (item['batch_uuid'] as String?) ??
              _buildRequestId();
          final String rawStatus =
              ((batch['status'] as String?) ?? 'PENDING').toUpperCase();
          return HistoryRequest(
            id: batchUuid,
            date: ((batch['request_time'] as String?) ?? '').trim().isEmpty
                ? 'Remote batch'
                : (batch['request_time'] as String),
            images: 0,
            transforms: const <String>['Remote pipeline'],
            status: _requestStatusFromString(rawStatus),
            duration: 'Pending from backend',
            nodes: 0,
            coverImageUrl: item['cover_image_url'] as String?,
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

    final dynamic payload = await _apiClient.getDecoded(
      '/bd/gallery?batchUuid=${Uri.encodeQueryComponent(batch.requestId)}&page=1&limit=100',
      token: _session!.token,
    );
    final Map<String, dynamic> json = payload is Map<String, dynamic>
        ? payload
        : <String, dynamic>{};
    final List<dynamic> images = json['images'] is List<dynamic>
        ? json['images'] as List<dynamic>
        : <dynamic>[];

    _latestBatchImages
      ..clear()
      ..addAll(
        images.map((dynamic row) {
          final Map<String, dynamic> item =
              row is Map<String, dynamic> ? row : <String, dynamic>{};
          return BatchGalleryImage(
            imageUuid: (item['image_uuid'] as String?) ?? '',
            batchUuid: (item['batch_uuid'] as String?) ?? batch.requestId,
            originalName: (item['original_name'] as String?) ?? 'result',
            resultUrl: (item['result_path'] as String?) ?? '',
            status: (item['status'] as String?) ?? 'PENDING',
            nodeId: (item['node_id'] as String?) ?? '-',
          );
        }),
      );

    if (_adminLogImageUuid == null && _latestBatchImages.isNotEmpty) {
      final String candidate = _latestBatchImages.first.imageUuid.trim();
      if (candidate.isNotEmpty) {
        _adminLogImageUuid = candidate;
      }
    }

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
          ? _latestBatchImages
                .map((BatchGalleryImage image) => image.originalName)
                .toList()
          : batch.fileNames,
    );

    if (notify) {
      notifyListeners();
    }
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

    _session = _session!.copyWith(
      userUuid: uuid ?? _session!.userUuid,
      username: username ?? _session!.username,
      roleId: roleId ?? _session!.roleId,
    );

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> refreshUserStatistics({bool notify = true}) async {
    if (_session == null || _session!.token.isEmpty) {
      return;
    }

    // Prefer the UUID-based endpoint when we already know the uuid.
    final String? uuid = _session!.userUuid;
    final String path = (uuid != null && uuid.isNotEmpty)
        ? '/users/$uuid/statistics'
        : '/user/statistics';

    dynamic payload;
    try {
      payload = await _apiClient.getDecoded(path, token: _session!.token);
    } catch (_) {
      // Fallback to generic endpoint if UUID variant fails.
      if (path != '/user/statistics') {
        payload = await _apiClient.getDecoded(
          '/user/statistics',
          token: _session!.token,
        );
      } else {
        rethrow;
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

    final String? uuid = _session!.userUuid;
    final String path = (uuid != null && uuid.isNotEmpty)
        ? '/users/$uuid/activity'
        : '/user/activity';

    dynamic payload;
    try {
      payload = await _apiClient.getDecoded(path, token: _session!.token);
    } catch (_) {
      if (path != '/user/activity') {
        payload = await _apiClient.getDecoded(
          '/user/activity',
          token: _session!.token,
        );
      } else {
        rethrow;
      }
    }

    final List<dynamic> rows = switch (payload) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map => map['activity'] is List<dynamic>
          ? map['activity'] as List<dynamic>
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

    final dynamic payload = await _apiClient.getDecodedFromAbsoluteUrl(
      _adminProxyUrl('/admin/metrics/$targetNodeId'),
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
    final dynamic payload = await _apiClient.getDecodedFromAbsoluteUrl(
      _adminProxyUrl('/admin/logs/$candidateImageUuid'),
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
        '/node/batch/${batch.requestId}/download',
        token: _session!.token,
      );
      _appendLog(
        level: LogLevel.success,
        source: 'api',
        message: 'Downloaded archive for ${batch.requestId} from backend.',
        job: batch.requestId,
      );
    } catch (_) {
      if (_selectedFiles.isEmpty) {
        throw StateError(
          'ZIP download is not available for remote batches because the backend archive endpoint did not respond.',
        );
      }
      final Archive archive = Archive();
      for (final UploadFileItem file in _selectedFiles) {
        archive.add(ArchiveFile(file.name, file.bytes.length, file.bytes));
      }
      bytes = ZipEncoder().encode(archive);
      fileName = '${batch.requestId}-demo.zip';
      _appendLog(
        level: LogLevel.warning,
        source: 'demo',
        message:
            'Backend download unavailable for ${batch.requestId}; exported staged files as demo ZIP.',
        job: batch.requestId,
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

  bool isReachablePreviewUrl(String url) => _isReachablePreviewUrl(url);

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

  RequestStatus _requestStatusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'CONVERTED':
      case 'DONE':
      case 'FINISHED':
        return RequestStatus.completed;
      default:
        return RequestStatus.failed;
    }
  }

  bool _isReachablePreviewUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return false;
    }
    final String host = uri.host.toLowerCase();
    return host != 'localhost' && host != '127.0.0.1';
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

  String _adminProxyUrl(String path) {
    final String base = adminProxyBaseUrl.endsWith('/')
        ? adminProxyBaseUrl.substring(0, adminProxyBaseUrl.length - 1)
        : adminProxyBaseUrl;
    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$base$normalizedPath';
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
