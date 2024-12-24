import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../models/budget.dart';

/// 缓存管理器类
class CacheManager {
  /// SharedPreferences 实例
  final SharedPreferences _prefs;

  /// 缓存键前缀
  static const String _keyPrefix = 'cache_';

  /// 缓存过期时间（毫秒）
  static const int _defaultExpiration = 1000 * 60 * 60; // 1小时

  /// 构造函数
  CacheManager(this._prefs);

  /// 初始化
  static Future<CacheManager> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheManager(prefs);
  }

  /// 设置缓存
  Future<bool> set(String key, dynamic value, {int? expiration}) async {
    final cacheData = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': expiration ?? _defaultExpiration,
    };
    return await _prefs.setString(_keyPrefix + key, jsonEncode(cacheData));
  }

  /// 获取缓存
  dynamic get(String key) {
    final data = _prefs.getString(_keyPrefix + key);
    if (data == null) {
      return null;
    }

    final cacheData = jsonDecode(data);
    final timestamp = cacheData['timestamp'] as int;
    final expiration = cacheData['expiration'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - timestamp > expiration) {
      _prefs.remove(_keyPrefix + key);
      return null;
    }

    return cacheData['value'];
  }

  /// 删除缓存
  Future<bool> remove(String key) async {
    return await _prefs.remove(_keyPrefix + key);
  }

  /// 清除所有缓存
  Future<bool> clear() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
    return true;
  }

  /// 缓存账户列表
  Future<bool> cacheAccounts(List<Account> accounts) async {
    return await set(
      'accounts',
      accounts.map((a) => a.toJson()).toList(),
    );
  }

  /// 获取缓存的账户列表
  List<Account>? getCachedAccounts() {
    final data = get('accounts');
    if (data == null) {
      return null;
    }
    return (data as List).map((json) => Account.fromJson(json)).toList();
  }

  /// 缓存交易列表
  Future<bool> cacheTransactions(List<Transaction> transactions) async {
    return await set(
      'transactions',
      transactions.map((t) => t.toJson()).toList(),
    );
  }

  /// 获取缓存的交易列表
  List<Transaction>? getCachedTransactions() {
    final data = get('transactions');
    if (data == null) {
      return null;
    }
    return (data as List).map((json) => Transaction.fromJson(json)).toList();
  }

  /// 缓存分类列表
  Future<bool> cacheCategories(List<Category> categories) async {
    return await set(
      'categories',
      categories.map((c) => c.toJson()).toList(),
    );
  }

  /// 获取缓存的分类列表
  List<Category>? getCachedCategories() {
    final data = get('categories');
    if (data == null) {
      return null;
    }
    return (data as List).map((json) => Category.fromJson(json)).toList();
  }

  /// 缓存标签列表
  Future<bool> cacheTags(List<Tag> tags) async {
    return await set(
      'tags',
      tags.map((t) => t.toJson()).toList(),
    );
  }

  /// 获取缓存的标签列表
  List<Tag>? getCachedTags() {
    final data = get('tags');
    if (data == null) {
      return null;
    }
    return (data as List).map((json) => Tag.fromJson(json)).toList();
  }

  /// 缓存预算列表
  Future<bool> cacheBudgets(List<Budget> budgets) async {
    return await set(
      'budgets',
      budgets.map((b) => b.toJson()).toList(),
    );
  }

  /// 获取缓存的预算列表
  List<Budget>? getCachedBudgets() {
    final data = get('budgets');
    if (data == null) {
      return null;
    }
    return (data as List).map((json) => Budget.fromJson(json)).toList();
  }

  /// 缓存统计数据
  Future<bool> cacheStatistics(Map<String, dynamic> statistics) async {
    return await set('statistics', statistics);
  }

  /// 获取缓存的统计数据
  Map<String, dynamic>? getCachedStatistics() {
    final data = get('statistics');
    if (data == null) {
      return null;
    }
    return data as Map<String, dynamic>;
  }

  /// 检查缓存是否存在
  bool has(String key) {
    return _prefs.containsKey(_keyPrefix + key);
  }

  /// 获取缓存剩余时间（毫秒）
  int? getTimeToLive(String key) {
    final data = _prefs.getString(_keyPrefix + key);
    if (data == null) {
      return null;
    }

    final cacheData = jsonDecode(data);
    final timestamp = cacheData['timestamp'] as int;
    final expiration = cacheData['expiration'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final ttl = expiration - (now - timestamp);

    return ttl > 0 ? ttl : null;
  }

  /// 更新缓存过期时间
  Future<bool> touch(String key, {int? expiration}) async {
    final data = _prefs.getString(_keyPrefix + key);
    if (data == null) {
      return false;
    }

    final cacheData = jsonDecode(data);
    cacheData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    if (expiration != null) {
      cacheData['expiration'] = expiration;
    }

    return await _prefs.setString(_keyPrefix + key, jsonEncode(cacheData));
  }

  /// 获取所有缓存键
  Set<String> keys() {
    return _prefs.getKeys()
        .where((key) => key.startsWith(_keyPrefix))
        .map((key) => key.substring(_keyPrefix.length))
        .toSet();
  }

  /// 获取缓存大小（字节）
  int size() {
    int total = 0;
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_keyPrefix)) {
        final data = _prefs.getString(key);
        if (data != null) {
          total += data.length;
        }
      }
    }
    return total;
  }

  /// 清除过期缓存
  Future<void> clearExpired() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_keyPrefix)) {
        final data = _prefs.getString(key);
        if (data != null) {
          final cacheData = jsonDecode(data);
          final timestamp = cacheData['timestamp'] as int;
          final expiration = cacheData['expiration'] as int;
          if (now - timestamp > expiration) {
            await _prefs.remove(key);
          }
        }
      }
    }
  }

  /// 批量设置缓存
  Future<void> setMultiple(Map<String, dynamic> items, {int? expiration}) async {
    for (final entry in items.entries) {
      await set(entry.key, entry.value, expiration: expiration);
    }
  }

  /// 批量获取缓存
  Map<String, dynamic> getMultiple(List<String> keys) {
    final result = <String, dynamic>{};
    for (final key in keys) {
      final value = get(key);
      if (value != null) {
        result[key] = value;
      }
    }
    return result;
  }

  /// 批量删除缓存
  Future<void> removeMultiple(List<String> keys) async {
    for (final key in keys) {
      await remove(key);
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    int totalItems = 0;
    int totalSize = 0;
    int expiredItems = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_keyPrefix)) {
        totalItems++;
        final data = _prefs.getString(key);
        if (data != null) {
          totalSize += data.length;
          final cacheData = jsonDecode(data);
          final timestamp = cacheData['timestamp'] as int;
          final expiration = cacheData['expiration'] as int;
          if (now - timestamp > expiration) {
            expiredItems++;
          }
        }
      }
    }

    return {
      'total_items': totalItems,
      'total_size': totalSize,
      'expired_items': expiredItems,
      'active_items': totalItems - expiredItems,
    };
  }
} 