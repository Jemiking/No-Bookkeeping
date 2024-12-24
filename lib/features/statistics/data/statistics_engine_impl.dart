import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/statistics_engine.dart';
import '../../transaction/models/transaction.dart';
import '../../category/models/category.dart';
import '../../tag/models/tag.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../core/utils/logger.dart';

class StatisticsEngineImpl implements StatisticsEngine {
  final Database database;
  final Logger logger;

  StatisticsEngineImpl({
    required this.database,
    required this.logger,
  });

  @override
  Future<StatisticsResult> calculateIncomeExpenseStatistics({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    StatisticsPeriod period = StatisticsPeriod.month,
    List<String>? categoryIds,
    List<String>? accountIds,
    List<String>? tagIds,
  }) async {
    try {
      // 构建查询条件
      final conditions = <String>['date >= ? AND date <= ?'];
      final arguments = <dynamic>[
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ];

      if (type != StatisticsType.all) {
        conditions.add('type = ?');
        arguments.add(type.toString().split('.').last);
      }

      if (categoryIds != null && categoryIds.isNotEmpty) {
        conditions.add('category_id IN (${List.filled(categoryIds.length, '?').join(',')})');
        arguments.addAll(categoryIds);
      }

      if (accountIds != null && accountIds.isNotEmpty) {
        conditions.add('account_id IN (${List.filled(accountIds.length, '?').join(',')})');
        arguments.addAll(accountIds);
      }

      if (tagIds != null && tagIds.isNotEmpty) {
        conditions.add('EXISTS (SELECT 1 FROM transaction_tags WHERE transaction_id = transactions.id AND tag_id IN (${List.filled(tagIds.length, '?').join(',')}))');
        arguments.addAll(tagIds);
      }

      // 执行查询
      final result = await database.rawQuery('''
        SELECT 
          COUNT(*) as count,
          SUM(amount) as total,
          category_id,
          strftime('%Y-%m-%d', datetime(date/1000, 'unixepoch')) as date_str
        FROM transactions
        WHERE ${conditions.join(' AND ')}
        GROUP BY category_id, date_str
        ORDER BY date_str
      ''', arguments);

      // 计算总金额和交易数量
      final totalAmount = result.fold<double>(0, (sum, row) => sum + (row['total'] as double? ?? 0));
      final transactionCount = result.fold<int>(0, (sum, row) => sum + (row['count'] as int? ?? 0));

      // 计算分布
      final distribution = <String, double>{};
      for (final row in result) {
        final categoryId = row['category_id'] as String?;
        if (categoryId != null) {
          distribution[categoryId] = (distribution[categoryId] ?? 0) + (row['total'] as double? ?? 0);
        }
      }

      // 计算趋势
      final trend = <DateTime, double>{};
      for (final row in result) {
        final dateStr = row['date_str'] as String;
        final date = DateTime.parse(dateStr);
        trend[date] = (trend[date] ?? 0) + (row['total'] as double? ?? 0);
      }

      // 计算环比和同比
      final previousPeriodAmount = await _calculatePreviousPeriodAmount(
        startDate,
        endDate,
        type,
        period,
        conditions,
        arguments,
      );

      final yearOverYearAmount = await _calculateYearOverYearAmount(
        startDate,
        endDate,
        type,
        conditions,
        arguments,
      );

      final periodGrowth = previousPeriodAmount != 0
          ? (totalAmount - previousPeriodAmount) / previousPeriodAmount * 100
          : 0;

      final yearOverYearGrowth = yearOverYearAmount != 0
          ? (totalAmount - yearOverYearAmount) / yearOverYearAmount * 100
          : 0;

      return StatisticsResult(
        totalAmount: totalAmount,
        transactionCount: transactionCount,
        distribution: distribution,
        trend: trend,
        previousPeriodAmount: previousPeriodAmount,
        yearOverYearAmount: yearOverYearAmount,
        periodGrowth: periodGrowth,
        yearOverYearGrowth: yearOverYearGrowth,
      );
    } catch (e) {
      logger.error('计算收支统计失败：$e');
      rethrow;
    }
  }

  @override
  Future<Map<Category, StatisticsResult>> calculateCategoryStatistics({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    StatisticsPeriod period = StatisticsPeriod.month,
    List<String>? categoryIds,
  }) async {
    try {
      // 获取所有分类
      final categories = await _getCategories(categoryIds);
      
      // 计算每个分类的统计结果
      final results = <Category, StatisticsResult>{};
      for (final category in categories) {
        final result = await calculateIncomeExpenseStatistics(
          startDate: startDate,
          endDate: endDate,
          type: type,
          period: period,
          categoryIds: [category.id],
        );
        results[category] = result;
      }
      
      return results;
    } catch (e) {
      logger.error('计���分类统计失败：$e');
      rethrow;
    }
  }

  @override
  Future<Map<DateTime, StatisticsResult>> calculatePeriodStatistics({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    required StatisticsPeriod period,
    StatisticsDimension dimension = StatisticsDimension.category,
    List<String>? filterIds,
  }) async {
    try {
      // 生成时间区间
      final periods = date_utils.generatePeriods(startDate, endDate, period);
      
      // 计算每个时间区间的统计结果
      final results = <DateTime, StatisticsResult>{};
      for (final periodStart in periods) {
        final periodEnd = date_utils.getNextPeriod(periodStart, period);
        final result = await calculateIncomeExpenseStatistics(
          startDate: periodStart,
          endDate: periodEnd,
          type: type,
          period: period,
          categoryIds: dimension == StatisticsDimension.category ? filterIds : null,
          tagIds: dimension == StatisticsDimension.tag ? filterIds : null,
          accountIds: dimension == StatisticsDimension.account ? filterIds : null,
        );
        results[periodStart] = result;
      }
      
      return results;
    } catch (e) {
      logger.error('计算周期统计失败：$e');
      rethrow;
    }
  }

  @override
  Future<Map<String, double>> calculateGrowthRates({
    required DateTime date,
    required StatisticsType type,
    required StatisticsPeriod period,
    StatisticsDimension dimension = StatisticsDimension.category,
    List<String>? filterIds,
  }) async {
    try {
      // 计算当前期间的统计结果
      final currentPeriodEnd = date;
      final currentPeriodStart = date_utils.getPreviousPeriod(date, period);
      final currentResult = await calculateIncomeExpenseStatistics(
        startDate: currentPeriodStart,
        endDate: currentPeriodEnd,
        type: type,
        period: period,
        categoryIds: dimension == StatisticsDimension.category ? filterIds : null,
        tagIds: dimension == StatisticsDimension.tag ? filterIds : null,
        accountIds: dimension == StatisticsDimension.account ? filterIds : null,
      );

      // 计算上一期间的统计结果
      final previousPeriodEnd = currentPeriodStart;
      final previousPeriodStart = date_utils.getPreviousPeriod(previousPeriodEnd, period);
      final previousResult = await calculateIncomeExpenseStatistics(
        startDate: previousPeriodStart,
        endDate: previousPeriodEnd,
        type: type,
        period: period,
        categoryIds: dimension == StatisticsDimension.category ? filterIds : null,
        tagIds: dimension == StatisticsDimension.tag ? filterIds : null,
        accountIds: dimension == StatisticsDimension.account ? filterIds : null,
      );

      // 计算去年同期的统计结果
      final yearOverYearEnd = date_utils.minusOneYear(currentPeriodEnd);
      final yearOverYearStart = date_utils.minusOneYear(currentPeriodStart);
      final yearOverYearResult = await calculateIncomeExpenseStatistics(
        startDate: yearOverYearStart,
        endDate: yearOverYearEnd,
        type: type,
        period: period,
        categoryIds: dimension == StatisticsDimension.category ? filterIds : null,
        tagIds: dimension == StatisticsDimension.tag ? filterIds : null,
        accountIds: dimension == StatisticsDimension.account ? filterIds : null,
      );

      return {
        'current_amount': currentResult.totalAmount,
        'previous_amount': previousResult.totalAmount,
        'year_over_year_amount': yearOverYearResult.totalAmount,
        'period_growth': currentResult.periodGrowth,
        'year_over_year_growth': currentResult.yearOverYearGrowth,
      };
    } catch (e) {
      logger.error('计算增长率失败：$e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> generateCustomReport({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    required StatisticsPeriod period,
    required StatisticsDimension dimension,
    required Map<String, dynamic> customParameters,
    List<String>? filterIds,
  }) async {
    try {
      // 基础统计
      final baseStats = await calculateIncomeExpenseStatistics(
        startDate: startDate,
        endDate: endDate,
        type: type,
        period: period,
        categoryIds: dimension == StatisticsDimension.category ? filterIds : null,
        tagIds: dimension == StatisticsDimension.tag ? filterIds : null,
        accountIds: dimension == StatisticsDimension.account ? filterIds : null,
      );

      // 周期统计
      final periodStats = await calculatePeriodStatistics(
        startDate: startDate,
        endDate: endDate,
        type: type,
        period: period,
        dimension: dimension,
        filterIds: filterIds,
      );

      // 增长率
      final growthRates = await calculateGrowthRates(
        date: endDate,
        type: type,
        period: period,
        dimension: dimension,
        filterIds: filterIds,
      );

      // Top N统计
      final topStats = await getTopStatistics(
        startDate: startDate,
        endDate: endDate,
        type: type,
        dimension: dimension,
        limit: customParameters['top_n'] ?? 10,
        filterIds: filterIds,
      );

      return {
        'base_statistics': baseStats,
        'period_statistics': periodStats,
        'growth_rates': growthRates,
        'top_statistics': topStats,
        'custom_parameters': customParameters,
      };
    } catch (e) {
      logger.error('生成自定义报表失败：$e');
      rethrow;
    }
  }

  @override
  Future<Map<DateTime, double>> getStatisticsTrend({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    required StatisticsPeriod period,
    StatisticsDimension dimension = StatisticsDimension.category,
    List<String>? filterIds,
  }) async {
    try {
      final result = await calculateIncomeExpenseStatistics(
        startDate: startDate,
        endDate: endDate,
        type: type,
        period: period,
        categoryIds: dimension == StatisticsDimension.category ? filterIds : null,
        tagIds: dimension == StatisticsDimension.tag ? filterIds : null,
        accountIds: dimension == StatisticsDimension.account ? filterIds : null,
      );
      
      return result.trend;
    } catch (e) {
      logger.error('获取统计趋势失败：$e');
      rethrow;
    }
  }

  @override
  Future<List<MapEntry<String, double>>> getTopStatistics({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    required StatisticsDimension dimension,
    required int limit,
    List<String>? filterIds,
  }) async {
    try {
      final result = await calculateIncomeExpenseStatistics(
        startDate: startDate,
        endDate: endDate,
        type: type,
        categoryIds: dimension == StatisticsDimension.category ? filterIds : null,
        tagIds: dimension == StatisticsDimension.tag ? filterIds : null,
        accountIds: dimension == StatisticsDimension.account ? filterIds : null,
      );

      final sortedEntries = result.distribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedEntries.take(limit).toList();
    } catch (e) {
      logger.error('获取Top统计失败：$e');
      rethrow;
    }
  }

  @override
  Future<Map<String, double>> getStatisticsSummary({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    StatisticsDimension dimension = StatisticsDimension.category,
    List<String>? filterIds,
  }) async {
    try {
      final result = await calculateIncomeExpenseStatistics(
        startDate: startDate,
        endDate: endDate,
        type: type,
        categoryIds: dimension == StatisticsDimension.category ? filterIds : null,
        tagIds: dimension == StatisticsDimension.tag ? filterIds : null,
        accountIds: dimension == StatisticsDimension.account ? filterIds : null,
      );

      return {
        'total_amount': result.totalAmount,
        'transaction_count': result.transactionCount.toDouble(),
        'average_amount': result.transactionCount > 0
            ? result.totalAmount / result.transactionCount
            : 0,
        'period_growth': result.periodGrowth,
        'year_over_year_growth': result.yearOverYearGrowth,
      };
    } catch (e) {
      logger.error('获取统计摘要失败：$e');
      rethrow;
    }
  }

  // 私有辅助方法

  Future<List<Category>> _getCategories(List<String>? categoryIds) async {
    final List<Map<String, dynamic>> maps;
    if (categoryIds != null && categoryIds.isNotEmpty) {
      maps = await database.query(
        'categories',
        where: 'id IN (${List.filled(categoryIds.length, '?').join(',')})',
        whereArgs: categoryIds,
      );
    } else {
      maps = await database.query('categories');
    }
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<double> _calculatePreviousPeriodAmount(
    DateTime startDate,
    DateTime endDate,
    StatisticsType type,
    StatisticsPeriod period,
    List<String> conditions,
    List<dynamic> arguments,
  ) async {
    final previousStartDate = date_utils.getPreviousPeriod(startDate, period);
    final previousEndDate = date_utils.getPreviousPeriod(endDate, period);

    final previousResult = await database.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE ${conditions.join(' AND ')}
      AND date >= ? AND date <= ?
    ''', [
      ...arguments,
      previousStartDate.millisecondsSinceEpoch,
      previousEndDate.millisecondsSinceEpoch,
    ]);

    return previousResult.first['total'] as double? ?? 0;
  }

  Future<double> _calculateYearOverYearAmount(
    DateTime startDate,
    DateTime endDate,
    StatisticsType type,
    List<String> conditions,
    List<dynamic> arguments,
  ) async {
    final yearOverYearStartDate = date_utils.minusOneYear(startDate);
    final yearOverYearEndDate = date_utils.minusOneYear(endDate);

    final yearOverYearResult = await database.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE ${conditions.join(' AND ')}
      AND date >= ? AND date <= ?
    ''', [
      ...arguments,
      yearOverYearStartDate.millisecondsSinceEpoch,
      yearOverYearEndDate.millisecondsSinceEpoch,
    ]);

    return yearOverYearResult.first['total'] as double? ?? 0;
  }
} 