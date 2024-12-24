import 'package:collection/collection.dart';
import '../../transaction/models/transaction.dart';
import '../../category/models/category.dart';
import '../../tag/models/tag.dart';

/// 统计时间范围
enum StatisticsPeriod {
  day,
  week,
  month,
  quarter,
  year,
  custom
}

/// 统计维度
enum StatisticsDimension {
  category,
  tag,
  account,
  paymentMethod,
  custom
}

/// 统计类型
enum StatisticsType {
  income,
  expense,
  transfer,
  all
}

/// 统计结果
class StatisticsResult {
  final double totalAmount;
  final int transactionCount;
  final Map<String, double> distribution;
  final Map<DateTime, double> trend;
  final double? previousPeriodAmount;
  final double? yearOverYearAmount;
  final double periodGrowth;
  final double yearOverYearGrowth;

  StatisticsResult({
    required this.totalAmount,
    required this.transactionCount,
    required this.distribution,
    required this.trend,
    this.previousPeriodAmount,
    this.yearOverYearAmount,
    required this.periodGrowth,
    required this.yearOverYearGrowth,
  });
}

/// 统计引擎接口
abstract class StatisticsEngine {
  /// 收支统计
  Future<StatisticsResult> calculateIncomeExpenseStatistics({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    StatisticsPeriod period = StatisticsPeriod.month,
    List<String>? categoryIds,
    List<String>? accountIds,
    List<String>? tagIds,
  });

  /// 分类统计
  Future<Map<Category, StatisticsResult>> calculateCategoryStatistics({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    StatisticsPeriod period = StatisticsPeriod.month,
    List<String>? categoryIds,
  });

  /// 周期统计
  Future<Map<DateTime, StatisticsResult>> calculatePeriodStatistics({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    required StatisticsPeriod period,
    StatisticsDimension dimension = StatisticsDimension.category,
    List<String>? filterIds,
  });

  /// 同比环比分析
  Future<Map<String, double>> calculateGrowthRates({
    required DateTime date,
    required StatisticsType type,
    required StatisticsPeriod period,
    StatisticsDimension dimension = StatisticsDimension.category,
    List<String>? filterIds,
  });

  /// 自定义报表
  Future<Map<String, dynamic>> generateCustomReport({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    required StatisticsPeriod period,
    required StatisticsDimension dimension,
    required Map<String, dynamic> customParameters,
    List<String>? filterIds,
  });

  /// 获取统计趋势
  Future<Map<DateTime, double>> getStatisticsTrend({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    required StatisticsPeriod period,
    StatisticsDimension dimension = StatisticsDimension.category,
    List<String>? filterIds,
  });

  /// 获取Top N统计
  Future<List<MapEntry<String, double>>> getTopStatistics({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    required StatisticsDimension dimension,
    required int limit,
    List<String>? filterIds,
  });

  /// 获取统计摘要
  Future<Map<String, double>> getStatisticsSummary({
    required DateTime startDate,
    required DateTime endDate,
    required StatisticsType type,
    StatisticsDimension dimension = StatisticsDimension.category,
    List<String>? filterIds,
  });
} 