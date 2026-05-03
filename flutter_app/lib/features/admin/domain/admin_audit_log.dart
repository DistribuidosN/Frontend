import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';

class AdminAuditLog {
  const AdminAuditLog({
    required this.id,
    required this.imageUuid,
    required this.level,
    required this.message,
    required this.createdAt,
  });

  final int? id;
  final String imageUuid;
  final LogLevel level;
  final String message;
  final String createdAt;

  factory AdminAuditLog.fromJson(Map<String, dynamic> json) {
    final String rawLevel = ((json['level'] as String?) ?? '')
        .trim()
        .toLowerCase();
    return AdminAuditLog(
      id: (json['id'] as num?)?.toInt(),
      imageUuid: (json['image_uuid'] as String?) ??
          (json['imageUuid'] as String?) ??
          '',
      level: switch (rawLevel) {
        'success' => LogLevel.success,
        'warning' || 'warn' => LogLevel.warning,
        'error' => LogLevel.error,
        _ => LogLevel.info,
      },
      message: (json['message'] as String?) ?? 'No message',
      createdAt: (json['created_at'] as String?) ??
          (json['timestamp'] as String?) ??
          '',
    );
  }
}
