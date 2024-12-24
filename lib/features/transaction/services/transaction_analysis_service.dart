import 'package:collection/collection.dart';
import '../models/transaction.dart';
import '../../tag/models/tag.dart';
import '../../../core/utils/validation_utils.dart';

class TransactionAnalysis {
  final Map<String, double> categoryTrends;
  final Map<String, double> monthlyTrends;
  final Map<String, double> weekdayDistribution;
  final Map<String, double> hourlyDistribution;
  final Map<String, double> tagCorrelations;
  final Map<String, List<Transaction>> anomalies;
  final Map<String, double> recurringPatterns;
  final Map<String, double> seasonalPatterns;
  final Map<String, double> categoryPredictions;

  TransactionAnalysis({
    required this.categoryTrends,
    required this.monthlyTrends,
    required this.weekdayDistribution,
    required this.hourlyDistribution,
    required this.tagCorrelations,
    required this.anomalies,
    required this.recurringPatterns,
    required this.seasonalPatterns,
    required this.categoryPredictions,
  }) {
    ValidationUtils.validateNotNull(categoryTrends, 'categoryTrends');
    ValidationUtils.validateNotNull(monthlyTrends, 'monthlyTrends');
    ValidationUtils.validateNotNull(weekdayDistribution, 'weekdayDistribution');
    ValidationUtils.validateNotNull(hourlyDistribution, 'hourlyDistribution');
    ValidationUtils.validateNotNull(tagCorrelations, 'tagCorrelations');
    ValidationUtils.validateNotNull(anomalies, 'anomalies');
    ValidationUtils.validateNotNull(recurringPatterns, 'recurringPatterns');
    ValidationUtils.validateNotNull(seasonalPatterns, 'seasonalPatterns');
    ValidationUtils.validateNotNull(categoryPredictions, 'categoryPredictions');
  }
}

class TransactionAnalysisService {
  // 生成高级分析报表
  static TransactionAnalysis generateAnalysis(
    List<Transaction> transactions,
    List<Tag> tags,
    DateTime startDate,
    DateTime endDate,
  ) {
    // 参数验证
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotEmpty(tags, 'tags');
    ValidationUtils.validateNotNull(startDate, 'startDate');
    ValidationUtils.validateNotNull(endDate, 'endDate');
    ValidationUtils.validateDateRange(startDate, endDate);

    // 过滤日期范围内的交易
    final filteredTransactions = transactions.where((t) =>
      t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      t.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();

    return TransactionAnalysis(
      categoryTrends: _analyzeCategoryTrends(filteredTransactions),
      monthlyTrends: _analyzeMonthlyTrends(filteredTransactions),
      weekdayDistribution: _analyzeWeekdayDistribution(filteredTransactions),
      hourlyDistribution: _analyzeHourlyDistribution(filteredTransactions),
      tagCorrelations: _analyzeTagCorrelations(filteredTransactions, tags),
      anomalies: _detectAnomalies(filteredTransactions),
      recurringPatterns: _analyzeRecurringPatterns(filteredTransactions),
      seasonalPatterns: _analyzeSeasonalPatterns(filteredTransactions),
      categoryPredictions: _predictCategoryTrends(filteredTransactions),
    );
  }

  // 分析分类趋势
  static Map<String, double> _analyzeCategoryTrends(
    List<Transaction> transactions,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');

    final trends = <String, double>{};
    final categoryGroups = groupBy(
      transactions,
      (Transaction t) => t.categoryId ?? 'uncategorized',
    );

    for (var entry in categoryGroups.entries) {
      final monthlyAmounts = <int, double>{};
      
      // 按月份分组计算金额
      for (var transaction in entry.value) {
        final monthKey = transaction.date.year * 12 + transaction.date.month;
        monthlyAmounts[monthKey] = (monthlyAmounts[monthKey] ?? 0) + transaction.amount;
      }

      // 计算趋势（简单线性回归）
      if (monthlyAmounts.length > 1) {
        final xValues = monthlyAmounts.keys.toList();
        final yValues = monthlyAmounts.values.toList();
        final slope = _calculateSlope(xValues, yValues);
        trends[entry.key] = slope;
      }
    }

    return trends;
  }

  // 分析月度趋势
  static Map<String, double> _analyzeMonthlyTrends(
    List<Transaction> transactions,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');

    final trends = <String, double>{};
    final monthlyGroups = groupBy(
      transactions,
      (Transaction t) => '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}',
    );

    // 计算每月总额
    for (var entry in monthlyGroups.entries) {
      final totalAmount = entry.value.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );
      trends[entry.key] = totalAmount;
    }

    return trends;
  }

  // 分析星期分布
  static Map<String, double> _analyzeWeekdayDistribution(
    List<Transaction> transactions,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');

    final distribution = <String, double>{};
    final weekdayGroups = groupBy(
      transactions,
      (Transaction t) => t.date.weekday.toString(),
    );

    for (var entry in weekdayGroups.entries) {
      final totalAmount = entry.value.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );
      distribution[entry.key] = totalAmount;
    }

    return distribution;
  }

  // 分析小时分布
  static Map<String, double> _analyzeHourlyDistribution(
    List<Transaction> transactions,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');

    final distribution = <String, double>{};
    final hourlyGroups = groupBy(
      transactions,
      (Transaction t) => t.date.hour.toString(),
    );

    for (var entry in hourlyGroups.entries) {
      final totalAmount = entry.value.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );
      distribution[entry.key] = totalAmount;
    }

    return distribution;
  }

  // 分析标签相关性
  static Map<String, double> _analyzeTagCorrelations(
    List<Transaction> transactions,
    List<Tag> tags,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotEmpty(tags, 'tags');

    final correlations = <String, double>{};
    
    // 计算标签对之间的相关性
    for (var i = 0; i < tags.length; i++) {
      for (var j = i + 1; j < tags.length; j++) {
        final tag1 = tags[i];
        final tag2 = tags[j];
        
        ValidationUtils.validateNotNull(tag1.id, 'tag1.id');
        ValidationUtils.validateNotNull(tag2.id, 'tag2.id');

        final tag1Transactions = transactions
            .where((t) => t.tagIds.contains(tag1.id))
            .toList();
        final tag2Transactions = transactions
            .where((t) => t.tagIds.contains(tag2.id))
            .toList();
        
        // 计算共现次数
        final cooccurrence = transactions
            .where((t) => t.tagIds.contains(tag1.id) && t.tagIds.contains(tag2.id))
            .length;
        
        // 计算相关系数
        final denominator = tag1Transactions.length + tag2Transactions.length - cooccurrence;
        final correlation = denominator > 0 ? cooccurrence / denominator : 0;
        
        correlations['${tag1.id}-${tag2.id}'] = correlation;
      }
    }

    return correlations;
  }

  // 检测异常交易
  static Map<String, List<Transaction>> _detectAnomalies(
    List<Transaction> transactions,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');

    final anomalies = <String, List<Transaction>>{};
    
    // 按分类分组
    final categoryGroups = groupBy(
      transactions,
      (Transaction t) => t.categoryId ?? 'uncategorized',
    );

    for (var entry in categoryGroups.entries) {
      final amounts = entry.value.map((t) => t.amount).toList();
      
      if (amounts.isEmpty) continue;

      // 计算均值和标准差
      final mean = amounts.average;
      final stdDev = _calculateStandardDeviation(amounts, mean);
      
      // 检测异常值（超过3个标准差）
      final anomalousTransactions = entry.value.where((t) {
        return (t.amount - mean).abs() > 3 * stdDev;
      }).toList();
      
      if (anomalousTransactions.isNotEmpty) {
        anomalies[entry.key] = anomalousTransactions;
      }
    }

    return anomalies;
  }

  // 分析重复模式
  static Map<String, double> _analyzeRecurringPatterns(
    List<Transaction> transactions,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');

    final patterns = <String, double>{};
    final categoryGroups = groupBy(
      transactions,
      (Transaction t) => t.categoryId ?? 'uncategorized',
    );

    for (var entry in categoryGroups.entries) {
      // 按金额分组
      final amountGroups = groupBy(
        entry.value,
        (Transaction t) => t.amount.toStringAsFixed(2),
      );

      // 查找重复交易
      for (var amountEntry in amountGroups.entries) {
        if (amountEntry.value.length >= 2) {
          // 计算交易间隔
          final dates = amountEntry.value
              .map((t) => t.date)
              .toList()
              ..sort();
          
          final intervals = <int>[];
          for (var i = 1; i < dates.length; i++) {
            intervals.add(
              dates[i].difference(dates[i - 1]).inDays,
            );
          }

          // 如果间隔相近，认为是重复模式
          if (_isRegularInterval(intervals)) {
            patterns['${entry.key}-${amountEntry.key}'] =
                intervals.average;
          }
        }
      }
    }

    return patterns;
  }

  // 分析季节性模式
  static Map<String, double> _analyzeSeasonalPatterns(
    List<Transaction> transactions,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');

    final patterns = <String, double>{};
    final monthlyGroups = groupBy(
      transactions,
      (Transaction t) => t.date.month.toString(),
    );

    // 计算每月平均金额
    for (var entry in monthlyGroups.entries) {
      if (entry.value.isEmpty) continue;

      final averageAmount = entry.value.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      ) / entry.value.length;
      
      patterns[entry.key] = averageAmount;
    }

    return patterns;
  }

  // 预测分类趋势
  static Map<String, double> _predictCategoryTrends(
    List<Transaction> transactions,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');

    final predictions = <String, double>{};
    final categoryGroups = groupBy(
      transactions,
      (Transaction t) => t.categoryId ?? 'uncategorized',
    );

    for (var entry in categoryGroups.entries) {
      // 按月份分组
      final monthlyAmounts = <int, double>{};
      for (var transaction in entry.value) {
        final monthKey = transaction.date.year * 12 + transaction.date.month;
        monthlyAmounts[monthKey] = (monthlyAmounts[monthKey] ?? 0) + transaction.amount;
      }

      if (monthlyAmounts.length >= 3) {
        // 使用简单移动平均预测
        final values = monthlyAmounts.values.toList();
        final prediction = _calculateMovingAverage(values, 3).last;
        predictions[entry.key] = prediction;
      }
    }

    return predictions;
  }

  // 计算斜率（线性回归）
  static double _calculateSlope(List<int> x, List<double> y) {
    ValidationUtils.validateNotNull(x, 'x');
    ValidationUtils.validateNotNull(y, 'y');
    ValidationUtils.validateNotEmpty(x, 'x');
    ValidationUtils.validateNotEmpty(y, 'y');
    if (x.length != y.length) {
      throw ValidationException(
        'Input lists must have the same length',
        invalidValue: {'x.length': x.length, 'y.length': y.length},
      );
    }

    final n = x.length;
    final xMean = x.average;
    final yMean = y.average;
    
    double numerator = 0;
    double denominator = 0;
    
    for (var i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (y[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }
    
    return denominator != 0 ? numerator / denominator : 0;
  }

  // 计算标准差
  static double _calculateStandardDeviation(List<double> values, double mean) {
    ValidationUtils.validateNotNull(values, 'values');
    ValidationUtils.validateNotEmpty(values, 'values');
    
    if (values.isEmpty) return 0;
    
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    return sqrt(squaredDiffs.sum / values.length);
  }

  // 检查是否为规律间隔
  static bool _isRegularInterval(List<int> intervals) {
    ValidationUtils.validateNotNull(intervals, 'intervals');
    
    if (intervals.isEmpty) return false;
    
    final mean = intervals.average;
    final tolerance = mean * 0.2; // 允许20%的误差
    
    return intervals.every((interval) =>
      (interval - mean).abs() <= tolerance
    );
  }

  // 计算移动平均
  static List<double> _calculateMovingAverage(
    List<double> values,
    int window,
  ) {
    ValidationUtils.validateNotNull(values, 'values');
    ValidationUtils.validateNotEmpty(values, 'values');
    ValidationUtils.validatePositive(window, 'window');
    if (window > values.length) {
      throw ValidationException(
        'Window size cannot be larger than values length',
        invalidValue: {'window': window, 'values.length': values.length},
      );
    }

    final result = <double>[];
    
    for (var i = window - 1; i < values.length; i++) {
      var sum = 0.0;
      for (var j = 0; j < window; j++) {
        sum += values[i - j];
      }
      result.add(sum / window);
    }
    
    return result;
  }

  // 计算平方根
  static double sqrt(double value) {
    ValidationUtils.validateNonNegative(value, 'value');
    
    if (value <= 0) return 0;
    
    double guess = value / 2;
    double previousGuess = 0;
    
    while ((guess - previousGuess).abs() > 1e-10) {
      previousGuess = guess;
      guess = (guess + value / guess) / 2;
    }
    
    return guess;
  }
} 