import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../error/app_error.dart';

/// 日志上报服务
class LogReporter {
  static final LogReporter _instance = LogReporter._internal();
  static const String _apiEndpoint = 'https://api.example.com/logs';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  bool _initialized = false;
  late String _deviceId;
  late String _appVersion;
  late String _osVersion;
  late Directory _cacheDirectory;
  final List<Map<String, dynamic>> _pendingLogs = [];

  /// 获取单例实例
  factory LogReporter() {
    return _instance;
  }

  LogReporter._internal();

  /// 初始化日志上报服务
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      // 获取设备信息
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
        _osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor ?? 'unknown';
        _osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      } else {
        _deviceId = 'unknown';
        _osVersion = Platform.operatingSystem;
      }

      // 获取应用信息
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      // 获取缓存目录
      _cacheDirectory = await getTemporaryDirectory();

      // 加载未上报的日志
      await _loadPendingLogs();

      _initialized = true;
    } catch (e) {
      print('初始化日志上报服务失败：$e');
    }
  }

  /// 上报日志
  Future<void> report(
    String level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (!_initialized) {
      print('日志上报服务未初始化');
      return;
    }

    final log = _buildLogData(
      level,
      message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );

    try {
      await _sendLog(log);
    } catch (e) {
      print('上报日志失败：$e');
      await _cachePendingLog(log);
    }
  }

  /// 上报应用错误
  Future<void> reportError(AppError error) async {
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

    await report(
      'error',
      error.message,
      data: data,
      error: error.originalError,
      stackTrace: error.stackTrace,
    );
  }

  /// 构建日志数据
  Map<String, dynamic> _buildLogData(
    String level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level,
      'message': message,
      'deviceId': _deviceId,
      'appVersion': _appVersion,
      'osVersion': _osVersion,
      if (data != null) 'data': data,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  /// 发送日志
  Future<void> _sendLog(Map<String, dynamic> log) async {
    int retries = 0;
    while (retries < _maxRetries) {
      try {
        final response = await http.post(
          Uri.parse(_apiEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(log),
        );

        if (response.statusCode == 200) {
          return;
        }

        throw Exception('上报日志失败：${response.statusCode}');
      } catch (e) {
        retries++;
        if (retries < _maxRetries) {
          await Future.delayed(_retryDelay * retries);
        } else {
          rethrow;
        }
      }
    }
  }

  /// 缓存未上报的日志
  Future<void> _cachePendingLog(Map<String, dynamic> log) async {
    _pendingLogs.add(log);
    await _savePendingLogs();
  }

  /// 加载未上报的日志
  Future<void> _loadPendingLogs() async {
    try {
      final file = File('${_cacheDirectory.path}/pending_logs.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> logs = jsonDecode(content);
        _pendingLogs.addAll(
          logs.map((log) => log as Map<String, dynamic>),
        );
      }
    } catch (e) {
      print('加载未上报的日志失败：$e');
    }
  }

  /// 保存未上报的���志
  Future<void> _savePendingLogs() async {
    try {
      final file = File('${_cacheDirectory.path}/pending_logs.json');
      await file.writeAsString(jsonEncode(_pendingLogs));
    } catch (e) {
      print('保存未上报的日志失败：$e');
    }
  }

  /// 重试上报未发送的日志
  Future<void> retryPendingLogs() async {
    if (!_initialized || _pendingLogs.isEmpty) {
      return;
    }

    final logs = List<Map<String, dynamic>>.from(_pendingLogs);
    _pendingLogs.clear();
    await _savePendingLogs();

    for (final log in logs) {
      try {
        await _sendLog(log);
      } catch (e) {
        await _cachePendingLog(log);
      }
    }
  }

  /// 清理过期的日志
  Future<void> cleanupExpiredLogs() async {
    if (!_initialized) {
      return;
    }

    final now = DateTime.now();
    _pendingLogs.removeWhere((log) {
      final timestamp = DateTime.parse(log['timestamp'] as String);
      return now.difference(timestamp) > const Duration(days: 7);
    });

    await _savePendingLogs();
  }
} 