import '../database/dao/category_dao.dart';
import '../database/models/category.dart';
import '../cache/cache_manager.dart';

/// 分类服务类
class CategoryService {
  final CategoryDao _categoryDao;
  final CacheManager _cacheManager;

  /// 构造函数
  CategoryService(this._categoryDao, this._cacheManager);

  /// 创建分类
  Future<Category> createCategory(Category category) async {
    // 验证分类名是否已存在
    final exists = await _categoryDao.isNameExists(category.name);
    if (exists) {
      throw Exception('分类名已存在');
    }

    // 插入分类
    final id = await _categoryDao.insert(category);
    final createdCategory = category.copyWith(id: id);

    // 更新缓存
    final cachedCategories = await _getCachedCategories();
    cachedCategories.add(createdCategory);
    await _cacheManager.cacheCategories(cachedCategories);

    return createdCategory;
  }

  /// 更新分类
  Future<Category> updateCategory(Category category) async {
    // 验证分类名是否已存在（排除当前分类）
    final exists = await _categoryDao.isNameExists(
      category.name,
      excludeId: category.id,
    );
    if (exists) {
      throw Exception('分类名已存在');
    }

    // 更新分类
    await _categoryDao.update(category);

    // 更新缓存
    final cachedCategories = await _getCachedCategories();
    final index = cachedCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      cachedCategories[index] = category;
      await _cacheManager.cacheCategories(cachedCategories);
    }

    return category;
  }

  /// 删除分类
  Future<void> deleteCategory(int id) async {
    // 删除分类
    await _categoryDao.delete(id);

    // 更新缓存
    final cachedCategories = await _getCachedCategories();
    cachedCategories.removeWhere((c) => c.id == id);
    await _cacheManager.cacheCategories(cachedCategories);
  }

  /// 获取分类
  Future<Category?> getCategory(int id) async {
    // 先从缓存获取
    final cachedCategories = await _getCachedCategories();
    final cachedCategory = cachedCategories.firstWhere(
      (c) => c.id == id,
      orElse: () => null as Category,
    );
    if (cachedCategory != null) {
      return cachedCategory;
    }

    // 从数据库获取
    return await _categoryDao.get(id);
  }

  /// 获取所有分类
  Future<List<Category>> getAllCategories() async {
    // 先从缓存获取
    final cachedCategories = await _getCachedCategories();
    if (cachedCategories.isNotEmpty) {
      return cachedCategories;
    }

    // 从数据库获取
    final categories = await _categoryDao.getAll();
    
    // 更新缓存
    await _cacheManager.cacheCategories(categories);
    
    return categories;
  }

  /// 获取父分类的子分类
  Future<List<Category>> getChildCategories(int parentId) async {
    return await _categoryDao.getChildren(parentId);
  }

  /// 获取根分类
  Future<List<Category>> getRootCategories() async {
    return await _categoryDao.getRootCategories();
  }

  /// 获取分类树
  Future<List<Category>> getCategoryTree() async {
    return await _categoryDao.getCategoryTree();
  }

  /// 搜索分类
  Future<List<Category>> searchCategories({
    String? keyword,
    List<CategoryType>? types,
    bool? isSystem,
    bool? isActive,
  }) async {
    return await _categoryDao.search(
      keyword: keyword,
      types: types,
      isSystem: isSystem,
      isActive: isActive,
    );
  }

  /// 获取分类统计信息
  Future<Map<String, dynamic>> getStatistics() async {
    return await _categoryDao.getStatistics();
  }

  /// 更新分类排序
  Future<void> updateOrder(List<Map<String, dynamic>> updates) async {
    await _categoryDao.updateOrder(updates);

    // 更新缓存
    final categories = await _categoryDao.getAll();
    await _cacheManager.cacheCategories(categories);
  }

  /// 批量更新分类状态
  Future<void> updateStatus(List<int> ids, {bool? isActive}) async {
    await _categoryDao.updateStatus(ids, isActive: isActive);

    // 更新缓存
    final categories = await _categoryDao.getAll();
    await _cacheManager.cacheCategories(categories);
  }

  /// 获取分类使用统计
  Future<List<Map<String, dynamic>>> getUsageStatistics() async {
    return await _categoryDao.getUsageStatistics();
  }

  /// 从缓存获取分类列表
  Future<List<Category>> _getCachedCategories() async {
    return _cacheManager.getCachedCategories() ?? [];
  }
} 