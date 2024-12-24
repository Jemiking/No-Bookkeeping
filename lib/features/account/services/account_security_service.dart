import '../../../core/security/security_validator.dart';
import '../../../core/security/security_logger.dart';
import '../../../core/security/security_exception_handler.dart';
import '../domain/account.dart';

class AccountSecurityService {
  static Future<bool> validateAccountDeletion(
    String accountId,
    String userId,
  ) async {
    try {
      // 验证账户操作权限
      if (!SecurityValidator.validateAccountOperation(accountId, 'DELETE')) {
        throw SecurityException(
          SecurityExceptionType.unauthorized,
          '无权删除该账户',
          details: {'accountId': accountId},
        );
      }

      // 记录安全事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'ACCOUNT_DELETION',
        userId: userId,
        operation: 'DELETE_ACCOUNT',
        details: {'accountId': accountId},
      );

      return true;
    } catch (e) {
      if (e is SecurityException) {
        await SecurityExceptionHandler.handleSecurityException(e, userId);
      }
      return false;
    }
  }

  static Future<bool> validateAccountModification(
    String accountId,
    String userId,
    Account oldAccount,
    Account newAccount,
  ) async {
    try {
      // 验证账户操作权限
      if (!SecurityValidator.validateAccountOperation(accountId, 'MODIFY')) {
        throw SecurityException(
          SecurityExceptionType.unauthorized,
          '无权修改该账户',
          details: {'accountId': accountId},
        );
      }

      // 验证余额变更
      if (!SecurityValidator.validateBalanceChange(
        oldAccount.balance,
        newAccount.balance,
      )) {
        throw SecurityException(
          SecurityExceptionType.suspiciousActivity,
          '账户余额变更异常',
          details: {
            'accountId': accountId,
            'oldBalance': oldAccount.balance,
            'newBalance': newAccount.balance,
          },
        );
      }

      // 记录安全事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'ACCOUNT_MODIFICATION',
        userId: userId,
        operation: 'MODIFY_ACCOUNT',
        details: {
          'accountId': accountId,
          'changes': {
            'balance': {
              'old': oldAccount.balance,
              'new': newAccount.balance,
            },
            'status': {
              'old': oldAccount.status,
              'new': newAccount.status,
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

  static Future<bool> validateAccountArchival(
    String accountId,
    String userId,
  ) async {
    try {
      // 验证账户操作权限
      if (!SecurityValidator.validateAccountOperation(accountId, 'ARCHIVE')) {
        throw SecurityException(
          SecurityExceptionType.unauthorized,
          '无权归档该账户',
          details: {'accountId': accountId},
        );
      }

      // 记录安全事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'ACCOUNT_ARCHIVAL',
        userId: userId,
        operation: 'ARCHIVE_ACCOUNT',
        details: {'accountId': accountId},
      );

      return true;
    } catch (e) {
      if (e is SecurityException) {
        await SecurityExceptionHandler.handleSecurityException(e, userId);
      }
      return false;
    }
  }

  static Future<bool> validateSensitiveOperation(
    String accountId,
    String userId,
    String operationType,
    SecurityLevel requiredLevel,
  ) async {
    try {
      // 验证敏感操作
      if (!SecurityValidator.validateSensitiveOperation(
        operationType,
        requiredLevel,
      )) {
        throw SecurityException(
          SecurityExceptionType.invalidOperation,
          '无效的敏感操作',
          details: {
            'accountId': accountId,
            'operationType': operationType,
            'requiredLevel': requiredLevel,
          },
        );
      }

      // 记录安全事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'SENSITIVE_OPERATION',
        userId: userId,
        operation: operationType,
        details: {
          'accountId': accountId,
          'securityLevel': requiredLevel.toString(),
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