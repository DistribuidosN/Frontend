import 'dart:convert';

/// Represents one entry from `/user/activity` or `/users/:uuid/activity`.
///
/// Backend Go fields mapped:
///   - `activity_uuid` / `id` / `event_id` / `uuid`
///   - `activity_type` / `action` / `event_type` / `type`
///   - `activity_details` – JSON-encoded string with extra data
///   - `created_at` / `timestamp` / `occurred_at`
///   - `description` / `message`
///   - `ref_uuid` / `parent_uuid`
class UserActivityEvent {
  const UserActivityEvent({
    required this.id,
    required this.action,
    required this.description,
    required this.timestamp,
    this.batchUuid,
    this.status,
    this.imagesProcessed = 0,
    this.refUuid,
    this.parentUuid,
  });

  final String id;
  final String action;
  final String description;
  final String timestamp;
  final String? batchUuid;
  final String? status;
  final int imagesProcessed;
  final String? refUuid;
  final String? parentUuid;

  factory UserActivityEvent.fromJson(Map<String, dynamic> json) {
    // Identity
    final String id = (json['activity_uuid'] as String?) ??
        (json['id'] as String?) ??
        (json['event_id'] as String?) ??
        (json['uuid'] as String?) ??
        DateTime.now().microsecondsSinceEpoch.toString();

    // Action / type
    final String action = (json['activity_type'] as String?) ??
        (json['action'] as String?) ??
        (json['event_type'] as String?) ??
        (json['type'] as String?) ??
        'activity';

    // Timestamp
    final String timestamp = (json['created_at'] as String?) ??
        (json['timestamp'] as String?) ??
        (json['occurred_at'] as String?) ??
        (json['time'] as String?) ??
        '';

    // activity_details: JSON-encoded string with extra info
    final dynamic detailsRaw = json['activity_details'] ?? json['details'];
    Map<String, dynamic> details = const <String, dynamic>{};
    if (detailsRaw is String && detailsRaw.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(detailsRaw);
        if (decoded is Map<String, dynamic>) {
          details = decoded;
        }
      } catch (_) {}
    } else if (detailsRaw is Map<String, dynamic>) {
      details = detailsRaw;
    }

    // images_processed
    int imagesProcessed = 0;
    final dynamic imgRaw = details['images_processed'] ??
        details['processed'] ??
        details['images'] ??
        json['images_processed'];
    if (imgRaw is num) {
      imagesProcessed = imgRaw.toInt();
    } else if (imgRaw is String) {
      imagesProcessed = int.tryParse(imgRaw) ?? 0;
    }

    // Human-readable description
    final String description = (json['description'] as String?) ??
        (json['message'] as String?) ??
        (details['description'] as String?) ??
        action;

    return UserActivityEvent(
      id: id,
      action: action,
      description: description,
      timestamp: timestamp,
      batchUuid: (json['batch_uuid'] as String?) ??
          (json['batch_id'] as String?) ??
          (details['batch_uuid'] as String?),
      status: json['status'] as String?,
      imagesProcessed: imagesProcessed,
      refUuid: (json['ref_uuid'] as String?) ?? (details['ref_uuid'] as String?),
      parentUuid: (json['parent_uuid'] as String?) ?? (details['parent_uuid'] as String?),
    );
  }
}
