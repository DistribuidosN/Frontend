enum LogLevel { success, info, warning, error }

class LogEntry {
  const LogEntry({
    required this.time,
    required this.level,
    required this.source,
    required this.message,
    required this.job,
  });

  final String time;
  final LogLevel level;
  final String source;
  final String message;
  final String job;
}
