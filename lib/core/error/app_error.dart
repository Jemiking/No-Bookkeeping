/// 应用错误类型
enum AppErrorType {
  /// 网络错误
  network,

  /// 数据库错误
  database,

  /// 认证错误
  authentication,

  /// 权限错误
  permission,

  /// 业务逻辑错误
  business,

  /// 未知错误
  unknown,
}

/// 应用错误类
class AppError implements Exception {
  /// 错误类型
  final AppErrorType type;

  /// 错误消息
  final String message;

  /// 原始错误
  final dynamic originalError;

  /// 堆栈跟踪
  final StackTrace? stackTrace;

  /// 构造函数
  AppError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  /// 从异常创建应用错误
  factory AppError.fromException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    String message = error.toString();
    AppErrorType type = AppErrorType.unknown;

    if (error is Exception) {
      if (error.toString().contains('SocketException') ||
          error.toString().contains('TimeoutException')) {
        type = AppErrorType.network;
        message = '网络连接失败，请��查网络设置';
      } else if (error.toString().contains('DatabaseException')) {
        type = AppErrorType.database;
        message = '数据库操作失败';
      } else if (error.toString().contains('AuthException')) {
        type = AppErrorType.authentication;
        message = '认证失败，请重新登录';
      } else if (error.toString().contains('PermissionException')) {
        type = AppErrorType.permission;
        message = '权限不足，请联系管理员';
      }
    }

    return AppError(
      type: type,
      message: message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    return 'AppError{type: $type, message: $message, originalError: $originalError}';
  }
}

/// 业务错误类
class BusinessError extends AppError {
  /// 错误代码
  final String code;

  /// 构造函数
  BusinessError({
    required this.code,
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          type: AppErrorType.business,
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    return 'BusinessError{code: $code, message: $message}';
  }
}

/// 数据库错误类
class DatabaseError extends AppError {
  /// 数据库操作类型
  final String operation;

  /// 表名
  final String table;

  /// 构造函数
  DatabaseError({
    required this.operation,
    required this.table,
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          type: AppErrorType.database,
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    return 'DatabaseError{operation: $operation, table: $table, message: $message}';
  }
}

/// 认证错误类
class AuthenticationError extends AppError {
  /// 错误代码
  final String code;

  /// 构造函数
  AuthenticationError({
    required this.code,
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          type: AppErrorType.authentication,
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    return 'AuthenticationError{code: $code, message: $message}';
  }
}

/// 权限错误类
class PermissionError extends AppError {
  /// 权限类型
  final String permission;

  /// 构造函数
  PermissionError({
    required this.permission,
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          type: AppErrorType.permission,
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    return 'PermissionError{permission: $permission, message: $message}';
  }
}

/// 网络错误类
class NetworkError extends AppError {
  /// 状态码
  final int? statusCode;

  /// 构造函数
  NetworkError({
    required String message,
    this.statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          type: AppErrorType.network,
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    return 'NetworkError{statusCode: $statusCode, message: $message}';
  }
} 