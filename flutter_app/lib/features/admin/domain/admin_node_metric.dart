class AdminNodeMetric {
  const AdminNodeMetric({
    required this.id,
    required this.address,
    required this.active,
    required this.load,
    required this.currentJobs,
    required this.totalProcessed,
    required this.lastHeartbeat,
    required this.uptime,
    required this.raw,
    this.busyWorkers = 0,
    this.ramUsage = 0,
  });

  final String id;
  final String address;
  final bool active;
  final int load;       // cpu_usage %
  final int currentJobs;
  final int totalProcessed;
  final String lastHeartbeat;
  final String uptime;
  final Map<String, dynamic> raw;
  final int busyWorkers; // busy_workers from backend
  final int ramUsage;    // ram_usage % from backend

  static AdminNodeMetric? maybeFromJson(
    dynamic payload, {
    required String fallbackNodeId,
  }) {
    if (payload is! Map<String, dynamic>) {
      return null;
    }
    if (payload.isEmpty) {
      return null;
    }

    final Map<String, dynamic> json = payload['metric'] is Map<String, dynamic>
        ? payload['metric'] as Map<String, dynamic>
        : payload['data'] is Map<String, dynamic>
        ? payload['data'] as Map<String, dynamic>
        : payload;

    final String status = _stringValue(
      json,
      <String>['status', 'state', 'node_status'],
    ).toLowerCase();
    final bool active = _boolValue(
          json,
          <String>['active', 'is_active', 'online'],
        ) ??
        (status.isEmpty ||
            status == 'active' ||
            status == 'online' ||
            status == 'healthy');

    final int busyWorkers = _intValue(
      json,
      <String>['workers_busy', 'busy_workers', 'active_workers', 'workers', 'activeJobs'],
    );
    final int cpuUsage = _intValue(
      json,
      <String>['cpu_usage', 'cpu_percent', 'load', 'usage', 'percentage', 'cpuUsage'],
    );
    final int ramUsage = _intValue(
      json,
      <String>['ram_usage', 'memory_usage', 'mem_usage', 'memoryUsage'],
    );

    final String nodeId = _stringValue(json, <String>['node_id', 'id', 'nodeId']);
    final String uptimeText = _stringValue(json, <String>['uptime', 'uptime_text']);

    return AdminNodeMetric(
      id: nodeId.isEmpty ? fallbackNodeId : nodeId,
      address: _stringValue(
        json,
        <String>['address', 'host', 'endpoint', 'ip', 'nodeAddress'],
      ),
      active: active,
      load: cpuUsage,
      currentJobs: busyWorkers > 0
          ? busyWorkers
          : _intValue(
              json,
              <String>[
                'current_jobs',
                'active_jobs',
                'jobs',
                'pending_jobs',
                'activeJobs',
                'workers_busy',
              ],
            ),
      totalProcessed: _intValue(
        json,
        <String>[
          'total_processed',
          'processed',
          'processed_jobs',
          'totalJobs',
          'tasks_done',
        ],
      ),
      lastHeartbeat: _stringValue(
        json,
        <String>[
          'last_heartbeat',
          'heartbeat_at',
          'updated_at',
          'reported_at',
          'timestamp',
          'log_time',
        ],
      ),
      uptime: uptimeText.isNotEmpty
          ? uptimeText
          : _formatUptime(_intValue(json, <String>['uptime_seconds'])),
      raw: json,
      busyWorkers: busyWorkers,
      ramUsage: ramUsage,
    );
  }

  static String _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  static int _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is num) {
        return value.round();
      }
      if (value is String) {
        final int? parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
        final double? parsedDouble = double.tryParse(value);
        if (parsedDouble != null) {
          return parsedDouble.round();
        }
      }
      if (value is double) {
        return value.round();
      }
      if (value is int) {
        return value;
      }
      if (value is bool) {
        return value ? 1 : 0;
      }
      if (value != null) {
        final double? parsedDouble = double.tryParse(value.toString());
        if (parsedDouble != null) {
          return parsedDouble.round();
        }
      }
    }
    return 0;
  }

  static bool? _boolValue(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is bool) {
        return value;
      }
      if (value is String) {
        final String normalized = value.trim().toLowerCase();
        if (normalized == 'true') {
          return true;
        }
        if (normalized == 'false') {
          return false;
        }
      }
    }
    return null;
  }

  static String _formatUptime(int seconds) {
    if (seconds <= 0) {
      return '';
    }
    final int days = seconds ~/ 86400;
    final int hours = (seconds % 86400) ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int remainingSeconds = seconds % 60;
    final List<String> parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (remainingSeconds > 0 || parts.isEmpty) parts.add('${remainingSeconds}s');
    return parts.join(' ');
  }
}
