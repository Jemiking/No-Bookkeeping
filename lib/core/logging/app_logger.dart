import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../error/app_error.dart';

/// 日志级别
enum LogLevel {
  /// 调试
  debug,

  /// 信息
  info,

  /// 警告
  warning,

  /// 错误
  error,
}

/// 应用日志记录器
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late Logger _logger;
  late File _logFile;
  bool _initialized = false;

  /// 获取单例实例
  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  /// 初始化日志记录器
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final logDirectory = Directory('${directory.path}/logs');
    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true);
    }

    _logFile = File('${logDirectory.path}/app.log');
    if (!await _logFile.exists()) {
      await _logFile.create();
    }

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: _logFile),
      ]),
    );

    _initialized = true;
  }

  /// 记录日志
  void log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (!_initialized) {
      print('Logger not initialized');
      return;
    }

    final logMessage = _buildLogMessage(message, data);

    switch (level) {
      case LogLevel.debug:
        _logger.d(logMessage, error, stackTrace);
        break;
      case LogLevel.info:
        _logger.i(logMessage, error, stackTrace);
        break;
      case LogLevel.warning:
        _logger.w(logMessage, error, stackTrace);
        break;
      case LogLevel.error:
        _logger.e(logMessage, error, stackTrace);
        break;
    }
  }

  /// 记录调试日志
  void debug(
    String message, {
    Map<String, dynamic>? data,
  }) {
    log(LogLevel.debug, message, data: data);
  }

  /// 记录信息日志
  void info(
    String message, {
    Map<String, dynamic>? data,
  }) {
    log(LogLevel.info, message, data: data);
  }

  /// 记录警告日志
  void warning(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.warning,
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// 记录错误日志
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// 记录应用错误
  void logAppError(AppError error) {
    final data = <String, dynamic>{
      'type': error.type.toString(),
      if (error is BusinessError) 'code': error.code,
      if (error is DatabaseError) ...{
        'operation': error.operation,
        'table': error.table,
      },
      if (error is AuthenticationError) 'code': error.code,
      if (error is PermissionError) 'permission': error.permission,
      if (error is NetworkError) 'statusCode': error.statusCode,
    };

    log(
      LogLevel.error,
      error.message,
      error: error.originalError,
      stackTrace: error.stackTrace,
      data: data,
    );
  }

  /// 构建日志消息
  String _buildLogMessage(String message, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return message;
    }

    final buffer = StringBuffer(message);
    buffer.write(' | ');
    buffer.write(data.entries.map((e) => '${e.key}: ${e.value}').join(', '));
    return buffer.toString();
  }
}

/// 文件输出
class FileOutput extends LogOutput {
  final File file;
  final bool overrideExisting;
  final Encoding encoding;

  FileOutput({
    required this.file,
    this.overrideExisting = false,
    this.encoding = utf8,
  });

  @override
  void output(OutputEvent event) {
    final output = event.lines.join('\n');
    if (overrideExisting) {
      file.writeAsStringSync('$output\n', encoding: encoding);
    } else {
      file.writeAsStringSync('$output\n', encoding: encoding, mode: FileMode.append);
    }
  }
}

/// 多输出
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultiOutput(this.outputs);

  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      output.output(event);
    }
  }
} 