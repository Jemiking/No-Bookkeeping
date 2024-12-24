import '../../../core/security/security_validator.dart';
import '../../../core/security/security_logger.dart';
import '../../../core/security/security_exception_handler.dart';
import '../models/transaction.dart';

class TransactionSecurityService {
  static Future<bool> validateTransactionCreation(
    Transaction transaction,
    String userId,
    double averageAmount,
  ) async {
    try {
      // 验证大额交易
      if (!SecurityValidator.validateLargeAmount(transaction.amount)) {
        throw SecurityException(
          SecurityExceptionType.limitExceeded,
          '交易金额超过限制',
          details: {'amount': transaction.amount},
        );
      }

      // 验证异常交易
      if (!SecurityValidator.validateUnusualTransaction(
        transaction.amount,
        averageAmount,
      )) {
        throw SecurityException(
          SecurityExceptionType.suspiciousActivity,
          '交易金额异常',
          details: {
            'amount': transaction.amount,
            'averageAmount': averageAmount,
          },
        );
      }

      // 记录安全事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'TRANSACTION_CREATION',
        userId: userId,
        operation: 'CREATE_TRANSACTION',
        details: {
          'transactionType': transaction.type.toString(),
          'amount': transaction.amount,
          'accountId': transaction.accountId,
        },
      );

      return true;
    } catch (e) {
      if (e is SecurityException) {
        await SecurityExceptionHandler.handleSecurityException(e, userId);
      }
      return false;
    }
  }

  static Future<bool> validateTransactionModification(
    String transactionId,
    String userId,
    Transaction oldTransaction,
    Transaction newTransaction,
  ) async {
    try {
      // 验证交易操作权限
      if (!SecurityValidator.validateTransactionOperation(
        transactionId,
        'MODIFY',
      )) {
        throw SecurityException(
          SecurityExceptionType.unauthorized,
          '无权修改该交易',
          details: {'transactionId': transactionId},
        );
      }

      // 验证金额变更
      if (oldTransaction.amount != newTransaction.amount) {
        if (!SecurityValidator.validateLargeAmount(newTransaction.amount)) {
          throw SecurityException(
            SecurityExceptionType.limitExceeded,
            '修改后的交易金额超过限制',
            details: {
              'oldAmount': oldTransaction.amount,
              'newAmount': newTransaction.amount,
            },
          );
        }
      }

      // 记录安全事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'TRANSACTION_MODIFICATION',
        userId: userId,
        operation: 'MODIFY_TRANSACTION',
        details: {
          'transactionId': transactionId,
          'changes': {
            'amount': {
              'old': oldTransaction.amount,
              'new': newTransaction.amount,
            },
            'type': {
              'old': oldTransaction.type.toString(),
              'new': newTransaction.type.toString(),
            },
          },
        },
      );

      return true;
    } catch (e) {
      if (e is SecurityException) {
        await SecurityExceptionHandler.handleSecurityException(e, userId);
      }
      return false;
    }
  }

  static Future<bool> validateTransactionDeletion(
    String transactionId,
    String userId,
    Transaction transaction,
  ) async {
    try {
      // 验证交易操作权限
      if (!SecurityValidator.validateTransactionOperation(
        transactionId,
        'DELETE',
      )) {
        throw SecurityException(
          SecurityExceptionType.unauthorized,
          '无权删除该交易',
          details: {'transactionId': transactionId},
        );
      }

      // 记录安全事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'TRANSACTION_DELETION',
        userId: userId,
        operation: 'DELETE_TRANSACTION',
        details: {
          'transactionId': transactionId,
          'amount': transaction.amount,
          'type': transaction.type.toString(),
        },
      );

      return true;
    } catch (e) {
      if (e is SecurityException) {
        await SecurityExceptionHandler.handleSecurityException(e, userId);
      }
      return false;
    }
  }

  static Future<bool> validateDailyTransactionLimit(
    String userId,
    int dailyCount,
  ) async {
    try {
      // 验证日交易频率
      if (!SecurityValidator.validateDailyTransactionLimit(dailyCount)) {
        throw SecurityException(
          SecurityExceptionType.limitExceeded,
          '超出每日交易次数限制',
          details: {'dailyCount': dailyCount},
        );
      }

      // 记录安全事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'DAILY_TRANSACTION_CHECK',
        userId: userId,
        operation: 'CHECK_DAILY_LIMIT',
        details: {'dailyCount': dailyCount},
      );

      return true;
    } catch (e) {
      if (e is SecurityException) {
        await SecurityExceptionHandler.handleSecurityException(e, userId);
      }
      return false;
    }
  }

  static Future<bool> validateBatchOperation(
    String userId,
    String operationType,
    List<String> transactionIds,
  ) async {
    try {
      // 验证批量操作权限
      if (!SecurityValidator.validateSensitiveOperation(
        operationType,
        SecurityLevel.high,
      )) {
        throw SecurityException(
          SecurityExceptionType.unauthorized,
          '无权执行批量操作',
          details: {
            'operationType': operationType,
            'transactionCount': transactionIds.length,
          },
        );
      }

      // 记录安全事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'BATCH_OPERATION',
        userId: userId,
        operation: operationType,
        details: {
          'transactionIds': transactionIds,
          'count': transactionIds.length,
        },
      );

      return true;
    } catch (e) {
      if (e is SecurityException) {
        await SecurityExceptionHandler.handleSecurityException(e, userId);
      }
      return false;
    }
  }
} 