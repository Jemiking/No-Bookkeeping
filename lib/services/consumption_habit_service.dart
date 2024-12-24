import 'package:collection/collection.dart';
import '../models/transaction.dart';
import '../utils/validation_utils.dart';

class ConsumptionHabit {
  final Map<String, double> weekdayDistribution;
  final Map<String, double> hourlyDistribution;
  final Map<String, double> locationDistribution;
  final Map<String, double> merchantDistribution;
  final Map<String, double> categoryCorrelation;
  final Map<String, List<String>> frequentCombinations;
  final List<String> insights;

  ConsumptionHabit({
    required this.weekdayDistribution,
    required this.hourlyDistribution,
    required this.locationDistribution,
    required this.merchantDistribution,
    required this.categoryCorrelation,
    required this.frequentCombinations,
    required this.insights,
  });
}

class ConsumptionHabitService {
  // 生成消费习惯分析
  static ConsumptionHabit generateHabitAnalysis({
    required List<Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // 参数验证
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotNull(startDate, 'startDate');
    ValidationUtils.validateNotNull(endDate, 'endDate');
    ValidationUtils.validateDateRange(startDate, endDate);

    // 过滤日期范围内的交易
    final filteredTransactions = transactions.where((t) =>
      t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      t.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();

    return ConsumptionHabit(
      weekdayDistribution: _analyzeWeekdayDistribution(filteredTransactions),
      hourlyDistribution: _analyzeHourlyDistribution(filteredTransactions),
      locationDistribution: _analyzeLocationDistribution(filteredTransactions),
      merchantDistribution: _analyzeMerchantDistribution(filteredTransactions),
      categoryCorrelation: _analyzeCategoryCorrelation(filteredTransactions),
      frequentCombinations: _analyzeFrequentCombinations(filteredTransactions),
      insights: _generateInsights(filteredTransactions),
    );
  }

  // 分析星期分布
  static Map<String, double> _analyzeWeekdayDistribution(List<Transaction> transactions) {
    final distribution = <String, double>{};
    final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekdayGroups = groupBy(
      transactions,
      (Transaction t) => t.date.weekday - 1,
    );

    for (var i = 0; i < 7; i++) {
      final transactions = weekdayGroups[i] ?? [];
      final totalAmount = transactions.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );
      distribution[weekdayNames[i]] = totalAmount;
    }

    return distribution;
  }

  // 分析时段分布
  static Map<String, double> _analyzeHourlyDistribution(List<Transaction> transactions) {
    final distribution = <String, double>{};
    final hourlyGroups = groupBy(
      transactions,
      (Transaction t) => t.date.hour,
    );

    for (var i = 0; i < 24; i++) {
      final transactions = hourlyGroups[i] ?? [];
      final totalAmount = transactions.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );
      distribution['${i.toString().padLeft(2, '0')}:00'] = totalAmount;
    }

    return distribution;
  }

  // 分析地点分布
  static Map<String, double> _analyzeLocationDistribution(List<Transaction> transactions) {
    final distribution = <String, double>{};
    final locationGroups = groupBy(
      transactions,
      (Transaction t) => t.location ?? '未知',
    );

    for (var entry in locationGroups.entries) {
      final totalAmount = entry.value.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );
      distribution[entry.key] = totalAmount;
    }

    return distribution;
  }

  // 分析商家分布
  static Map<String, double> _analyzeMerchantDistribution(List<Transaction> transactions) {
    final distribution = <String, double>{};
    final merchantGroups = groupBy(
      transactions,
      (Transaction t) => t.merchant ?? '未知',
    );

    for (var entry in merchantGroups.entries) {
      final totalAmount = entry.value.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );
      distribution[entry.key] = totalAmount;
    }

    return distribution;
  }

  // 分析分类相关性
  static Map<String, double> _analyzeCategoryCorrelation(List<Transaction> transactions) {
    final correlation = <String, double>{};
    final categoryGroups = groupBy(
      transactions,
      (Transaction t) => t.categoryId ?? '未分类',
    );

    // 分析同一天内出现的分类组合
    final dailyGroups = groupBy(
      transactions,
      (Transaction t) => t.date.toString().split(' ')[0],
    );

    for (var dayTransactions in dailyGroups.values) {
      final categories = dayTransactions.map((t) => t.categoryId ?? '未分类').toSet();
      for (var category1 in categories) {
        for (var category2 in categories) {
          if (category1 != category2) {
            final key = '${category1}-${category2}';
            correlation[key] = (correlation[key] ?? 0) + 1;
          }
        }
      }
    }

    // 计算相关性系数
    final totalDays = dailyGroups.length;
    correlation.forEach((key, value) {
      correlation[key] = value / totalDays;
    });

    return correlation;
  }

  // 分析频繁组合
  static Map<String, List<String>> _analyzeFrequentCombinations(List<Transaction> transactions) {
    final combinations = <String, List<String>>{};
    final dailyGroups = groupBy(
      transactions,
      (Transaction t) => t.date.toString().split(' ')[0],
    );

    // 统计每天的消费组合
    final dailyCombinations = <String>[];
    for (var dayTransactions in dailyGroups.values) {
      final categories = dayTransactions.map((t) => t.categoryId ?? '未分类').toList();
      if (categories.length >= 2) {
        categories.sort();
        dailyCombinations.add(categories.join('-'));
      }
    }

    // 找出频繁组合
    final combinationGroups = groupBy(dailyCombinations, (String c) => c);
    combinationGroups.forEach((combination, occurrences) {
      if (occurrences.length >= 3) { // 至少出现3次的组合
        final categories = combination.split('-');
        combinations[combination] = categories;
      }
    });

    return combinations;
  }

  // 生成消费习惯洞察
  static List<String> _generateInsights(List<Transaction> transactions) {
    final insights = <String>[];

    // 分析消费时间习惯
    final weekdayDistribution = _analyzeWeekdayDistribution(transactions);
    final hourlyDistribution = _analyzeHourlyDistribution(transactions);

    // 找出消费最多的星期
    var maxWeekdayAmount = 0.0;
    var maxWeekday = '';
    weekdayDistribution.forEach((weekday, amount) {
      if (amount > maxWeekdayAmount) {
        maxWeekdayAmount = amount;
        maxWeekday = weekday;
      }
    });
    insights.add('您在$maxWeekday的消费最多，请注意合理安排支出');

    // 找出消费高峰时段
    var maxHourAmount = 0.0;
    var maxHour = '';
    hourlyDistribution.forEach((hour, amount) {
      if (amount > maxHourAmount) {
        maxHourAmount = amount;
        maxHour = hour;
      }
    });
    insights.add('消费高峰时段在$maxHour，建议避开高峰期消费');

    // 分析消费地点习惯
    final locationDistribution = _analyzeLocationDistribution(transactions);
    var maxLocationAmount = 0.0;
    var maxLocation = '';
    locationDistribution.forEach((location, amount) {
      if (amount > maxLocationAmount) {
        maxLocationAmount = amount;
        maxLocation = location;
      }
    });
    if (maxLocation != '未知') {
      insights.add('您在$maxLocation的消费最多，建议关���该地区的优惠信息');
    }

    // 分析商家消费习惯
    final merchantDistribution = _analyzeMerchantDistribution(transactions);
    var maxMerchantAmount = 0.0;
    var maxMerchant = '';
    merchantDistribution.forEach((merchant, amount) {
      if (amount > maxMerchantAmount) {
        maxMerchantAmount = amount;
        maxMerchant = merchant;
      }
    });
    if (maxMerchant != '未知') {
      insights.add('您在$maxMerchant的消费最多，建议关注该商家的会员优惠');
    }

    // 分析频繁组合
    final combinations = _analyzeFrequentCombinations(transactions);
    if (combinations.isNotEmpty) {
      final firstCombination = combinations.entries.first;
      insights.add('您经常同时消费的类别是：${firstCombination.value.join('、')}，建议合理规划这些支出');
    }

    return insights;
  }
} 