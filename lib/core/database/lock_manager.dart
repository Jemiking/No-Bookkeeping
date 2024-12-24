class LockManager {
  final Map<String, Lock> _locks = {};
  final Map<String, String> _resourceOwners = {};
  
  // 获取锁
  Future<bool> acquireLock(String resourceId, String requesterId) async {
    try {
      final lock = _locks.putIfAbsent(resourceId, () => Lock());
      if (await lock.acquire()) {
        _resourceOwners[resourceId] = requesterId;
        return true;
      }
      return false;
    } catch (e) {
      print('获取锁失败: $e');
      return false;
    }
  }

  // 释放锁
  Future<bool> releaseLock(String resourceId, String requesterId) async {
    try {
      if (_resourceOwners[resourceId] != requesterId) {
        return false;
      }
      final lock = _locks[resourceId];
      if (lock != null) {
        await lock.release();
        _resourceOwners.remove(resourceId);
        return true;
      }
      return false;
    } catch (e) {
      print('释放锁失败: $e');
      return false;
    }
  }

  // 检查锁状态
  bool isLocked(String resourceId) {
    return _locks[resourceId]?.isLocked ?? false;
  }

  // 获取资源所有者
  String? getResourceOwner(String resourceId) {
    return _resourceOwners[resourceId];
  }

  // 清理过期锁
  void cleanupExpiredLocks(Duration timeout) {
    final expiredResources = _resourceOwners.entries
        .where((entry) => _locks[entry.key]?.isExpired(timeout) ?? false)
        .map((entry) => entry.key)
        .toList();

    for (var resourceId in expiredResources) {
      _locks[resourceId]?.forceRelease();
      _locks.remove(resourceId);
      _resourceOwners.remove(resourceId);
    }
  }
}

class Lock {
  bool _locked = false;
  DateTime? _acquiredTime;

  bool get isLocked => _locked;

  Future<bool> acquire() async {
    if (_locked) return false;
    _locked = true;
    _acquiredTime = DateTime.now();
    return true;
  }

  Future<void> release() async {
    _locked = false;
    _acquiredTime = null;
  }

  void forceRelease() {
    _locked = false;
    _acquiredTime = null;
  }

  bool isExpired(Duration timeout) {
    if (!_locked || _acquiredTime == null) return false;
    return DateTime.now().difference(_acquiredTime!) > timeout;
  }
}