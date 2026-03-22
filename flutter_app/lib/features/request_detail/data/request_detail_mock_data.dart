import 'package:imageflow_flutter/features/logs/domain/log_entry.dart';
import 'package:imageflow_flutter/features/request_detail/domain/request_detail_models.dart';

const List<TransformationDetail> transformationDetails = <TransformationDetail>[
  TransformationDetail(name: 'Grayscale', value: 'Enabled'),
  TransformationDetail(name: 'Resize', value: '1920x1080'),
  TransformationDetail(name: 'Brightness', value: '+10%'),
  TransformationDetail(name: 'Contrast', value: '+5%'),
  TransformationDetail(name: 'Format', value: 'JPG'),
  TransformationDetail(name: 'Quality', value: '85%'),
];

const List<RequestImageDetail> requestImageDetails = <RequestImageDetail>[
  RequestImageDetail(
    name: 'image-001.jpg',
    node: 'node-01',
    start: '14:32:16',
    end: '14:32:18',
    status: 'completed',
  ),
  RequestImageDetail(
    name: 'image-002.jpg',
    node: 'node-02',
    start: '14:32:16',
    end: '14:32:17',
    status: 'completed',
  ),
  RequestImageDetail(
    name: 'image-003.jpg',
    node: 'node-03',
    start: '14:32:16',
    end: '14:32:18',
    status: 'completed',
  ),
  RequestImageDetail(
    name: 'image-004.jpg',
    node: 'node-04',
    start: '14:32:17',
    end: '14:32:19',
    status: 'completed',
  ),
];

const List<LogEntry> requestLogs = <LogEntry>[
  LogEntry(
    time: '14:32:15',
    level: LogLevel.info,
    source: 'api',
    message: 'Request received: req-4522',
    job: 'req-4522',
  ),
  LogEntry(
    time: '14:32:15',
    level: LogLevel.info,
    source: 'api',
    message: 'Validated 24 images for processing',
    job: 'req-4522',
  ),
  LogEntry(
    time: '14:32:16',
    level: LogLevel.info,
    source: 'orchestrator',
    message: 'Distributed tasks across 8 worker nodes',
    job: 'req-4522',
  ),
  LogEntry(
    time: '14:32:16',
    level: LogLevel.success,
    source: 'orchestrator',
    message: 'Processing started',
    job: 'req-4522',
  ),
  LogEntry(
    time: '14:33:07',
    level: LogLevel.success,
    source: 'orchestrator',
    message: 'All images processed successfully',
    job: 'req-4522',
  ),
];
