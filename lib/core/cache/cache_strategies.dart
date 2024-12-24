import 'cache_manager.dart';

/// LRU（最近最少使用）缓存策略
class LRUCacheStrategy implements CacheStrategy {
  @override
  bool shouldEvict(CacheEntry entry) {
    return true; // 总是选择最久未使用的条目
  }

  @override
  void onEntryAccessed(CacheEntry entry) {
    // 更新访问时间
    entry.markAccessed();
  }

  @override
  void onEntryAdded(CacheEntry entry) {
    // 无需特殊处理
  }

  @override
  void onEntryRemoved(CacheEntry entry) {
    // 无需特殊处理
  }
}

/// LFU（最不经常使用）缓存策略
class LFUCacheStrategy implements CacheStrategy {
  @override
  bool shouldEvict(CacheEntry entry) {
    return true; // 总是选择访问次数最少的条目
  }

  @override
  void onEntryAccessed(CacheEntry entry) {
    // 增加访问计数
    entry.markAccessed();
  }

  @override
  void onEntryAdded(CacheEntry entry) {
    // 初始化访问计数
  }

  @override
  void onEntryRemoved(CacheEntry entry) {
    // 无需特殊处理
  }
}

/// FIFO（先进先出）缓存策略
class FIFOCacheStrategy implements CacheStrategy {
  @override
  bool shouldEvict(CacheEntry entry) {
    return true; // 总是选择最早创建的条目
  }

  @override
  void onEntryAccessed(CacheEntry entry) {
    // FIFO策略不关心访问
  }

  @override
  void onEntryAdded(CacheEntry entry) {
    // 无需特殊处理
  }

  @override
  void onEntryRemoved(CacheEntry entry) {
    // 无需特殊处理
  }
}

/// 时间过期策略
class TimeExpirationStrategy implements CacheStrategy {
  final Duration maxAge;

  TimeExpirationStrategy(this.maxAge);

  @override
  bool shouldEvict(CacheEntry entry) {
    return DateTime.now().difference(entry.createdAt) > maxAge;
  }

  @override
  void onEntryAccessed(CacheEntry entry) {
    // 不更新过期时间
  }

  @override
  void onEntryAdded(CacheEntry entry) {
    // 无需特殊处理
  }

  @override
  void onEntryRemoved(CacheEntry entry) {
    // 无需特殊处理
  }
}

/// 混合策略（组合多个策略）
class HybridCacheStrategy implements CacheStrategy {
  final List<CacheStrategy> strategies;

  HybridCacheStrategy(this.strategies);

  @override
  bool shouldEvict(CacheEntry entry) {
    return strategies.any((strategy) => strategy.shouldEvict(entry));
  }

  @override
  void onEntryAccessed(CacheEntry entry) {
    for (final strategy in strategies) {
      strategy.onEntryAccessed(entry);
    }
  }

  @override
  void onEntryAdded(CacheEntry entry) {
    for (final strategy in strategies) {
      strategy.onEntryAdded(entry);
    }
  }

  @override
  void onEntryRemoved(CacheEntry entry) {
    for (final strategy in strategies) {
      strategy.onEntryRemoved(entry);
    }
  }
} 