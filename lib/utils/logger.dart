import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static final Logger _instance = Logger._internal();
  static const String _logFileName = 'app.log';
  static const int _maxLogSize = 10 * 1024 * 1024; // 10MB
  static const int _maxLogFiles = 5;
  
  File? _logFile;
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

  factory Logger() {
    return _instance;
  }

  Logger._internal();

  static Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final logDir = Directory('${directory.path}/logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    _instance._logFile = File('${logDir.path}/$_logFileName');
    if (!await _instance._logFile!.exists()) {
      await _instance._logFile!.create();
    }

    await _instance._rotateLogFiles();
  }

  static void debug(String message) {
    _instance._log(LogLevel.debug, message);
  }

  static void info(String message) {
    _instance._log(LogLevel.info, message);
  }

  static void warning(String message) {
    _instance._log(LogLevel.warning, message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    final errorMessage = error != null ? ': $error' : '';
    final stackMessage = stackTrace != null ? '\n$stackTrace' : '';
    _instance._log(LogLevel.error, '$message$errorMessage$stackMessage');
  }

  Future<void> _log(LogLevel level, String message) async {
    if (_logFile == null) return;

    final timestamp = _dateFormat.format(DateTime.now());
    final logMessage = '$timestamp [${level.toString().toUpperCase()}] $message\n';

    try {
      await _logFile!.writeAsString(
        logMessage,
        mode: FileMode.append,
        flush: true,
      );

      // 检查日志文件大小
      if ((await _logFile!.length()) > _maxLogSize) {
        await _rotateLogFiles();
      }
    } catch (e) {
      print('Error writing to log file: $e');
    }
  }

  Future<void> _rotateLogFiles() async {
    if (_logFile == null) return;

    try {
      final directory = _logFile!.parent;
      final baseFileName = _logFileName.split('.').first;
      final extension = _logFileName.split('.').last;

      // 删除最旧的日志文件
      final oldestLogFile = File(
        '${directory.path}/$baseFileName.$_maxLogFiles.$extension'
      );
      if (await oldestLogFile.exists()) {
        await oldestLogFile.delete();
      }

      // 重命名现有的日志文件
      for (var i = _maxLogFiles - 1; i >= 1; i--) {
        final file = File(
          '${directory.path}/$baseFileName.$i.$extension'
        );
        if (await file.exists()) {
          await file.rename(
            '${directory.path}/$baseFileName.${i + 1}.$extension'
          );
        }
      }

      // 重命名当前日志文件
      if (await _logFile!.exists()) {
        await _logFile!.rename(
          '${directory.path}/$baseFileName.1.$extension'
        );
      }

      // 创建新的日志文件
      _logFile = File('${directory.path}/$_logFileName');
      await _logFile!.create();
    } catch (e) {
      print('Error rotating log files: $e');
    }
  }

  Future<List<String>> getLogs([int maxLines = 100]) async {
    if (_logFile == null || !await _logFile!.exists()) {
      return [];
    }

    try {
      final lines = await _logFile!.readAsLines();
      return lines.reversed.take(maxLines).toList();
    } catch (e) {
      print('Error reading log file: $e');
      return [];
    }
  }

  Future<void> clearLogs() async {
    if (_logFile == null) return;

    try {
      await _logFile!.writeAsString('');
    } catch (e) {
      print('Error clearing log file: $e');
    }
  }

  Future<Map<String, int>> getLogStatistics() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return {};
    }

    final stats = <String, int>{
      'debug': 0,
      'info': 0,
      'warning': 0,
      'error': 0,
    };

    try {
      final lines = await _logFile!.readAsLines();
      for (var line in lines) {
        if (line.contains('[DEBUG]')) stats['debug'] = stats['debug']! + 1;
        if (line.contains('[INFO]')) stats['info'] = stats['info']! + 1;
        if (line.contains('[WARNING]')) stats['warning'] = stats['warning']! + 1;
        if (line.contains('[ERROR]')) stats['error'] = stats['error']! + 1;
      }
    } catch (e) {
      print('Error getting log statistics: $e');
    }

    return stats;
  }

  Future<void> exportLogs(String exportPath) async {
    if (_logFile == null || !await _logFile!.exists()) {
      return;
    }

    try {
      final exportFile = File(exportPath);
      await _logFile!.copy(exportFile.path);
    } catch (e) {
      print('Error exporting logs: $e');
    }
  }

  Future<List<String>> searchLogs(String keyword) async {
    if (_logFile == null || !await _logFile!.exists()) {
      return [];
    }

    try {
      final lines = await _logFile!.readAsLines();
      return lines.where((line) => 
        line.toLowerCase().contains(keyword.toLowerCase())
      ).toList();
    } catch (e) {
      print('Error searching logs: $e');
      return [];
    }
  }

  Future<List<String>> getLogsByLevel(LogLevel level) async {
    if (_logFile == null || !await _logFile!.exists()) {
      return [];
    }

    try {
      final lines = await _logFile!.readAsLines();
      return lines.where((line) => 
        line.contains('[${level.toString().toUpperCase()}]')
      ).toList();
    } catch (e) {
      print('Error getting logs by level: $e');
      return [];
    }
  }

  Future<List<String>> getLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_logFile == null || !await _logFile!.exists()) {
      return [];
    }

    try {
      final lines = await _logFile!.readAsLines();
      return lines.where((line) {
        try {
          final timestamp = _dateFormat.parse(line.split(']').first.substring(1));
          return timestamp.isAfter(startDate) && timestamp.isBefore(endDate);
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      print('Error getting logs by date range: $e');
      return [];
    }
  }
} 