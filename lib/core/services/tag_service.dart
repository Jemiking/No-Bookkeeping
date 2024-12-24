import '../database/dao/tag_dao.dart';
import '../database/models/tag.dart';
import '../cache/cache_manager.dart';

/// 标签服务类
class TagService {
  final TagDao _tagDao;
  final CacheManager _cacheManager;

  /// 构造函数
  TagService(this._tagDao, this._cacheManager);

  /// 创建标签
  Future<Tag> createTag(Tag tag) async {
    // 验证标签名是否已存在
    final exists = await _tagDao.isNameExists(tag.name);
    if (exists) {
      throw Exception('标签名已存在');
    }

    // 插入标签
    final id = await _tagDao.insert(tag);
    final createdTag = tag.copyWith(id: id);

    // 更新缓存
    final cachedTags = await _getCachedTags();
    cachedTags.add(createdTag);
    await _cacheManager.cacheTags(cachedTags);

    return createdTag;
  }

  /// 更新标签
  Future<Tag> updateTag(Tag tag) async {
    // 验证标签名是否已存在（排除当前标签）
    final exists = await _tagDao.isNameExists(
      tag.name,
      excludeId: tag.id,
    );
    if (exists) {
      throw Exception('标签名已存在');
    }

    // 更新标签
    await _tagDao.update(tag);

    // 更新缓存
    final cachedTags = await _getCachedTags();
    final index = cachedTags.indexWhere((t) => t.id == tag.id);
    if (index != -1) {
      cachedTags[index] = tag;
      await _cacheManager.cacheTags(cachedTags);
    }

    return tag;
  }

  /// 删除标签
  Future<void> deleteTag(int id) async {
    // 删除标签
    await _tagDao.delete(id);

    // 更新缓存
    final cachedTags = await _getCachedTags();
    cachedTags.removeWhere((t) => t.id == id);
    await _cacheManager.cacheTags(cachedTags);
  }

  /// 获取标签
  Future<Tag?> getTag(int id) async {
    // 先从缓存获取
    final cachedTags = await _getCachedTags();
    final cachedTag = cachedTags.firstWhere(
      (t) => t.id == id,
      orElse: () => null as Tag,
    );
    if (cachedTag != null) {
      return cachedTag;
    }

    // 从数据库获取
    return await _tagDao.get(id);
  }

  /// 获取所有标签
  Future<List<Tag>> getAllTags() async {
    // 先从缓存获取
    final cachedTags = await _getCachedTags();
    if (cachedTags.isNotEmpty) {
      return cachedTags;
    }

    // 从数据库获取
    final tags = await _tagDao.getAll();
    
    // 更新缓存
    await _cacheManager.cacheTags(tags);
    
    return tags;
  }

  /// 获取交易的标签
  Future<List<Tag>> getTagsByTransaction(int transactionId) async {
    return await _tagDao.getByTransaction(transactionId);
  }

  /// 搜索标签
  Future<List<Tag>> searchTags({
    String? keyword,
    bool? isSystem,
    bool? isActive,
    int? minUseCount,
    int? maxUseCount,
  }) async {
    return await _tagDao.search(
      keyword: keyword,
      isSystem: isSystem,
      isActive: isActive,
      minUseCount: minUseCount,
      maxUseCount: maxUseCount,
    );
  }

  /// 获取标签统计信息
  Future<Map<String, dynamic>> getStatistics() async {
    return await _tagDao.getStatistics();
  }

  /// 批量更新标签状态
  Future<void> updateStatus(List<int> ids, {bool? isActive}) async {
    await _tagDao.updateStatus(ids, isActive: isActive);

    // 更新缓存
    final tags = await _tagDao.getAll();
    await _cacheManager.cacheTags(tags);
  }

  /// 增加标签使用次数
  Future<void> incrementUseCount(int id) async {
    await _tagDao.incrementUseCount(id);

    // 更新缓存
    final tag = await _tagDao.get(id);
    if (tag != null) {
      final cachedTags = await _getCachedTags();
      final index = cachedTags.indexWhere((t) => t.id == id);
      if (index != -1) {
        cachedTags[index] = tag;
        await _cacheManager.cacheTags(cachedTags);
      }
    }
  }

  /// 减少标签使用次数
  Future<void> decrementUseCount(int id) async {
    await _tagDao.decrementUseCount(id);

    // 更新缓存
    final tag = await _tagDao.get(id);
    if (tag != null) {
      final cachedTags = await _getCachedTags();
      final index = cachedTags.indexWhere((t) => t.id == id);
      if (index != -1) {
        cachedTags[index] = tag;
        await _cacheManager.cacheTags(cachedTags);
      }
    }
  }

  /// 获取标签使用统计
  Future<List<Map<String, dynamic>>> getUsageStatistics() async {
    return await _tagDao.getUsageStatistics();
  }

  /// 获取相关标签
  Future<List<Tag>> getRelatedTags(int tagId) async {
    return await _tagDao.getRelatedTags(tagId);
  }

  /// 合并标签
  Future<bool> mergeTags(int sourceId, int targetId) async {
    final result = await _tagDao.mergeTags(sourceId, targetId);

    if (result) {
      // 更新缓存
      final tags = await _tagDao.getAll();
      await _cacheManager.cacheTags(tags);
    }

    return result;
  }

  /// 从缓存获取标签列表
  Future<List<Tag>> _getCachedTags() async {
    return _cacheManager.getCachedTags() ?? [];
  }
} 