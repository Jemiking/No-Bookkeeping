import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';

enum AccessLevel {
  none,
  read,
  write,
  admin
}

class AccessRule {
  final String resourceId;
  final String userId;
  final AccessLevel level;
  final DateTime expiresAt;

  AccessRule({
    required this.resourceId,
    required this.userId,
    required this.level,
    required this.expiresAt,
  });
}

class AuditLog {
  final String userId;
  final String resourceId;
  final String action;
  final DateTime timestamp;
  final String details;

  AuditLog({
    required this.userId,
    required this.resourceId,
    required this.action,
    required this.timestamp,
    required this.details,
  });
}

class AccessControlService {
  final Map<String, List<AccessRule>> _accessRules = {};
  final List<AuditLog> _auditLogs = [];
  final _auditLogController = StreamController<AuditLog>.broadcast();

  Stream<AuditLog> get auditLogStream => _auditLogController.stream;

  // 检查访问权限
  Future<bool> checkAccess(
    String userId,
    String resourceId,
    AccessLevel requiredLevel,
  ) async {
    try {
      final rules = _accessRules[resourceId] ?? [];
      final userRules = rules.where((rule) => rule.userId == userId).toList();

      if (userRules.isEmpty) {
        await _logAccess(
          userId,
          resourceId,
          'ACCESS_DENIED',
          '无访问权限',
        );
        return false;
      }

      // 检查是否有任何有效的规则满足要求的访问级别
      final hasAccess = userRules.any((rule) =>
        rule.level.index >= requiredLevel.index &&
        rule.expiresAt.isAfter(DateTime.now())
      );

      await _logAccess(
        userId,
        resourceId,
        hasAccess ? 'ACCESS_GRANTED' : 'ACCESS_DENIED',
        '访问级别: ${requiredLevel.toString()}',
      );

      return hasAccess;
    } catch (e) {
      await _logAccess(
        userId,
        resourceId,
        'ACCESS_ERROR',
        '访问检查失败: $e',
      );
      return false;
    }
  }

  // 授予访问权限
  Future<void> grantAccess(
    String userId,
    String resourceId,
    AccessLevel level,
    Duration duration,
  ) async {
    try {
      final rule = AccessRule(
        resourceId: resourceId,
        userId: userId,
        level: level,
        expiresAt: DateTime.now().add(duration),
      );

      _accessRules.update(
        resourceId,
        (rules) => [...rules, rule],
        ifAbsent: () => [rule],
      );

      await _logAccess(
        userId,
        resourceId,
        'ACCESS_GRANTED',
        '授予访问权限: ${level.toString()}, 有效期: ${duration.inDays}天',
      );
    } catch (e) {
      await _logAccess(
        userId,
        resourceId,
        'GRANT_ERROR',
        '授权失败: $e',
      );
      rethrow;
    }
  }

  // 撤销访问权限
  Future<void> revokeAccess(
    String userId,
    String resourceId,
  ) async {
    try {
      final rules = _accessRules[resourceId] ?? [];
      rules.removeWhere((rule) => rule.userId == userId);

      await _logAccess(
        userId,
        resourceId,
        'ACCESS_REVOKED',
        '撤销访问权限',
      );
    } catch (e) {
      await _logAccess(
        userId,
        resourceId,
        'REVOKE_ERROR',
        '撤销权限失败: $e',
      );
      rethrow;
    }
  }

  // 修改访问权限
  Future<void> modifyAccess(
    String userId,
    String resourceId,
    AccessLevel newLevel,
    Duration? newDuration,
  ) async {
    try {
      final rules = _accessRules[resourceId] ?? [];
      final index = rules.indexWhere((rule) => rule.userId == userId);

      if (index == -1) {
        throw Exception('未找到访问规则');
      }

      final oldRule = rules[index];
      final newRule = AccessRule(
        resourceId: resourceId,
        userId: userId,
        level: newLevel,
        expiresAt: newDuration != null
            ? DateTime.now().add(newDuration)
            : oldRule.expiresAt,
      );

      rules[index] = newRule;

      await _logAccess(
        userId,
        resourceId,
        'ACCESS_MODIFIED',
        '修改访问权限: ${newLevel.toString()}',
      );
    } catch (e) {
      await _logAccess(
        userId,
        resourceId,
        'MODIFY_ERROR',
        '修改权限失败: $e',
      );
      rethrow;
    }
  }

  // 获取用户的所有访问权限
  List<AccessRule> getUserAccessRules(String userId) {
    final userRules = <AccessRule>[];
    
    for (final rules in _accessRules.values) {
      userRules.addAll(
        rules.where((rule) =>
          rule.userId == userId &&
          rule.expiresAt.isAfter(DateTime.now())
        ),
      );
    }
    
    return userRules;
  }

  // 获取资源的所有访问规则
  List<AccessRule> getResourceAccessRules(String resourceId) {
    return _accessRules[resourceId]
        ?.where((rule) => rule.expiresAt.isAfter(DateTime.now()))
        .toList() ??
        [];
  }

  // 清理过期的访问规则
  Future<void> cleanupExpiredRules() async {
    try {
      var totalRemoved = 0;
      
      _accessRules.forEach((resourceId, rules) {
        final initialCount = rules.length;
        rules.removeWhere((rule) => rule.expiresAt.isBefore(DateTime.now()));
        totalRemoved += initialCount - rules.length;
      });

      if (totalRemoved > 0) {
        await _logAccess(
          'SYSTEM',
          'ALL',
          'CLEANUP',
          '清理过期规则: $totalRemoved',
        );
      }
    } catch (e) {
      await _logAccess(
        'SYSTEM',
        'ALL',
        'CLEANUP_ERROR',
        '清理过期规则失败: $e',
      );
      rethrow;
    }
  }

  // 记录访问日志
  Future<void> _logAccess(
    String userId,
    String resourceId,
    String action,
    String details,
  ) async {
    final log = AuditLog(
      userId: userId,
      resourceId: resourceId,
      action: action,
      timestamp: DateTime.now(),
      details: details,
    );

    _auditLogs.add(log);
    _auditLogController.add(log);

    // 如果需要，可以将日志保存到持久存储
    await _persistAuditLog(log);
  }

  // 获取审计日志
  List<AuditLog> getAuditLogs({
    String? userId,
    String? resourceId,
    String? action,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return _auditLogs.where((log) {
      if (userId != null && log.userId != userId) return false;
      if (resourceId != null && log.resourceId != resourceId) return false;
      if (action != null && log.action != action) return false;
      if (startTime != null && log.timestamp.isBefore(startTime)) return false;
      if (endTime != null && log.timestamp.isAfter(endTime)) return false;
      return true;
    }).toList();
  }

  // 导出审计日志
  Future<String> exportAuditLogs({
    String? userId,
    String? resourceId,
    String? action,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final logs = getAuditLogs(
      userId: userId,
      resourceId: resourceId,
      action: action,
      startTime: startTime,
      endTime: endTime,
    );

    final jsonLogs = logs.map((log) => {
      'userId': log.userId,
      'resourceId': log.resourceId,
      'action': log.action,
      'timestamp': log.timestamp.toIso8601String(),
      'details': log.details,
    }).toList();

    return jsonEncode(jsonLogs);
  }

  // 持久化审计日志
  Future<void> _persistAuditLog(AuditLog log) async {
    // 实现将日志保存到持久存储的逻辑
  }

  // 销毁服务
  void dispose() {
    _auditLogController.close();
  }
} 