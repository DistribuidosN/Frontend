import 'dart:math';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:imageflow_flutter/core/api/api_client.dart';
import 'package:imageflow_flutter/core/api/api_config.dart';
import 'package:imageflow_flutter/core/files/save_bytes.dart';
import 'package:imageflow_flutter/features/auth/domain/auth_session.dart';
import 'package:imageflow_flutter/features/history/domain/history_request.dart';
import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';
import 'package:imageflow_flutter/features/nodes/domain/worker_node.dart';
import 'package:imageflow_flutter/features/upload/domain/upload_batch_result.dart';
import 'package:imageflow_flutter/features/upload/domain/upload_file_item.dart';

class WorkspaceController extends ChangeNotifier {
  WorkspaceController({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(ApiConfig.resolve());

  final ApiClient _apiClient;
  final Random _random = Random();

  AuthSession? _session;
  final List<UploadFileItem> _selectedFiles = <UploadFileItem>[];
  final Set<String> _selectedFilters = <String>{};
  final List<HistoryRequest> _historyRequests = <HistoryRequest>[];
  final List<LogEntry> _logs = <LogEntry>[];
  UploadBatchResult? _latestBatch;

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;
  List<UploadFileItem> get selectedFiles =>
      List<UploadFileItem>.unmodifiable(_selectedFiles);
  Set<String> get selectedFilters => Set<String>.unmodifiable(_selectedFilters);
  UploadBatchResult? get latestBatch => _latestBatch;
  String get apiBaseUrl => ApiConfig.resolve().baseUrl;
  List<HistoryRequest> get historyRequests =>
      List<HistoryRequest>.unmodifiable(_historyRequests);
  List<LogEntry> get logs => List<LogEntry>.unmodifiable(_logs);
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
          (int acc, HistoryRequest item) => acc + item.images,
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
          (int acc, HistoryRequest item) => acc + (item.images ~/ 2),
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
    );
    _appendLog(
      level: LogLevel.success,
      source: 'auth',
      message: 'Signed in as $email.',
      job: '-',
    );
    notifyListeners();
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _apiClient.postJson(
      '/auth/register',
      body: <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'role_id': 2,
      },
    );
    _appendLog(
      level: LogLevel.success,
      source: 'auth',
      message: 'Created account for $email.',
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
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const <String>[
        'jpg',
        'jpeg',
        'png',
        'webp',
        'bmp',
        'gif',
        'tiff',
        'ico',
      ],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return false;
    }

    final List<UploadFileItem> incoming = result.files
        .where(
          (PlatformFile file) => file.bytes != null && file.bytes!.isNotEmpty,
        )
        .map(
          (PlatformFile file) => UploadFileItem(
            id:
                file.identifier ??
                '${file.name}-${file.size}-${_random.nextInt(1 << 32)}',
            name: file.name,
            sizeLabel: _formatBytes(file.size),
            sizeBytes: file.size,
            bytes: file.bytes!,
          ),
        )
        .toList();

    if (incoming.isEmpty) {
      return false;
    }

    _selectedFiles.addAll(incoming);
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
    if (_selectedFilters.isEmpty) {
      throw StateError(
        'Choose at least one transformation before starting processing.',
      );
    }

    final Map<String, dynamic> json = await _apiClient.postMultipart(
      '/node/batch',
      files: _selectedFiles,
      filters: _selectedFilters.toList(),
      token: _session!.token,
    );

    final UploadBatchResult result = UploadBatchResult(
      requestId: (json['jobId'] as String?) ?? _buildRequestId(),
      status: (json['status'] as String?) ?? 'accepted',
      message: (json['message'] as String?) ?? 'Batch submitted successfully.',
      fileCount: _selectedFiles.length,
      filters: _selectedFilters.toList(),
      fileNames: _selectedFiles
          .map((UploadFileItem file) => file.name)
          .toList(),
    );

    _latestBatch = result;
    _historyRequests.insert(
      0,
      HistoryRequest(
        id: result.requestId,
        date: _longDateLabel(DateTime.now()),
        images: result.fileCount,
        transforms: result.filters,
        status: RequestStatus.completed,
        duration: 'pending',
        nodes: workerNodes.where((WorkerNode node) => node.active).length,
      ),
    );
    _appendLog(
      level: LogLevel.success,
      source: 'api',
      message:
          'Submitted batch ${result.requestId} with ${result.fileCount} image(s).',
      job: result.requestId,
    );
    notifyListeners();
    return result;
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
    final UploadFileItem file = _selectedFiles.firstWhere(
      (UploadFileItem item) => item.name == fileName,
      orElse: () => throw StateError('Selected file $fileName not found.'),
    );

    final SavedFile saved = await saveBytes(
      suggestedName: file.name,
      bytes: file.bytes,
      mimeType: _mimeTypeForFile(file.name),
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

  String _longDateLabel(DateTime time) {
    final String yyyy = time.year.toString();
    final String mm = time.month.toString().padLeft(2, '0');
    final String dd = time.day.toString().padLeft(2, '0');
    final String hh = time.hour.toString().padLeft(2, '0');
    final String min = time.minute.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd $hh:$min';
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

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
