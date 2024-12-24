import 'package:flutter/material.dart';
import '../logging/app_logger.dart';
import 'app_error.dart';

/// 错误处理器
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  final AppLogger _logger = AppLogger();

  /// 获取单例实例
  factory ErrorHandler() {
    return _instance;
  }

  ErrorHandler._internal();

  /// 处理错误
  void handleError(
    BuildContext? context,
    dynamic error, {
    StackTrace? stackTrace,
    String? fallbackMessage,
  }) {
    // 转换为应用错误
    final appError = error is AppError
        ? error
        : AppError.fromException(error, stackTrace);

    // 记录错误日志
    _logger.logAppError(appError);

    // 显示错误提示
    if (context != null && context.mounted) {
      _showErrorSnackBar(context, appError);
    }
  }

  /// 显示错误提示
  void _showErrorSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: '关闭',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 处理异步操作
  Future<T> handleAsync<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    bool showLoading = true,
    bool showSuccess = false,
  }) async {
    if (showLoading) {
      _showLoadingDialog(context, loadingMessage);
    }

    try {
      final result = await operation();

      if (showLoading) {
        Navigator.of(context).pop();
      }

      if (showSuccess && successMessage != null) {
        _showSuccessSnackBar(context, successMessage);
      }

      return result;
    } catch (error, stackTrace) {
      if (showLoading) {
        Navigator.of(context).pop();
      }

      handleError(context, error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 显示加载对话框
  void _showLoadingDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16.0),
                  Text(message),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 显示成功提示
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// 处理确认操作
  Future<bool> handleConfirmation(
    BuildContext context,
    String title,
    String message, {
    String? confirmText,
    String? cancelText,
    bool dangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(cancelText ?? '取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                confirmText ?? '确认',
                style: dangerous
                    ? TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// 处理表单验证
  String? handleValidation(
    String? value,
    List<ValidationRule> rules,
  ) {
    if (rules.isEmpty) {
      return null;
    }

    for (final rule in rules) {
      final error = rule.validate(value);
      if (error != null) {
        return error;
      }
    }

    return null;
  }
}

/// 验证规则
class ValidationRule {
  final String message;
  final bool Function(String?) validator;

  ValidationRule({
    required this.message,
    required this.validator,
  });

  String? validate(String? value) {
    return validator(value) ? null : message;
  }

  /// 必填验证
  static ValidationRule required({
    String message = '此字段不能为空',
  }) {
    return ValidationRule(
      message: message,
      validator: (value) => value != null && value.isNotEmpty,
    );
  }

  /// 最小长度验证
  static ValidationRule minLength(
    int length, {
    String? message,
  }) {
    return ValidationRule(
      message: message ?? '长度不能小于 $length',
      validator: (value) =>
          value == null || value.isEmpty || value.length >= length,
    );
  }

  /// 最大长度验证
  static ValidationRule maxLength(
    int length, {
    String? message,
  }) {
    return ValidationRule(
      message: message ?? '长度不能大于 $length',
      validator: (value) =>
          value == null || value.isEmpty || value.length <= length,
    );
  }

  /// 正则表达式验证
  static ValidationRule pattern(
    RegExp pattern, {
    String? message,
  }) {
    return ValidationRule(
      message: message ?? '格式不正确',
      validator: (value) =>
          value == null || value.isEmpty || pattern.hasMatch(value),
    );
  }

  /// 邮箱验证
  static ValidationRule email({
    String message = '请输入有效的邮箱地址',
  }) {
    return pattern(
      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$'),
      message: message,
    );
  }

  /// 手机号验证
  static ValidationRule phone({
    String message = '请输入有效的手机号',
  }) {
    return pattern(
      RegExp(r'^1[3-9]\d{9}$'),
      message: message,
    );
  }

  /// 数字验证
  static ValidationRule numeric({
    String message = '请输入数字',
  }) {
    return pattern(
      RegExp(r'^\d+$'),
      message: message,
    );
  }

  /// 金额验证
  static ValidationRule amount({
    String message = '请输入有效的金额',
  }) {
    return pattern(
      RegExp(r'^\d+(\.\d{1,2})?$'),
      message: message,
    );
  }
} 