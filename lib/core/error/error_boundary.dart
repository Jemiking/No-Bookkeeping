import 'package:flutter/material.dart';
import '../logging/app_logger.dart';
import 'app_error.dart';
import 'error_handler.dart';

/// 错误边界组件
class ErrorBoundary extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 错误回调
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// 错误组件构建器
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;

  /// 构造函数
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.onError,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  final AppLogger _logger = AppLogger();
  final ErrorHandler _errorHandler = ErrorHandler();
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _error = null;
    _stackTrace = null;
  }

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child) {
      _error = null;
      _stackTrace = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      final error = _error!;
      final stackTrace = _stackTrace!;

      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(error, stackTrace);
      }

      return _buildErrorWidget(error, stackTrace);
    }

    return ErrorWidget.builder = (details) {
      _handleError(details.exception, details.stack ?? StackTrace.empty);
      return _buildErrorWidget(details.exception, details.stack);
    };
  }

  /// 处理错误
  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });

    final appError = AppError.fromException(error, stackTrace);
    _logger.logAppError(appError);
    _errorHandler.handleError(context, appError);

    widget.onError?.call(error, stackTrace);
  }

  /// 构建错误组件
  Widget _buildErrorWidget(Object error, StackTrace? stackTrace) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48.0,
          ),
          const SizedBox(height: 16.0),
          const Text(
            '组件发生错误',
            style: TextStyle(
              fontSize: 18.0,
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
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

/// 错误边界构建器
class ErrorBoundaryBuilder extends StatelessWidget {
  /// 子组件构建器
  final Widget Function(BuildContext context) builder;

  /// 错误回调
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// 错误组件构建器
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;

  /// 构造函数
  const ErrorBoundaryBuilder({
    Key? key,
    required this.builder,
    this.onError,
    this.errorBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: onError,
      errorBuilder: errorBuilder,
      child: Builder(
        builder: builder,
      ),
    );
  }
}

/// 错误边界路由
class ErrorBoundaryRoute<T> extends MaterialPageRoute<T> {
  /// 错误回调
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// 错误组件构建器
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;

  /// 构造函数
  ErrorBoundaryRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    this.onError,
    this.errorBuilder,
  }) : super(
          builder: (context) => ErrorBoundary(
            onError: onError,
            errorBuilder: errorBuilder,
            child: Builder(
              builder: builder,
            ),
          ),
          settings: settings,
        );
}

/// 错误边界页面
class ErrorBoundaryPage extends Page {
  /// 子组件构建器
  final WidgetBuilder builder;

  /// 错误回调
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// 错误组件构建器
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;

  /// 构造函数
  const ErrorBoundaryPage({
    required this.builder,
    this.onError,
    this.errorBuilder,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  @override
  Route createRoute(BuildContext context) {
    return ErrorBoundaryRoute(
      builder: builder,
      settings: this,
      onError: onError,
      errorBuilder: errorBuilder,
    );
  }
} 