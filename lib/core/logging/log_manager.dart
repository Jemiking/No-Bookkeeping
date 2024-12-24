import 'logger.dart';
import 'log_level.dart';

class LogManager {
  final Logger _logger;
  final Map<String, Logger> _moduleLoggers = {};

  LogManager(this._logger);

  // 获取模块专用日志记录器
  Logger getLogger(String module) {
    return _moduleLoggers.putIfAbsent(
      module,
      () => Logger(maxLogs: 500, minLevel: LogLevel.debug),
    );
  }

  // 记录应用级别日志
  void logAppEvent(String message, {LogLevel level = LogLevel.info}) {
    switch (level) {
      case LogLevel.debug:
        _logger.debug(message);
      case LogLevel.info:
        _logger.info(message);
      case LogLevel.warning:
        _logger.warning(message);
      case LogLevel.error:
        _logger.error(message);
    }
  }

  // 导出日志
  Future<String> exportLogs({
    DateTime? startTime,
    DateTime? endTime,
    LogLevel? minLevel,
  }) async {
    final logs = _logger.getLogs(
      startTime: startTime,
      endTime: endTime,
      level: minLevel,
    );

    // 将日志转换为JSON格式
    final logsJson = logs.map((log) => log.toMap()).toList();
    return logsJson.toString();
  }

  // 清理过期日志
  void cleanupOldLogs(Duration age) {
    final cutoffTime = DateTime.now().subtract(age);
    final logs = _logger.getLogs();
    logs.removeWhere((log) => log.timestamp.isBefore(cutoffTime));
  }

  // 获取最近的错误日志
  List<LogEntry> getRecentErrors({int limit = 10}) {
    return _logger
        .getLogs(level: LogLevel.error)
        .take(limit)
        .toList();
  }
} 