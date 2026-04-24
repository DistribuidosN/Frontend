/// Represents user-level telemetry returned by the backend.
///
/// The backend response schema varies slightly across environments, so this
/// model extracts the most common fields with defensive fallbacks. Any extra
/// metrics are preserved in [extras] so they can still be displayed.
class UserStatistics {
  const UserStatistics({
    required this.totalBatches,
    required this.totalImages,
    required this.successfulImages,
    required this.failedImages,
    required this.lastActivity,
    this.extras = const <String, dynamic>{},
  });

  final int totalBatches;
  final int totalImages;
  final int successfulImages;
  final int failedImages;
  final String? lastActivity;
  final Map<String, dynamic> extras;

  double get successRate {
    if (totalImages <= 0) return 0;
    return successfulImages / totalImages;
  }

  String get successRateLabel {
    if (totalImages <= 0) return '0%';
    return '${(successRate * 100).toStringAsFixed(1)}%';
  }

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final Map<String, dynamic> stats = json['statistics'] is Map<String, dynamic>
        ? json['statistics'] as Map<String, dynamic>
        : json;

    return UserStatistics(
      totalBatches: asInt(
        stats['total_batches'] ??
            stats['batches_total'] ??
            stats['batches'] ??
            stats['totalBatches'],
      ),
      totalImages: asInt(
        stats['total_images'] ??
            stats['images_total'] ??
            stats['images'] ??
            stats['totalImages'],
      ),
      successfulImages: asInt(
        stats['successful_images'] ??
            stats['success_count'] ??
            stats['successful'] ??
            stats['processed_images'],
      ),
      failedImages: asInt(
        stats['failed_images'] ??
            stats['failed_count'] ??
            stats['failed'] ??
            stats['errors'],
      ),
      lastActivity: (stats['last_activity'] as String?) ??
          (stats['last_seen'] as String?) ??
          (stats['updated_at'] as String?),
      extras: stats,
    );
  }

  static UserStatistics empty() => const UserStatistics(
        totalBatches: 0,
        totalImages: 0,
        successfulImages: 0,
        failedImages: 0,
        lastActivity: null,
      );
}
