import 'dart:async';
import 'cache_manager.dart';
import 'cache_strategies.dart';

/// 缓存服务类
class CacheService {
  final Map<String, CacheManager> _cacheManagers = {};
  final StreamController<CacheServiceEvent> _eventController = 
      StreamController<CacheServiceEvent>.broadcast();

  // 默认缓存配置
  static const Duration defaultMaxAge = Duration(hours: 1);
  static const int defaultMaxSize = 1000;

  // 获取或创建缓存管理器
  CacheManager _getOrCreateManager(
    String namespace, {
    int? maxSize,
    Duration? maxAge,
    CacheStrategy? strategy,
  }) {
    return _cacheManagers.putIfAbsent(
      namespace,
      () => CacheManager(
        maxSize: maxSize ?? defaultMaxSize,
        maxAge: maxAge ?? defaultMaxAge,
        strategy: strategy,
      ),
    );
  }

  // 获取缓存项
  T? get<T>(String key, {String namespace = 'default'}) {
    final manager = _cacheManagers[namespace];
    if (manager == null) {
      _eventController.add(CacheServiceEvent(
        'Cache manager not found for namespace: $namespace',
        CacheServiceEventType.error,
      ));
      return null;
    }

    final value = manager.get<T>(key);
    _eventController.add(CacheServiceEvent(
      'Get cache: $key from $namespace',
      value != null 
          ? CacheServiceEventType.hit 
          : CacheServiceEventType.miss,
    ));
    return value;
  }

  // 设置缓存项
  void set<T>(
    String key,
    T value, {
    String namespace = 'default',
    int? maxSize,
    Duration? maxAge,
    CacheStrategy? strategy,
  }) {
    final manager = _getOrCreateManager(
      namespace,
      maxSize: maxSize,
      maxAge: maxAge,
      strategy: strategy,
    );

    manager.set(key, value);
    _eventController.add(CacheServiceEvent(
      'Set cache: $key in $namespace',
      CacheServiceEventType.set,
    ));
  }

  // 移除缓存项
  void remove(String key, {String namespace = 'default'}) {
    final manager = _cacheManagers[namespace];
    if (manager != null) {
      manager.remove(key);
      _eventController.add(CacheServiceEvent(
        'Remove cache: $key from $namespace',
        CacheServiceEventType.remove,
      ));
    }
  }

  // 清空指定命名空间的缓存
  void clearNamespace(String namespace) {
    final manager = _cacheManagers[namespace];
    if (manager != null) {
      manager.clear();
      _eventController.add(CacheServiceEvent(
        'Clear namespace: $namespace',
        CacheServiceEventType.clear,
      ));
    }
  }

  // 清空所有缓存
  void clearAll() {
    for (final manager in _cacheManagers.values) {
      manager.clear();
    }
    _cacheManagers.clear();
    _eventController.add(CacheServiceEvent(
      'Clear all caches',
      CacheServiceEventType.clear,
    ));
  }

  // 获取缓存统计信息
  Map<String, CacheStatistics> getStatistics() {
    final stats = <String, CacheStatistics>{};
    for (final entry in _cacheManagers.entries) {
      stats[entry.key] = CacheStatistics(
        namespace: entry.key,
        size: entry.value.size,
      );
    }
    return stats;
  }

  // 监听缓存事件
  Stream<CacheServiceEvent> get events => _eventController.stream;

  // 创建特定策略的缓存管理器
  void createCache(
    String namespace, {
    int? maxSize,
    Duration? maxAge,
    CacheStrategy? strategy,
  }) {
    if (!_cacheManagers.containsKey(namespace)) {
      _getOrCreateManager(
        namespace,
        maxSize: maxSize,
        maxAge: maxAge,
        strategy: strategy,
      );
      _eventController.add(CacheServiceEvent(
        'Create cache manager: $namespace',
        CacheServiceEventType.create,
      ));
    }
  }

  // 移除缓存管理器
  void removeCache(String namespace) {
    final manager = _cacheManagers.remove(namespace);
    if (manager != null) {
      manager.dispose();
      _eventController.add(CacheServiceEvent(
        'Remove cache manager: $namespace',
        CacheServiceEventType.remove,
      ));
    }
  }

  // 检查键是否存在
  bool containsKey(String key, {String namespace = 'default'}) {
    final manager = _cacheManagers[namespace];
    return manager?.containsKey(key) ?? false;
  }

  // 获取命名空间列表
  List<String> get namespaces => _cacheManagers.keys.toList();

  // 释放资源
  void dispose() {
    for (final manager in _cacheManagers.values) {
      manager.dispose();
    }
    _cacheManagers.clear();
    _eventController.close();
  }
}

/// 缓存服务事件类型
enum CacheServiceEventType {
  hit,
  miss,
  set,
  remove,
  clear,
  create,
  error,
}

/// 缓存服务事件
class CacheServiceEvent {
  final String message;
  final CacheServiceEventType type;
  final DateTime timestamp;

  CacheServiceEvent(this.message, this.type)
      : timestamp = DateTime.now();
}

/// 缓存统计信息
class CacheStatistics {
  final String namespace;
  final int size;

  CacheStatistics({
    required this.namespace,
    required this.size,
  });
} 