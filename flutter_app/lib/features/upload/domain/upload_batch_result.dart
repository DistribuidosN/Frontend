class UploadBatchResult {
  const UploadBatchResult({
    required this.requestId,
    required this.status,
    required this.message,
    required this.fileCount,
    required this.filters,
    required this.fileNames,
  });

  final String requestId;
  final String status;
  final String message;
  final int fileCount;
  final List<String> filters;
  final List<String> fileNames;
}
