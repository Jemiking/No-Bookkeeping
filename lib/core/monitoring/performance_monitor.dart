import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../logging/app_logger.dart';

/// 性能监控服务
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  final AppLogger _logger = AppLogger();
  final Map<String, _OperationTimer> _timers = {};
  final Map<String, _FrameStats> _frameStats = {};
  Timer? _frameStatsTimer;
  bool _initialized = false;

  /// 获取单例实例
  factory PerformanceMonitor() {
    return _instance;
  }

  PerformanceMonitor._internal();

  /// 初始化性能监控服务
  void init() {
    if (_initialized) {
      return;
    }

    // 监听帧绘制
    WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);

    // 定期记录帧统计
    _frameStatsTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _logFrameStats(),
    );

    _initialized = true;
  }

  /// 销毁性能监控服务
  void dispose() {
    _frameStatsTimer?.cancel();
    _frameStatsTimer = null;
    _initialized = false;
  }

  /// 开始计时
  void startOperation(String name) {
    if (!_initialized) {
      return;
    }

    _timers[name] = _OperationTimer(name);
  }

  /// 结束计时
  void endOperation(String name) {
    if (!_initialized) {
      return;
    }

    final timer = _timers.remove(name);
    if (timer == null) {
      return;
    }

    final duration = timer.stop();
    _logger.info(
      '操作完成',
      data: {
        'operation': name,
        'duration': duration.inMilliseconds,
      },
    );
  }

  /// 监控异步操作
  Future<T> monitorAsync<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    startOperation(name);
    try {
      return await operation();
    } finally {
      endOperation(name);
    }
  }

  /// 监控同步操作
  T monitorSync<T>(
    String name,
    T Function() operation,
  ) {
    startOperation(name);
    try {
      return operation();
    } finally {
      endOperation(name);
    }
  }

  /// 处理帧绘制回调
  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_initialized) {
      return;
    }

    for (final timing in timings) {
      final buildDuration = Duration(
        microseconds: timing.buildDuration.inMicroseconds,
      );
      final rasterDuration = Duration(
        microseconds: timing.rasterDuration.inMicroseconds,
      );
      final totalDuration = buildDuration + rasterDuration;

      final stats = _frameStats[timing.vsyncOverhead.toString()] ??= _FrameStats();
      stats.frameCount++;
      stats.totalBuildDuration += buildDuration;
      stats.totalRasterDuration += rasterDuration;
      stats.totalDuration += totalDuration;

      if (totalDuration > const Duration(milliseconds: 16)) {
        stats.jankCount++;
        _logger.warning(
          '帧绘制延迟',
          data: {
            'buildDuration': buildDuration.inMilliseconds,
            'rasterDuration': rasterDuration.inMilliseconds,
            'totalDuration': totalDuration.inMilliseconds,
          },
        );
      }
    }
  }

  /// 记录帧统计
  void _logFrameStats() {
    if (!_initialized || _frameStats.isEmpty) {
      return;
    }

    for (final entry in _frameStats.entries) {
      final stats = entry.value;
      _logger.info(
        '帧统计',
        data: {
          'vsyncOverhead': entry.key,
          'frameCount': stats.frameCount,
          'jankCount': stats.jankCount,
          'avgBuildDuration':
              (stats.totalBuildDuration.inMicroseconds / stats.frameCount)
                  .toStringAsFixed(2),
          'avgRasterDuration':
              (stats.totalRasterDuration.inMicroseconds / stats.frameCount)
                  .toStringAsFixed(2),
          'avgTotalDuration':
              (stats.totalDuration.inMicroseconds / stats.frameCount)
                  .toStringAsFixed(2),
          'jankRate':
              (stats.jankCount / stats.frameCount * 100).toStringAsFixed(2),
        },
      );
    }

    _frameStats.clear();
  }

  /// 监控内存使用
  void monitorMemory() {
    if (!_initialized) {
      return;
    }

    if (kDebugMode) {
      final info = HeapProfile.current;
      _logger.info(
        '内存使用',
        data: {
          'heapSize': info.heapSize,
          'heapUsage': info.heapUsage,
          'externalSize': info.externalSize,
        },
      );
    }
  }

  /// 监控 CPU 使用
  void monitorCPU() {
    if (!_initialized) {
      return;
    }

    // TODO: 实现 CPU 使用监控
  }

  /// 监控网络请求
  void monitorNetwork(
    String url,
    String method,
    int statusCode,
    int contentLength,
    Duration duration,
  ) {
    if (!_initialized) {
      return;
    }

    _logger.info(
      '网络请求',
      data: {
        'url': url,
        'method': method,
        'statusCode': statusCode,
        'contentLength': contentLength,
        'duration': duration.inMilliseconds,
      },
    );
  }

  /// 监控电池使用
  void monitorBattery() {
    if (!_initialized) {
      return;
    }

    // TODO: 实现电池使用监控
  }

  /// 监控存储使用
  void monitorStorage() {
    if (!_initialized) {
      return;
    }

    // TODO: 实现存储使用监控
  }
}

/// 操作计时器
class _OperationTimer {
  final String name;
  final DateTime startTime;

  _OperationTimer(this.name) : startTime = DateTime.now();

  Duration stop() {
    return DateTime.now().difference(startTime);
  }
}

/// 帧统计
class _FrameStats {
  int frameCount = 0;
  int jankCount = 0;
  Duration totalBuildDuration = Duration.zero;
  Duration totalRasterDuration = Duration.zero;
  Duration totalDuration = Duration.zero;
} 