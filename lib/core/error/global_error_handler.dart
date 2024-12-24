import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../logging/app_logger.dart';
import 'app_error.dart';
import 'error_handler.dart';

/// 全局错误处理器
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  final AppLogger _logger = AppLogger();
  final ErrorHandler _errorHandler = ErrorHandler();

  /// 获取单例实例
  factory GlobalErrorHandler() {
    return _instance;
  }

  GlobalErrorHandler._internal();

  /// 初始化错误处理器
  void init() {
    // 捕获 Flutter 框架错误
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _handleFlutterError(details);
    };

    // 捕获未处理的异步错误
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };

    // 捕获 Zone 中的错误
    runZonedGuarded(
      () {
        // 应用入口点
      },
      (error, stackTrace) {
        _handleZoneError(error, stackTrace);
      },
    );

    // 捕获 Isolate 错误
    Isolate.current.addErrorListener(RawReceivePort((pair) {
      final List<dynamic> errorAndStacktrace = pair;
      _handleIsolateError(errorAndStacktrace[0], errorAndStacktrace[1]);
    }).sendPort);
  }

  /// 处理 Flutter 框架错误
  void _handleFlutterError(FlutterErrorDetails details) {
    final error = AppError(
      type: AppErrorType.unknown,
      message: details.exceptionAsString(),
      originalError: details.exception,
      stackTrace: details.stack,
    );

    _logger.logAppError(error);
  }

  /// 处理平台错误
  void _handlePlatformError(Object error, StackTrace stackTrace) {
    final appError = AppError.fromException(error, stackTrace);
    _logger.logAppError(appError);
  }

  /// 处理 Zone 错误
  void _handleZoneError(Object error, StackTrace stackTrace) {
    final appError = AppError.fromException(error, stackTrace);
    _logger.logAppError(appError);
  }

  /// 处理 Isolate 错误
  void _handleIsolateError(Object error, StackTrace stackTrace) {
    final appError = AppError.fromException(error, stackTrace);
    _logger.logAppError(appError);
  }

  /// 处理未捕获的错误
  void handleUncaughtError(
    BuildContext? context,
    Object error,
    StackTrace stackTrace,
  ) {
    final appError = AppError.fromException(error, stackTrace);
    _logger.logAppError(appError);

    if (context != null && context.mounted) {
      _errorHandler.handleError(context, appError);
    }
  }

  /// 显示错误页面
  Widget buildErrorScreen(Object error, StackTrace? stackTrace) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64.0,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  '应用程序发生错误',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 重启应用
                  },
                  child: const Text('重新启动'),
                ),
                if (kDebugMode && stackTrace != null) ...[
                  const SizedBox(height: 16.0),
                  const Text(
                    '调试信息',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        stackTrace.toString(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 