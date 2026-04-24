class BatchGalleryImage {
  const BatchGalleryImage({
    required this.imageUuid,
    required this.batchUuid,
    required this.originalName,
    required this.resultUrl,
    required this.status,
    required this.nodeId,
  });

  final String imageUuid;
  final String batchUuid;
  final String originalName;
  final String resultUrl;
  final String status;
  final String nodeId;
}
