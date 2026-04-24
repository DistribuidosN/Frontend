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
  });

  final String id;
  final String address;
  final bool active;
  final int load;
  final int currentJobs;
  final int totalProcessed;
  final String lastHeartbeat;
  final String uptime;
  final Map<String, dynamic> raw;

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

    final String status = _stringValue(
      payload,
      <String>['status', 'state', 'node_status'],
    ).toLowerCase();
    final bool active = _boolValue(
          payload,
          <String>['active', 'is_active', 'online'],
        ) ??
        (status == 'active' || status == 'online' || status == 'healthy');

    return AdminNodeMetric(
      id: _stringValue(payload, <String>['node_id', 'id', 'nodeId']) == ''
          ? fallbackNodeId
          : _stringValue(payload, <String>['node_id', 'id', 'nodeId']),
      address: _stringValue(
        payload,
        <String>['address', 'host', 'endpoint', 'ip'],
      ),
      active: active,
      load: _intValue(
        payload,
        <String>['load', 'cpu_usage', 'cpu_percent', 'usage', 'percentage'],
      ),
      currentJobs: _intValue(
        payload,
        <String>['current_jobs', 'active_jobs', 'jobs', 'pending_jobs'],
      ),
      totalProcessed: _intValue(
        payload,
        <String>['total_processed', 'processed', 'processed_jobs'],
      ),
      lastHeartbeat: _stringValue(
        payload,
        <String>['last_heartbeat', 'heartbeat_at', 'updated_at'],
      ),
      uptime: _stringValue(payload, <String>['uptime', 'uptime_text']),
      raw: payload,
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
