import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';

enum SecurityLogLevel {
  info,
  warning,
  error,
  critical
}

class SecurityEvent {
  final String eventId;
  final String eventType;
  final SecurityLogLevel level;
  final String userId;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  SecurityEvent({
    required this.eventType,
    required this.level,
    required this.userId,
    required this.description,
    required this.metadata,
    required this.timestamp,
  }) : eventId = _generateEventId(timestamp, eventType, userId);

  static String _generateEventId(
    DateTime timestamp,
    String eventType,
    String userId,
  ) {
    final data = '${timestamp.toIso8601String()}_$eventType_$userId';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
}

class SecurityLogService {
  final List<SecurityEvent> _securityLogs = [];
  final _securityEventController = StreamController<SecurityEvent>.broadcast();
  final Map<String, int> _eventTypeCount = {};
  final Map<String, int> _userEventCount = {};
  final Map<SecurityLogLevel, int> _levelCount = {};

  Stream<SecurityEvent> get securityEventStream => _securityEventController.stream;

  // 记录安全事件
  Future<void> logSecurityEvent(
    String eventType,
    SecurityLogLevel level,
    String userId,
    String description, {
    Map<String, dynamic> metadata = const {},
  }) async {
    final event = SecurityEvent(
      eventType: eventType,
      level: level,
      userId: userId,
      description: description,
      metadata: metadata,
      timestamp: DateTime.now(),
    );

    _securityLogs.add(event);
    _securityEventController.add(event);

    // 更新统计数据
    _eventTypeCount.update(eventType, (count) => count + 1, ifAbsent: () => 1);
    _userEventCount.update(userId, (count) => count + 1, ifAbsent: () => 1);
    _levelCount.update(level, (count) => count + 1, ifAbsent: () => 1);

    // 如果是高危事件，触发实时告警
    if (level == SecurityLogLevel.critical) {
      await _triggerSecurityAlert(event);
    }

    // 持久化日志
    await _persistSecurityLog(event);
  }

  // 获取安全日志
  List<SecurityEvent> getSecurityLogs({
    String? eventType,
    SecurityLogLevel? level,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return _securityLogs.where((event) {
      if (eventType != null && event.eventType != eventType) return false;
      if (level != null && event.level != level) return false;
      if (userId != null && event.userId != userId) return false;
      if (startTime != null && event.timestamp.isBefore(startTime)) return false;
      if (endTime != null && event.timestamp.isAfter(endTime)) return false;
      return true;
    }).toList();
  }

  // 生成安全报告
  Future<String> generateSecurityReport({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final report = {
      'reportId': _generateReportId(),
      'generatedAt': DateTime.now().toIso8601String(),
      'period': {
        'start': startTime?.toIso8601String(),
        'end': endTime?.toIso8601String(),
      },
      'summary': {
        'totalEvents': _securityLogs.length,
        'eventsByType': _eventTypeCount,
        'eventsByUser': _userEventCount,
        'eventsByLevel': _levelCount,
      },
      'criticalEvents': _getCriticalEvents(startTime, endTime),
      'topUsers': _getTopUsers(),
      'topEventTypes': _getTopEventTypes(),
      'recommendations': _generateRecommendations(),
    };

    return jsonEncode(report);
  }

  // 分析安全趋势
  Map<String, dynamic> analyzeSecurityTrends({
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final trends = {
      'eventTrends': _analyzeEventTrends(startTime, endTime),
      'userTrends': _analyzeUserTrends(startTime, endTime),
      'severityTrends': _analyzeSeverityTrends(startTime, endTime),
      'anomalies': _detectAnomalies(startTime, endTime),
    };

    return trends;
  }

  // 检测异常活动
  List<SecurityEvent> detectAnomalousActivity({
    double threshold = 2.0,
    Duration window = const Duration(hours: 1),
  }) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    final recentEvents = _securityLogs
        .where((event) => event.timestamp.isAfter(windowStart))
        .toList();

    // 计算每个用户的事件频率
    final userFrequency = <String, int>{};
    for (final event in recentEvents) {
      userFrequency.update(
        event.userId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    // 计算平均频率和标准差
    final frequencies = userFrequency.values.toList();
    final avgFrequency = frequencies.reduce((a, b) => a + b) / frequencies.length;
    final variance = frequencies
        .map((f) => math.pow(f - avgFrequency, 2))
        .reduce((a, b) => a + b) / frequencies.length;
    final stdDev = math.sqrt(variance);

    // 识别异常用户
    final anomalousUsers = userFrequency.entries
        .where((entry) => (entry.value - avgFrequency) > threshold * stdDev)
        .map((entry) => entry.key)
        .toSet();

    // 返回异常用户的事件
    return recentEvents
        .where((event) => anomalousUsers.contains(event.userId))
        .toList();
  }

  // 导出安全日志
  Future<String> exportSecurityLogs({
    String? eventType,
    SecurityLogLevel? level,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String format = 'json',
  }) async {
    final logs = getSecurityLogs(
      eventType: eventType,
      level: level,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
    );

    switch (format.toLowerCase()) {
      case 'json':
        return _exportToJson(logs);
      case 'csv':
        return _exportToCsv(logs);
      default:
        throw ArgumentError('不支持的导出格式: $format');
    }
  }

  // 触发安全告警
  Future<void> _triggerSecurityAlert(SecurityEvent event) async {
    // 实现安全告警逻辑
  }

  // 持久化安全日志
  Future<void> _persistSecurityLog(SecurityEvent event) async {
    // 实现日志持久化逻辑
  }

  // 生成报告ID
  String _generateReportId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(10000);
    return 'SEC-REP-$timestamp-$random';
  }

  // 获取关键事件
  List<Map<String, dynamic>> _getCriticalEvents(
    DateTime? startTime,
    DateTime? endTime,
  ) {
    return getSecurityLogs(
      level: SecurityLogLevel.critical,
      startTime: startTime,
      endTime: endTime,
    ).map((event) => {
      'eventId': event.eventId,
      'eventType': event.eventType,
      'userId': event.userId,
      'description': event.description,
      'timestamp': event.timestamp.toIso8601String(),
      'metadata': event.metadata,
    }).toList();
  }

  // 获取最活跃用户
  List<Map<String, dynamic>> _getTopUsers() {
    return _userEventCount.entries
        .map((entry) => {
          'userId': entry.key,
          'eventCount': entry.value,
        })
        .toList()
      ..sort((a, b) => b['eventCount'].compareTo(a['eventCount']));
  }

  // 获取最常见事件类型
  List<Map<String, dynamic>> _getTopEventTypes() {
    return _eventTypeCount.entries
        .map((entry) => {
          'eventType': entry.key,
          'count': entry.value,
        })
        .toList()
      ..sort((a, b) => b['count'].compareTo(a['count']));
  }

  // 生成安全建议
  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    
    // 基于事件级别分布的建议
    if (_levelCount[SecurityLogLevel.critical] ?? 0 > 0) {
      recommendations.add('存在严重安全事件，建议立即审查系统安全策略');
    }
    
    // 基于用户行为的建议
    if (_detectAnomalies(null, null).isNotEmpty) {
      recommendations.add('检测到异常用户行为，建议加强用户行为监控');
    }
    
    // 基于事件类型的建议
    final failedLoginCount = _eventTypeCount['LOGIN_FAILED'] ?? 0;
    if (failedLoginCount > 100) {
      recommendations.add('登录失败次数过多，建议加强密码策略和访问控制');
    }

    return recommendations;
  }

  // 分析事件趋势
  Map<String, dynamic> _analyzeEventTrends(
    DateTime? startTime,
    DateTime? endTime,
  ) {
    // 实现事件趋势分析逻辑
    return {};
  }

  // 分析用户趋势
  Map<String, dynamic> _analyzeUserTrends(
    DateTime? startTime,
    DateTime? endTime,
  ) {
    // 实现用户趋势分析逻辑
    return {};
  }

  // 分析严重程度趋势
  Map<String, dynamic> _analyzeSeverityTrends(
    DateTime? startTime,
    DateTime? endTime,
  ) {
    // 实现严重程度趋势分析逻辑
    return {};
  }

  // 检测异常
  List<Map<String, dynamic>> _detectAnomalies(
    DateTime? startTime,
    DateTime? endTime,
  ) {
    // 实现异常检测逻辑
    return [];
  }

  // 导出为JSON格式
  String _exportToJson(List<SecurityEvent> logs) {
    final jsonLogs = logs.map((log) => {
      'eventId': log.eventId,
      'eventType': log.eventType,
      'level': log.level.toString(),
      'userId': log.userId,
      'description': log.description,
      'metadata': log.metadata,
      'timestamp': log.timestamp.toIso8601String(),
    }).toList();

    return jsonEncode(jsonLogs);
  }

  // 导出为CSV格式
  String _exportToCsv(List<SecurityEvent> logs) {
    final header = 'EventID,EventType,Level,UserID,Description,Timestamp\n';
    final rows = logs.map((log) =>
      '${log.eventId},${log.eventType},${log.level},${log.userId},'
      '"${log.description}",${log.timestamp.toIso8601String()}'
    ).join('\n');

    return header + rows;
  }

  // 销毁服务
  void dispose() {
    _securityEventController.close();
  }
} 