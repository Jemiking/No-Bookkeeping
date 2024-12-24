import '../database/dao/statistics_dao.dart';
import '../database/models/transaction.dart';
import '../cache/cache_manager.dart';

/// 统计服务类
class StatisticsService {
  final StatisticsDao _statisticsDao;
  final CacheManager _cacheManager;

  /// 构造函数
  StatisticsService(this._statisticsDao, this._cacheManager);

  /// 获取收支统计
  Future<Map<String, dynamic>> getIncomeExpenseStats({
    DateTime? startDate,
    DateTime? endDate,
    String? period = 'month',
    List<int>? accountIds,
    List<int>? categoryIds,
    List<int>? tagIds,
  }) async {
    // 先从缓存获取
    final cacheKey = _buildCacheKey(
      'income_expense',
      startDate,
      endDate,
      period,
      accountIds,
      categoryIds,
      tagIds,
    );
    final cachedStats = await _cacheManager.getCachedStats(cacheKey);
    if (cachedStats != null) {
      return cachedStats;
    }

    // 从数据库获取
    final stats = await _statisticsDao.getIncomeExpenseStats(
      startDate: startDate,
      endDate: endDate,
      period: period,
      accountIds: accountIds,
      categoryIds: categoryIds,
      tagIds: tagIds,
    );

    // 更新缓存
    await _cacheManager.cacheStats(cacheKey, stats);

    return stats;
  }

  /// 获取分类统计
  Future<List<Map<String, dynamic>>> getCategoryStats({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    List<int>? accountIds,
    List<int>? categoryIds,
    List<int>? tagIds,
  }) async {
    // 先从缓存获取
    final cacheKey = _buildCacheKey(
      'category',
      startDate,
      endDate,
      type?.toString(),
      accountIds,
      categoryIds,
      tagIds,
    );
    final cachedStats = await _cacheManager.getCachedStats(cacheKey);
    if (cachedStats != null) {
      return List<Map<String, dynamic>>.from(cachedStats);
    }

    // 从数据库获取
    final stats = await _statisticsDao.getCategoryStats(
      startDate: startDate,
      endDate: endDate,
      type: type,
      accountIds: accountIds,
      categoryIds: categoryIds,
      tagIds: tagIds,
    );

    // 更新缓存
    await _cacheManager.cacheStats(cacheKey, stats);

    return stats;
  }

  /// 获取趋势分析
  Future<List<Map<String, dynamic>>> getTrendAnalysis({
    DateTime? startDate,
    DateTime? endDate,
    String? period = 'month',
    TransactionType? type,
    List<int>? accountIds,
    List<int>? categoryIds,
    List<int>? tagIds,
  }) async {
    // 先从缓存获取
    final cacheKey = _buildCacheKey(
      'trend',
      startDate,
      endDate,
      period,
      type?.toString(),
      accountIds,
      categoryIds,
      tagIds,
    );
    final cachedStats = await _cacheManager.getCachedStats(cacheKey);
    if (cachedStats != null) {
      return List<Map<String, dynamic>>.from(cachedStats);
    }

    // 从数据库获取
    final stats = await _statisticsDao.getTrendAnalysis(
      startDate: startDate,
      endDate: endDate,
      period: period,
      type: type,
      accountIds: accountIds,
      categoryIds: categoryIds,
      tagIds: tagIds,
    );

    // 更新缓存
    await _cacheManager.cacheStats(cacheKey, stats);

    return stats;
  }

  /// 获取账户统计
  Future<List<Map<String, dynamic>>> getAccountStats({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
  }) async {
    // 先从缓存获取
    final cacheKey = _buildCacheKey(
      'account',
      startDate,
      endDate,
      accountIds,
    );
    final cachedStats = await _cacheManager.getCachedStats(cacheKey);
    if (cachedStats != null) {
      return List<Map<String, dynamic>>.from(cachedStats);
    }

    // 从数据库获取
    final stats = await _statisticsDao.getAccountStats(
      startDate: startDate,
      endDate: endDate,
      accountIds: accountIds,
    );

    // 更新缓存
    await _cacheManager.cacheStats(cacheKey, stats);

    return stats;
  }

  /// 获取标签统计
  Future<List<Map<String, dynamic>>> getTagStats({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    List<int>? accountIds,
    List<int>? tagIds,
  }) async {
    // 先从缓存获取
    final cacheKey = _buildCacheKey(
      'tag',
      startDate,
      endDate,
      type?.toString(),
      accountIds,
      tagIds,
    );
    final cachedStats = await _cacheManager.getCachedStats(cacheKey);
    if (cachedStats != null) {
      return List<Map<String, dynamic>>.from(cachedStats);
    }

    // 从数据库获取
    final stats = await _statisticsDao.getTagStats(
      startDate: startDate,
      endDate: endDate,
      type: type,
      accountIds: accountIds,
      tagIds: tagIds,
    );

    // 更新缓存
    await _cacheManager.cacheStats(cacheKey, stats);

    return stats;
  }

  /// 获取预算执行统计
  Future<List<Map<String, dynamic>>> getBudgetStats({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? budgetIds,
  }) async {
    // 先从缓存获取
    final cacheKey = _buildCacheKey(
      'budget',
      startDate,
      endDate,
      budgetIds,
    );
    final cachedStats = await _cacheManager.getCachedStats(cacheKey);
    if (cachedStats != null) {
      return List<Map<String, dynamic>>.from(cachedStats);
    }

    // 从数据库获取
    final stats = await _statisticsDao.getBudgetStats(
      startDate: startDate,
      endDate: endDate,
      budgetIds: budgetIds,
    );

    // 更新缓存
    await _cacheManager.cacheStats(cacheKey, stats);

    return stats;
  }

  /// 获取财务分析报告
  Future<Map<String, dynamic>> getFinancialReport({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
  }) async {
    // 先从缓存获取
    final cacheKey = _buildCacheKey(
      'financial_report',
      startDate,
      endDate,
      accountIds,
    );
    final cachedReport = await _cacheManager.getCachedStats(cacheKey);
    if (cachedReport != null) {
      return cachedReport;
    }

    // 从数据库获取
    final report = await _statisticsDao.getFinancialReport(
      startDate: startDate,
      endDate: endDate,
      accountIds: accountIds,
    );

    // 更新缓存
    await _cacheManager.cacheStats(cacheKey, report);

    return report;
  }

  /// 构建缓存键
  String _buildCacheKey(String prefix, [dynamic ...params]) {
    final key = StringBuffer(prefix);
    for (final param in params) {
      if (param != null) {
        if (param is List) {
          key.write('_${param.join(',')}');
        } else {
          key.write('_$param');
        }
      }
    }
    return key.toString();
  }
} 