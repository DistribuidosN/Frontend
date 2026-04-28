class BatchGalleryImage {
  const BatchGalleryImage({
    required this.imageUuid,
    required this.batchUuid,
    required this.originalName,
    required this.resultUrl,
    required this.status,
    required this.nodeId,
    this.receptionTime,
    this.conversionTime,
  });

  final String imageUuid;
  final String batchUuid;
  final String originalName;
  final String resultUrl;
  final String status;
  final String nodeId;
  final String? receptionTime;
  final String? conversionTime;

  factory BatchGalleryImage.fromJson(
    Map<String, dynamic> json, {
    required String fallbackBatchUuid,
    required String Function(String) resolveUrl,
  }) {
    String rawUrl = (json['result_path'] as String?) ??
        (json['result_url'] as String?) ??
        (json['output_path'] as String?) ??
        (json['output_url'] as String?) ??
        (json['processed_url'] as String?) ??
        (json['image_url'] as String?) ??
        (json['url'] as String?) ??
        (json['path'] as String?) ??
        (json['download_url'] as String?) ??
        '';

    if (rawUrl.isNotEmpty) {
      if (!rawUrl.startsWith('http') && !rawUrl.startsWith('data:')) {
        rawUrl = resolveUrl(rawUrl);
      } else if (rawUrl.contains('.ngrok-free.app') || rawUrl.contains('localhost')) {
        // Resolve backend returning old ngrok urls or localhost
        final Uri badUri = Uri.parse(rawUrl);
        // resolveUrl takes relative paths, so we cheat by asking it to resolve / and taking the host
        final String origin = resolveUrl('/');
        final Uri currentUri = Uri.parse(origin);
        
        // Also replace the port if the bad URI has one and the current one doesn't
        String patched = rawUrl.replaceFirst(badUri.host, currentUri.host);
        if (badUri.hasPort && !currentUri.hasPort) {
          patched = patched.replaceFirst(':${badUri.port}', '');
        }
        rawUrl = patched;
      }
    }

    return BatchGalleryImage(
      imageUuid: (json['image_uuid'] as String?) ??
          (json['uuid'] as String?) ??
          (json['id'] as String?) ??
          '',
      batchUuid: (json['batch_uuid'] as String?) ?? fallbackBatchUuid,
      originalName: (json['original_name'] as String?) ??
          (json['name'] as String?) ??
          (json['fileName'] as String?) ??
          'result',
      resultUrl: rawUrl,
      status: (json['status'] as String?) ?? 'RECEIVED',
      nodeId: (json['node_id'] as String?) ?? (json['nodeId'] as String?) ?? '-',
      receptionTime: json['reception_time'] as String?,
      conversionTime: json['conversion_time'] as String?,
    );
  }

  /// Whether the image has been fully processed by the backend worker.
  bool get isProcessed {
    final s = status.toUpperCase();
    return s == 'COMPLETED' || s == 'CONVERTED' || s == 'DONE' || s == 'FINISHED';
  }

  /// Whether the image has a renderable URL.
  bool get hasResult => resultUrl.isNotEmpty;
}
