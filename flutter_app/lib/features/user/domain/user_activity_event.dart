/// Represents one entry from `/user/activity` or `/users/:uuid/activity`.
class UserActivityEvent {
  const UserActivityEvent({
    required this.id,
    required this.action,
    required this.description,
    required this.timestamp,
    this.batchUuid,
    this.status,
  });

  final String id;
  final String action;
  final String description;
  final String timestamp;
  final String? batchUuid;
  final String? status;

  factory UserActivityEvent.fromJson(Map<String, dynamic> json) {
    final String id = (json['id'] as String?) ??
        (json['event_id'] as String?) ??
        (json['uuid'] as String?) ??
        DateTime.now().microsecondsSinceEpoch.toString();

    final String action = (json['action'] as String?) ??
        (json['event_type'] as String?) ??
        (json['type'] as String?) ??
        'activity';

    final String description = (json['description'] as String?) ??
        (json['message'] as String?) ??
        (json['details'] as String?) ??
        action;

    final String timestamp = (json['timestamp'] as String?) ??
        (json['created_at'] as String?) ??
        (json['time'] as String?) ??
        '';

    return UserActivityEvent(
      id: id,
      action: action,
      description: description,
      timestamp: timestamp,
      batchUuid: (json['batch_uuid'] as String?) ?? (json['batch_id'] as String?),
      status: (json['status'] as String?),
    );
  }
}
