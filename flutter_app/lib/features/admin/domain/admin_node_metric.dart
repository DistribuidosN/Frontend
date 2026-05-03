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
      <String>['busy_workers', 'active_workers', 'workers', 'activeJobs'],
    );
    final int cpuUsage = _intValue(
      json,
      <String>['cpu_usage', 'cpu_percent', 'load', 'usage', 'percentage', 'cpuUsage'],
    );
    final int ramUsage = _intValue(
      json,
      <String>['ram_usage', 'memory_usage', 'mem_usage', 'memoryUsage'],
    );

    return AdminNodeMetric(
      id: _stringValue(json, <String>['node_id', 'id', 'nodeId']) == ''
          ? fallbackNodeId
          : _stringValue(json, <String>['node_id', 'id', 'nodeId']),
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
              <String>['current_jobs', 'active_jobs', 'jobs', 'pending_jobs', 'activeJobs'],
            ),
      totalProcessed: _intValue(
        json,
        <String>['total_processed', 'processed', 'processed_jobs', 'totalJobs'],
      ),
      lastHeartbeat: _stringValue(
        json,
        <String>['last_heartbeat', 'heartbeat_at', 'updated_at', 'reported_at', 'timestamp'],
      ),
      uptime: _stringValue(json, <String>['uptime', 'uptime_text']),
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
}
