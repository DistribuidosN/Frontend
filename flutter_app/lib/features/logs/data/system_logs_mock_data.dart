import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';

const List<LogEntry> systemLogs = <LogEntry>[
  LogEntry(
    time: '14:33:07',
    level: LogLevel.success,
    source: 'worker-node-01',
    message: 'Image image-024.jpg processed successfully',
    job: 'req-4522',
  ),
  LogEntry(
    time: '14:33:06',
    level: LogLevel.success,
    source: 'worker-node-02',
    message: 'Image image-023.jpg processed successfully',
    job: 'req-4522',
  ),
  LogEntry(
    time: '14:33:05',
    level: LogLevel.info,
    source: 'orchestrator',
    message: 'Task distribution completed for request req-4522',
    job: 'req-4522',
  ),
  LogEntry(
    time: '14:32:16',
    level: LogLevel.info,
    source: 'orchestrator',
    message: 'Distributed 24 tasks across 8 worker nodes',
    job: 'req-4522',
  ),
  LogEntry(
    time: '14:32:15',
    level: LogLevel.info,
    source: 'api',
    message: 'Request received: req-4522 with 24 images',
    job: 'req-4522',
  ),
  LogEntry(
    time: '14:30:45',
    level: LogLevel.warning,
    source: 'worker-node-06',
    message: 'Node health check failed - retrying...',
    job: '-',
  ),
  LogEntry(
    time: '14:28:12',
    level: LogLevel.error,
    source: 'worker-node-03',
    message: 'Failed to process image-015.jpg: Invalid format',
    job: 'req-4518',
  ),
  LogEntry(
    time: '14:25:33',
    level: LogLevel.success,
    source: 'orchestrator',
    message: 'Cluster initialized with 8 active nodes',
    job: '-',
  ),
];
