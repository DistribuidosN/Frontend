enum RequestStatus { completed, failed }

class HistoryRequest {
  const HistoryRequest({
    required this.id,
    required this.date,
    required this.images,
    required this.transforms,
    required this.status,
    required this.duration,
    required this.nodes,
  });

  final String id;
  final String date;
  final int images;
  final List<String> transforms;
  final RequestStatus status;
  final String duration;
  final int nodes;
}
