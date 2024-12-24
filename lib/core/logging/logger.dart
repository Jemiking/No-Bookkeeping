import 'log_level.dart';

abstract class AppLogger {
  void debug(String message, [dynamic error, StackTrace? stackTrace]);
  void info(String message, [dynamic error, StackTrace? stackTrace]);
  void warning(String message, [dynamic error, StackTrace? stackTrace]);
  void error(String message, [dynamic error, StackTrace? stackTrace]);
}

class Logger implements AppLogger {
  final List<LogEntry> _logs = [];
  final int maxLogs;
  final LogLevel minLevel;

  Logger({
    this.maxLogs = 1000,
    this.minLevel = LogLevel.debug,
  });

  @override
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  @override
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  @override
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void _log(
    LogLevel level,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (level.index < minLevel.index) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    _logs.add(entry);
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }

    _persistLog(entry);
  }

  Future<void> _persistLog(LogEntry entry) async {
    // TODO: 实现日志持久化逻辑
  }

  List<LogEntry> getLogs({
    LogLevel? level,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return _logs.where((log) {
      if (level != null && log.level != level) return false;
      if (startTime != null && log.timestamp.isBefore(startTime)) return false;
      if (endTime != null && log.timestamp.isAfter(endTime)) return false;
      return true;
    }).toList();
  }

  void clearLogs() {
    _logs.clear();
  }
} 