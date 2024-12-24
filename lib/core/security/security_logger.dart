import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SecurityLogger {
  static const String LOG_FILE_NAME = 'security_log.json';
  
  // 记录安全事件
  static Future<void> logSecurityEvent({
    required String eventType,
    required String userId,
    required String operation,
    Map<String, dynamic>? details,
  }) async {
    try {
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'eventType': eventType,
        'userId': userId,
        'operation': operation,
        'details': details,
        'deviceInfo': await _getDeviceInfo(),
      };

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$LOG_FILE_NAME');
      
      List<Map<String, dynamic>> logs = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          logs = List<Map<String, dynamic>>.from(jsonDecode(content));
        }
      }
      
      logs.add(logEntry);
      await file.writeAsString(jsonEncode(logs));
      
    } catch (e) {
      debugPrint('Security logging failed: $e');
    }
  }

  // 获取安全日志
  static Future<List<Map<String, dynamic>>> getSecurityLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$LOG_FILE_NAME');
      
      if (!await file.exists()) {
        return [];
      }
      
      final content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }
      
      return List<Map<String, dynamic>>.from(jsonDecode(content));
    } catch (e) {
      debugPrint('Failed to read security logs: $e');
      return [];
    }
  }

  // 清理过期日志
  static Future<void> cleanupOldLogs(int daysToKeep) async {
    try {
      final logs = await getSecurityLogs();
      final threshold = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final filteredLogs = logs.where((log) {
        final timestamp = DateTime.parse(log['timestamp']);
        return timestamp.isAfter(threshold);
      }).toList();
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$LOG_FILE_NAME');
      await file.writeAsString(jsonEncode(filteredLogs));
      
    } catch (e) {
      debugPrint('Failed to cleanup old logs: $e');
    }
  }

  // 获取设备信息
  static Future<Map<String, String>> _getDeviceInfo() async {
    return {
      'platform': defaultTargetPlatform.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
} 