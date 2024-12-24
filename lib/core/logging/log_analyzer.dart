import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 日志分析服务
class LogAnalyzer {
  static final LogAnalyzer _instance = LogAnalyzer._internal();
  late Directory _logDirectory;
  bool _initialized = false;

  /// 获取单例实例
  factory LogAnalyzer() {
    return _instance;
  }

  LogAnalyzer._internal();

  /// 初始化日志分析服务
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      _logDirectory = Directory('${directory.path}/logs');
      if (!await _logDirectory.exists()) {
        await _logDirectory.create(recursive: true);
      }

      _initialized = true;
    } catch (e) {
      print('初始化日志分析服务失败：$e');
    }
  }

  /// 分析错误日志
  Future<ErrorAnalysisResult> analyzeErrors({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!_initialized) {
      throw Exception('日志分析服务未初始化');
    }

    final logs = await _readLogs(
      level: 'error',
      startTime: startTime,
      endTime: endTime,
    );

    final result = ErrorAnalysisResult();
    for (final log in logs) {
      final type = log['data']?['type'] as String? ?? 'unknown';
      result.errorCount++;
      result.errorTypeCount[type] = (result.errorTypeCount[type] ?? 0) + 1;

      if (log['data']?['code'] != null) {
        final code = log['data']!['code'] as String;
        result.errorCodeCount[code] = (result.errorCodeCount[code] ?? 0) + 1;
      }
    }

    return result;
  }

  /// 分析性能日志
  Future<PerformanceAnalysisResult> analyzePerformance({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!_initialized) {
      throw Exception('日志分析服务未初始化');
    }

    final logs = await _readLogs(
      level: 'performance',
      startTime: startTime,
      endTime: endTime,
    );

    final result = PerformanceAnalysisResult();
    for (final log in logs) {
      final operation = log['data']?['operation'] as String? ?? 'unknown';
      final duration = log['data']?['duration'] as int? ?? 0;

      if (!result.operationStats.containsKey(operation)) {
        result.operationStats[operation] = OperationStats();
      }

      final stats = result.operationStats[operation]!;
      stats.count++;
      stats.totalDuration += duration;
      stats.minDuration = stats.minDuration == 0
          ? duration
          : duration < stats.minDuration
              ? duration
              : stats.minDuration;
      stats.maxDuration = duration > stats.maxDuration
          ? duration
          : stats.maxDuration;
    }

    // 计算平均值
    for (final stats in result.operationStats.values) {
      stats.avgDuration = stats.totalDuration ~/ stats.count;
    }

    return result;
  }

  /// 分析用户行为日志
  Future<UserBehaviorAnalysisResult> analyzeUserBehavior({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!_initialized) {
      throw Exception('日志分析服务未初始化');
    }

    final logs = await _readLogs(
      level: 'behavior',
      startTime: startTime,
      endTime: endTime,
    );

    final result = UserBehaviorAnalysisResult();
    for (final log in logs) {
      final action = log['data']?['action'] as String? ?? 'unknown';
      final screen = log['data']?['screen'] as String? ?? 'unknown';
      final duration = log['data']?['duration'] as int? ?? 0;

      result.actionCount[action] = (result.actionCount[action] ?? 0) + 1;
      result.screenCount[screen] = (result.screenCount[screen] ?? 0) + 1;
      result.totalDuration += duration;
    }

    return result;
  }

  /// 读取日志文件
  Future<List<Map<String, dynamic>>> _readLogs({
    String? level,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final logs = <Map<String, dynamic>>[];
    final files = await _logDirectory.list().toList();

    for (final file in files) {
      if (file is File && file.path.endsWith('.log')) {
        final content = await file.readAsString();
        final lines = content.split('\n');

        for (final line in lines) {
          if (line.isEmpty) {
            continue;
          }

          try {
            final log = jsonDecode(line) as Map<String, dynamic>;
            final timestamp = DateTime.parse(log['timestamp'] as String);

            if (level != null && log['level'] != level) {
              continue;
            }

            if (startTime != null && timestamp.isBefore(startTime)) {
              continue;
            }

            if (endTime != null && timestamp.isAfter(endTime)) {
              continue;
            }

            logs.add(log);
          } catch (e) {
            print('解析日志失败：$e');
          }
        }
      }
    }

    return logs;
  }

  /// 生成分析报告
  Future<void> generateReport({
    DateTime? startTime,
    DateTime? endTime,
    String? outputPath,
  }) async {
    if (!_initialized) {
      throw Exception('日志分析服务���初始化');
    }

    final errorResult = await analyzeErrors(
      startTime: startTime,
      endTime: endTime,
    );

    final performanceResult = await analyzePerformance(
      startTime: startTime,
      endTime: endTime,
    );

    final behaviorResult = await analyzeUserBehavior(
      startTime: startTime,
      endTime: endTime,
    );

    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'period': {
        'start': startTime?.toIso8601String(),
        'end': endTime?.toIso8601String(),
      },
      'error': errorResult.toJson(),
      'performance': performanceResult.toJson(),
      'behavior': behaviorResult.toJson(),
    };

    final path = outputPath ??
        '${_logDirectory.path}/report_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(path);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(report),
    );
  }
}

/// 错误分析结果
class ErrorAnalysisResult {
  /// 错误总数
  int errorCount = 0;

  /// 错误类型统计
  final Map<String, int> errorTypeCount = {};

  /// 错误代码统计
  final Map<String, int> errorCodeCount = {};

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'errorCount': errorCount,
      'errorTypeCount': errorTypeCount,
      'errorCodeCount': errorCodeCount,
    };
  }
}

/// 性能分析结果
class PerformanceAnalysisResult {
  /// 操作统计
  final Map<String, OperationStats> operationStats = {};

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'operationStats': operationStats.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

/// 操作统计
class OperationStats {
  /// 操作次数
  int count = 0;

  /// 总耗时
  int totalDuration = 0;

  /// 最小耗时
  int minDuration = 0;

  /// 最大耗时
  int maxDuration = 0;

  /// 平均耗时
  int avgDuration = 0;

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'totalDuration': totalDuration,
      'minDuration': minDuration,
      'maxDuration': maxDuration,
      'avgDuration': avgDuration,
    };
  }
}

/// 用户行为分析结果
class UserBehaviorAnalysisResult {
  /// 操作统计
  final Map<String, int> actionCount = {};

  /// 页面统计
  final Map<String, int> screenCount = {};

  /// 总耗时
  int totalDuration = 0;

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'actionCount': actionCount,
      'screenCount': screenCount,
      'totalDuration': totalDuration,
    };
  }
} 