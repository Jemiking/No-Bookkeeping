class VersionControl {
  final Map<String, int> _versions = {};
  final Map<String, List<int>> _history = {};

  // 获取当前版本
  int getCurrentVersion(String resourceId) {
    return _versions[resourceId] ?? 0;
  }

  // 更新版本
  int incrementVersion(String resourceId) {
    final newVersion = (_versions[resourceId] ?? 0) + 1;
    _versions[resourceId] = newVersion;
    _history.putIfAbsent(resourceId, () => []).add(newVersion);
    return newVersion;
  }

  // 验证版本
  bool validateVersion(String resourceId, int version) {
    return _versions[resourceId] == version;
  }

  // 获取版本历史
  List<int> getVersionHistory(String resourceId) {
    return List.from(_history[resourceId] ?? []);
  }

  // 回滚版本
  bool rollbackVersion(String resourceId, int targetVersion) {
    final history = _history[resourceId];
    if (history == null || !history.contains(targetVersion)) {
      return false;
    }
    _versions[resourceId] = targetVersion;
    history.removeWhere((v) => v > targetVersion);
    return true;
  }
} 