enum RequestStatus {
  completed,
  failed,
  received,
  processing,
  pending,
}

class HistoryRequest {
  const HistoryRequest({
    required this.id,
    required this.date,
    required this.images,
    required this.transforms,
    required this.status,
    required this.duration,
    required this.nodes,
    this.coverImageUrl,
  });

  final String id;
  final String date;
  final int images;
  final List<String> transforms;
  final RequestStatus status;
  final String duration;
  final int nodes;
  final String? coverImageUrl;

  static RequestStatus statusFromString(String raw) {
    switch (raw.toUpperCase()) {
      case 'COMPLETED':
      case 'CONVERTED':
      case 'DONE':
      case 'FINISHED':
        return RequestStatus.completed;
      case 'FAILED':
      case 'ERROR':
        return RequestStatus.failed;
      case 'RECEIVED':
        return RequestStatus.received;
      case 'PROCESSING':
      case 'IN_PROGRESS':
        return RequestStatus.processing;
      default:
        return RequestStatus.pending;
    }
  }
}
