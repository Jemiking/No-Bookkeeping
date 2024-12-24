import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class CloudSyncConfig {
  final String serverUrl;
  final String username;
  final String password;
  final Duration syncInterval;
  final int maxRetries;
  final bool autoSync;

  CloudSyncConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.syncInterval = const Duration(minutes: 30),
    this.maxRetries = 3,
    this.autoSync = true,
  });
}

class SyncStatus {
  final bool isSuccess;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  SyncStatus({
    required this.isSuccess,
    required this.message,
    required this.timestamp,
    this.details,
  });
}

class CloudSyncService {
  final CloudSyncConfig config;
  Timer? _syncTimer;
  bool _isSyncing = false;
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final Map<String, DateTime> _lastSyncTimes = {};
  final Map<String, String> _localHashCache = {};

  CloudSyncService(this.config) {
    if (config.autoSync) {
      startAutoSync();
    }
  }

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  // 启动自动同步
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(config.syncInterval, (_) => syncData());
  }

  // 停止自动同步
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // 执行数据同步
  Future<SyncStatus> syncData() async {
    if (_isSyncing) {
      return SyncStatus(
        isSuccess: false,
        message: '同步正在进行中',
        timestamp: DateTime.now(),
      );
    }

    _isSyncing = true;
    try {
      // 1. 准备本地数据
      final localData = await _prepareLocalData();
      
      // 2. 获取服务器数据
      final serverData = await _fetchServerData();
      
      // 3. 执行增量同步
      final syncResult = await _performIncrementalSync(localData, serverData);
      
      // 4. 处理冲突
      final resolvedData = await _resolveConflicts(syncResult);
      
      // 5. 更新服务器数据
      await _updateServerData(resolvedData);
      
      // 6. 更新本地缓存
      await _updateLocalCache(resolvedData);

      return SyncStatus(
        isSuccess: true,
        message: '同步成功',
        timestamp: DateTime.now(),
        details: {'changedItems': syncResult.length},
      );
    } catch (e) {
      return SyncStatus(
        isSuccess: false,
        message: '同步失败: $e',
        timestamp: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  // 准备本地数据
  Future<Map<String, dynamic>> _prepareLocalData() async {
    try {
      // 收集需要同步的本地数据
      final localData = <String, dynamic>{};
      
      // 获取各类数据
      localData['accounts'] = await _getLocalAccounts();
      localData['transactions'] = await _getLocalTransactions();
      localData['categories'] = await _getLocalCategories();
      localData['tags'] = await _getLocalTags();
      localData['budgets'] = await _getLocalBudgets();

      return localData;
    } catch (e) {
      throw Exception('准备本地数据失败: $e');
    }
  }

  // 获取服务器数据
  Future<Map<String, dynamic>> _fetchServerData() async {
    try {
      // 这里实现实际的服务器数据获取逻辑
      final response = await _makeApiRequest(
        '${config.serverUrl}/sync/data',
        method: 'GET',
        headers: {'X-API-Key': config.apiKey},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('获取服务器数据失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取服务器数据失败: $e');
    }
  }

  // 执行增量同步
  Future<Map<String, dynamic>> _performIncrementalSync(
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
  ) async {
    final changes = <String, dynamic>{};

    // 对每种数据类型进行增量比较
    for (final dataType in localData.keys) {
      final localItems = localData[dataType] as Map<String, dynamic>;
      final serverItems = serverData[dataType] as Map<String, dynamic>;

      // 比较本地和服务器数据的哈希值
      for (final itemId in localItems.keys) {
        final localHash = _calculateHash(localItems[itemId]);
        final serverHash = _calculateHash(serverItems[itemId]);

        if (localHash != serverHash) {
          if (!changes.containsKey(dataType)) {
            changes[dataType] = <String, dynamic>{};
          }
          changes[dataType][itemId] = {
            'local': localItems[itemId],
            'server': serverItems[itemId],
          };
        }
      }
    }

    return changes;
  }

  // 解决冲突
  Future<Map<String, dynamic>> _resolveConflicts(
    Map<String, dynamic> conflicts,
  ) async {
    final resolvedData = <String, dynamic>{};

    for (final dataType in conflicts.keys) {
      resolvedData[dataType] = <String, dynamic>{};
      final typeConflicts = conflicts[dataType] as Map<String, dynamic>;

      for (final itemId in typeConflicts.keys) {
        final conflict = typeConflicts[itemId] as Map<String, dynamic>;
        final localVersion = conflict['local'];
        final serverVersion = conflict['server'];

        // 使用时间戳策略解决冲突
        final resolvedItem = await _resolveConflictByTimestamp(
          localVersion,
          serverVersion,
        );
        resolvedData[dataType][itemId] = resolvedItem;
      }
    }

    return resolvedData;
  }

  // 更新服务器数据
  Future<void> _updateServerData(Map<String, dynamic> data) async {
    try {
      final response = await _makeApiRequest(
        '${config.serverUrl}/sync/update',
        method: 'POST',
        headers: {
          'X-API-Key': config.apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('更新服务器数据失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('更新服务器数据失败: $e');
    }
  }

  // 更新本地缓存
  Future<void> _updateLocalCache(Map<String, dynamic> data) async {
    try {
      // 更新本地数据库
      await _updateLocalDatabase(data);
      
      // 更新同步时间戳
      for (final dataType in data.keys) {
        _lastSyncTimes[dataType] = DateTime.now();
      }
      
      // 更新哈希缓存
      for (final dataType in data.keys) {
        final items = data[dataType] as Map<String, dynamic>;
        for (final itemId in items.keys) {
          _localHashCache['$dataType:$itemId'] = _calculateHash(items[itemId]);
        }
      }
    } catch (e) {
      throw Exception('更新本地缓存失败: $e');
    }
  }

  // 获取本地账户数据
  Future<Map<String, dynamic>> _getLocalAccounts() async {
    // 实现从本地数据库获取账户数据的逻辑
    return {};
  }

  // 获取本地交易数据
  Future<Map<String, dynamic>> _getLocalTransactions() async {
    // 实现从本地数据库获取交易数据的逻辑
    return {};
  }

  // 获取本地分类数据
  Future<Map<String, dynamic>> _getLocalCategories() async {
    // 实现从本地数据库获取分类数据的逻辑
    return {};
  }

  // 获取本地标签数据
  Future<Map<String, dynamic>> _getLocalTags() async {
    // 实现从本地数据库获取标签数据的逻辑
    return {};
  }

  // 获取本地预算数据
  Future<Map<String, dynamic>> _getLocalBudgets() async {
    // 实现从本地数据库获取预算数据的逻辑
    return {};
  }

  // 计算数据哈希值
  String _calculateHash(dynamic data) {
    final content = json.encode(data);
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 基于时间戳解决冲突
  Future<Map<String, dynamic>> _resolveConflictByTimestamp(
    Map<String, dynamic> localVersion,
    Map<String, dynamic> serverVersion,
  ) async {
    final localTimestamp = DateTime.parse(localVersion['updatedAt'] as String);
    final serverTimestamp = DateTime.parse(serverVersion['updatedAt'] as String);

    return localTimestamp.isAfter(serverTimestamp) ? localVersion : serverVersion;
  }

  // 更新本地数据库
  Future<void> _updateLocalDatabase(Map<String, dynamic> data) async {
    // 实现更新本地数据库的逻辑
  }

  // 发送API请求
  Future<dynamic> _makeApiRequest(
    String url, {
    required String method,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    // 实现实际的API请求逻辑
    return null;
  }

  // 销毁服务
  void dispose() {
    stopAutoSync();
    _syncStatusController.close();
  }
} 