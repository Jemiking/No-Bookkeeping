import '../database/dao/budget_dao.dart';
import '../database/models/budget.dart';
import '../cache/cache_manager.dart';

/// 预算服务类
class BudgetService {
  final BudgetDao _budgetDao;
  final CacheManager _cacheManager;

  /// 构造函数
  BudgetService(this._budgetDao, this._cacheManager);

  /// 创建预算
  Future<Budget> createBudget(Budget budget) async {
    // 验证预算名是否已存在
    final exists = await _budgetDao.isNameExists(budget.name);
    if (exists) {
      throw Exception('预算名已存在');
    }

    // 插入预算
    final id = await _budgetDao.insert(budget);
    final createdBudget = budget.copyWith(id: id);

    // 更新缓存
    final cachedBudgets = await _getCachedBudgets();
    cachedBudgets.add(createdBudget);
    await _cacheManager.cacheBudgets(cachedBudgets);

    return createdBudget;
  }

  /// 更新预算
  Future<Budget> updateBudget(Budget budget) async {
    // 验证预算名是否已存在（排除当前预算）
    final exists = await _budgetDao.isNameExists(
      budget.name,
      excludeId: budget.id,
    );
    if (exists) {
      throw Exception('预算名已存在');
    }

    // 更新预算
    await _budgetDao.update(budget);

    // 更新缓存
    final cachedBudgets = await _getCachedBudgets();
    final index = cachedBudgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      cachedBudgets[index] = budget;
      await _cacheManager.cacheBudgets(cachedBudgets);
    }

    return budget;
  }

  /// 删除预算
  Future<void> deleteBudget(int id) async {
    // 删除预算
    await _budgetDao.delete(id);

    // 更新缓存
    final cachedBudgets = await _getCachedBudgets();
    cachedBudgets.removeWhere((b) => b.id == id);
    await _cacheManager.cacheBudgets(cachedBudgets);
  }

  /// 获取预算
  Future<Budget?> getBudget(int id) async {
    // 先从缓存获取
    final cachedBudgets = await _getCachedBudgets();
    final cachedBudget = cachedBudgets.firstWhere(
      (b) => b.id == id,
      orElse: () => null as Budget,
    );
    if (cachedBudget != null) {
      return cachedBudget;
    }

    // 从数据库获取
    return await _budgetDao.get(id);
  }

  /// 获取所有预算
  Future<List<Budget>> getAllBudgets() async {
    // 先从缓存获取
    final cachedBudgets = await _getCachedBudgets();
    if (cachedBudgets.isNotEmpty) {
      return cachedBudgets;
    }

    // 从数据库获取
    final budgets = await _budgetDao.getAll();
    
    // 更新缓存
    await _cacheManager.cacheBudgets(budgets);
    
    return budgets;
  }

  /// 获取分类的预算
  Future<List<Budget>> getBudgetsByCategory(int categoryId) async {
    return await _budgetDao.getByCategory(categoryId);
  }

  /// 搜索预算
  Future<List<Budget>> searchBudgets({
    String? keyword,
    bool? isActive,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _budgetDao.search(
      keyword: keyword,
      isActive: isActive,
      minAmount: minAmount,
      maxAmount: maxAmount,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 获取预算统计信息
  Future<Map<String, dynamic>> getStatistics() async {
    return await _budgetDao.getStatistics();
  }

  /// 批量更新预算状态
  Future<void> updateStatus(List<int> ids, {bool? isActive}) async {
    await _budgetDao.updateStatus(ids, isActive: isActive);

    // 更新缓存
    final budgets = await _budgetDao.getAll();
    await _cacheManager.cacheBudgets(budgets);
  }

  /// 获取预算使用情况
  Future<Map<String, dynamic>> getUsage(int id) async {
    return await _budgetDao.getUsage(id);
  }

  /// 获取预算提醒
  Future<List<Map<String, dynamic>>> getReminders() async {
    return await _budgetDao.getReminders();
  }

  /// 更新预算提醒设置
  Future<void> updateReminder(int id, {
    bool? enabled,
    double? threshold,
    String? frequency,
  }) async {
    await _budgetDao.updateReminder(
      id,
      enabled: enabled,
      threshold: threshold,
      frequency: frequency,
    );

    // 更新缓存
    final budgets = await _budgetDao.getAll();
    await _cacheManager.cacheBudgets(budgets);
  }

  /// 获取预算分析报告
  Future<Map<String, dynamic>> getAnalysisReport(int id) async {
    return await _budgetDao.getAnalysisReport(id);
  }

  /// 从缓存获取预算列表
  Future<List<Budget>> _getCachedBudgets() async {
    return _cacheManager.getCachedBudgets() ?? [];
  }
} 