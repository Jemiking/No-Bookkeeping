import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志工具类
class Logger {
  static const String LOG_FOLDER = 'logs';
  static const int MAX_LOG_FILES = 7; // 保留最近7天的日志
  static const int MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

  final String _tag;
  late final Directory _logDir;
  late final File _currentLogFile;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  
  bool _initialized = false;

  /// 构造函数
  Logger(this._tag);

  /// 初始化日志系统
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 创建日志目录
      final appDir = await getApplicationDocumentsDirectory();
      _logDir = Directory('${appDir.path}/$LOG_FOLDER');
      if (!await _logDir.exists()) {
        await _logDir.create(recursive: true);
      }

      // 创建当前日志文件
      final today = DateTime.now();
      final fileName = 'log_${today.year}-${today.month}-${today.day}.txt';
      _currentLogFile = File('${_logDir.path}/$fileName');
      if (!await _currentLogFile.exists()) {
        await _currentLogFile.create();
      }

      // 清理旧日志文件
      await _cleanOldLogs();

      _initialized = true;
    } catch (e) {
      print('初始化日志系统失败：$e');
    }
  }

  /// 记录调试级别日志
  Future<void> debug(String message) async {
    await _log(LogLevel.debug, message);
  }

  /// 记录信息级别日志
  Future<void> info(String message) async {
    await _log(LogLevel.info, message);
  }

  /// 记录警告级别日志
  Future<void> warning(String message) async {
    await _log(LogLevel.warning, message);
  }

  /// 记录错误级别日志
  Future<void> error(String message, [dynamic error, StackTrace? stackTrace]) async {
    String fullMessage = message;
    if (error != null) {
      fullMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      fullMessage += '\nStackTrace:\n$stackTrace';
    }
    await _log(LogLevel.error, fullMessage);
  }

  /// 获取日志文件列表
  Future<List<File>> getLogFiles() async {
    if (!_initialized) await initialize();

    final files = await _logDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.txt'))
        .map((entity) => entity as File)
        .toList();

    return files..sort((a, b) => b.path.compareTo(a.path));
  }

  /// 清理所有日志
  Future<void> clearAllLogs() async {
    if (!_initialized) await initialize();

    final files = await getLogFiles();
    for (var file in files) {
      await file.delete();
    }
  }

  /// 获取指定日期的日志内容
  Future<String> getLogContent(DateTime date) async {
    if (!_initialized) await initialize();

    final fileName = 'log_${date.year}-${date.month}-${date.day}.txt';
    final file = File('${_logDir.path}/$fileName');
    
    if (await file.exists()) {
      return await file.readAsString();
    }
    
    return '';
  }

  // 私有辅助方法

  /// 记录日志
  Future<void> _log(LogLevel level, String message) async {
    if (!_initialized) await initialize();

    try {
      // 检查文件大小
      if (await _currentLogFile.length() > MAX_FILE_SIZE) {
        await _rotateLogFile();
      }

      // 格式化日志消息
      final timestamp = _dateFormat.format(DateTime.now());
      final logMessage = '$timestamp [$level] $_tag: $message\n';

      // 写入日志文件
      await _currentLogFile.writeAsString(
        logMessage,
        mode: FileMode.append,
        flush: true,
      );

      // 在调试模式下同时输出到控制台
      assert(() {
        print(logMessage);
        return true;
      }());
    } catch (e) {
      print('写入日志失败：$e');
    }
  }

  /// 清理旧日志文件
  Future<void> _cleanOldLogs() async {
    try {
      final files = await getLogFiles();
      if (files.length > MAX_LOG_FILES) {
        final filesToDelete = files.sublist(MAX_LOG_FILES);
        for (var file in filesToDelete) {
          await file.delete();
        }
      }
    } catch (e) {
      print('清理旧日志文件失败：$e');
    }
  }

  /// 轮换日志文件
  Future<void> _rotateLogFile() async {
    try {
      final now = DateTime.now();
      final newFileName = 'log_${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}.txt';
      final newFile = File('${_logDir.path}/$newFileName');
      
      // 重命名当前日志文件
      await _currentLogFile.rename(newFile.path);
      
      // 创建新的日志文件
      _currentLogFile = File('${_logDir.path}/log_${now.year}-${now.month}-${now.day}.txt');
      await _currentLogFile.create();
      
      // 清理旧日志文件
      await _cleanOldLogs();
    } catch (e) {
      print('轮换日志文件失败：$e');
    }
  }
} 