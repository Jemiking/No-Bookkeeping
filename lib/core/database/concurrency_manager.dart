class ConcurrencyManager {
  final LockManager _lockManager;
  final VersionControl _versionControl;

  ConcurrencyManager(this._lockManager, this._versionControl);

  // 乐观锁更新
  Future<bool> optimisticUpdate(
    String resourceId,
    String requesterId,
    int expectedVersion,
    Future<void> Function() updateOperation,
  ) async {
    if (!_versionControl.validateVersion(resourceId, expectedVersion)) {
      return false;
    }

    try {
      await updateOperation();
      _versionControl.incrementVersion(resourceId);
      return true;
    } catch (e) {
      print('乐观锁更新失败: $e');
      return false;
    }
  }

  // 悲观锁更新
  Future<bool> pessimisticUpdate(
    String resourceId,
    String requesterId,
    Future<void> Function() updateOperation,
  ) async {
    if (!await _lockManager.acquireLock(resourceId, requesterId)) {
      return false;
    }

    try {
      await updateOperation();
      _versionControl.incrementVersion(resourceId);
      return true;
    } catch (e) {
      print('悲观锁更新失败: $e');
      return false;
    } finally {
      await _lockManager.releaseLock(resourceId, requesterId);
    }
  }

  // 并发操作控制
  Future<List<T>> controlledConcurrentOperations<T>(
    List<Future<T> Function()> operations,
    int maxConcurrent,
  ) async {
    final results = <T>[];
    final futures = <Future<T>>[];

    for (var i = 0; i < operations.length; i++) {
      if (futures.length >= maxConcurrent) {
        await Future.wait(futures);
        futures.clear();
      }
      futures.add(operations[i]());
    }

    if (futures.isNotEmpty) {
      results.addAll(await Future.wait(futures));
    }

    return results;
  }

  // 资源访问控制
  Future<T?> controlledResourceAccess<T>(
    String resourceId,
    String requesterId,
    Future<T> Function() operation,
    {bool optimistic = true}
  ) async {
    if (optimistic) {
      final version = _versionControl.getCurrentVersion(resourceId);
      final success = await optimisticUpdate(
        resourceId,
        requesterId,
        version,
        () async {
          await operation();
        },
      );
      if (!success) return null;
    } else {
      final success = await pessimisticUpdate(
        resourceId,
        requesterId,
        () async {
          await operation();
        },
      );
      if (!success) return null;
    }

    try {
      return await operation();
    } catch (e) {
      print('资源访问失败: $e');
      return null;
    }
  }
} 