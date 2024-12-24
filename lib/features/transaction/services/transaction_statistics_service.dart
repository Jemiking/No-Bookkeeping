import 'package:collection/collection.dart';
import '../models/transaction.dart';

class TransactionStatistics {
  final double totalIncome;
  final double totalExpense;
  final double totalTransfer;
  final double netAmount;
  final Map<String, double> categoryDistribution;
  final Map<String, double> accountDistribution;
  final Map<String, double> tagDistribution;
  final Map<DateTime, double> dailyTrend;
  final Map<DateTime, double> monthlyTrend;
  final Map<String, List<Transaction>> groupedTransactions;

  TransactionStatistics({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalTransfer,
    required this.netAmount,
    required this.categoryDistribution,
    required this.accountDistribution,
    required this.tagDistribution,
    required this.dailyTrend,
    required this.monthlyTrend,
    required this.groupedTransactions,
  });
}

class TransactionStatisticsService {
  // 生成综合统计报告
  static TransactionStatistics generateStatistics(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    // 过滤日期范围内的交易
    final filteredTransactions = transactions.where((t) =>
      t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      t.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();

    // 计算总收入、支出和转账
    double totalIncome = 0;
    double totalExpense = 0;
    double totalTransfer = 0;

    for (var transaction in filteredTransactions) {
      switch (transaction.type) {
        case TransactionType.income:
          totalIncome += transaction.amount;
          break;
        case TransactionType.expense:
          totalExpense += transaction.amount;
          break;
        case TransactionType.transfer:
          totalTransfer += transaction.amount;
          break;
      }
    }

    // 计算净额
    final netAmount = totalIncome - totalExpense;

    // 按分类统计
    final categoryDistribution = _calculateDistribution(
      filteredTransactions,
      (t) => t.categoryId ?? 'uncategorized',
    );

    // 按账户统计
    final accountDistribution = _calculateDistribution(
      filteredTransactions,
      (t) => t.accountId,
    );

    // 按标签统计
    final tagDistribution = _calculateTagDistribution(filteredTransactions);

    // 计算日趋势
    final dailyTrend = _calculateDailyTrend(
      filteredTransactions,
      startDate,
      endDate,
    );

    // 计算月趋势
    final monthlyTrend = _calculateMonthlyTrend(
      filteredTransactions,
      startDate,
      endDate,
    );

    // 按自定义规则分组
    final groupedTransactions = _groupTransactions(filteredTransactions);

    return TransactionStatistics(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalTransfer: totalTransfer,
      netAmount: netAmount,
      categoryDistribution: categoryDistribution,
      accountDistribution: accountDistribution,
      tagDistribution: tagDistribution,
      dailyTrend: dailyTrend,
      monthlyTrend: monthlyTrend,
      groupedTransactions: groupedTransactions,
    );
  }

  // 计算分布
  static Map<String, double> _calculateDistribution(
    List<Transaction> transactions,
    String Function(Transaction) keyExtractor,
  ) {
    final distribution = <String, double>{};
    
    for (var transaction in transactions) {
      final key = keyExtractor(transaction);
      distribution[key] = (distribution[key] ?? 0) + transaction.amount;
    }
    
    return distribution;
  }

  // 计算标签分布
  static Map<String, double> _calculateTagDistribution(
    List<Transaction> transactions,
  ) {
    final distribution = <String, double>{};
    
    for (var transaction in transactions) {
      for (var tagId in transaction.tagIds) {
        distribution[tagId] = (distribution[tagId] ?? 0) + transaction.amount;
      }
    }
    
    return distribution;
  }

  // 计算日趋势
  static Map<DateTime, double> _calculateDailyTrend(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final trend = <DateTime, double>{};
    
    // 初始化所有日期
    for (var date = startDate;
         date.isBefore(endDate.add(const Duration(days: 1)));
         date = date.add(const Duration(days: 1))) {
      trend[DateTime(date.year, date.month, date.day)] = 0;
    }
    
    // 计算每日金额
    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      trend[date] = (trend[date] ?? 0) + transaction.amount;
    }
    
    return trend;
  }

  // 计算月趋势
  static Map<DateTime, double> _calculateMonthlyTrend(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final trend = <DateTime, double>{};
    
    // 初始化所有月份
    for (var date = DateTime(startDate.year, startDate.month);
         date.isBefore(DateTime(endDate.year, endDate.month + 1));
         date = DateTime(date.year, date.month + 1)) {
      trend[date] = 0;
    }
    
    // 计算每月金额
    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
      );
      trend[date] = (trend[date] ?? 0) + transaction.amount;
    }
    
    return trend;
  }

  // 按规则分组交易
  static Map<String, List<Transaction>> _groupTransactions(
    List<Transaction> transactions,
  ) {
    return groupBy(transactions, (Transaction t) {
      if (t.amount >= 10000) return 'large_amount';
      if (t.type == TransactionType.transfer) return 'transfers';
      if (t.tagIds.isNotEmpty) return 'tagged';
      return 'others';
    });
  }

  // 计算同比增长
  static double calculateYearOverYearGrowth(
    List<Transaction> currentPeriod,
    List<Transaction> previousPeriod,
  ) {
    final currentTotal = currentPeriod.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    
    final previousTotal = previousPeriod.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    
    if (previousTotal == 0) return 0;
    return (currentTotal - previousTotal) / previousTotal * 100;
  }

  // 计算环比增长
  static double calculateMonthOverMonthGrowth(
    List<Transaction> currentPeriod,
    List<Transaction> previousPeriod,
  ) {
    final currentTotal = currentPeriod.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    
    final previousTotal = previousPeriod.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    
    if (previousTotal == 0) return 0;
    return (currentTotal - previousTotal) / previousTotal * 100;
  }

  // 分析消费模式
  static Map<String, dynamic> analyzeSpendingPattern(
    List<Transaction> transactions,
  ) {
    // 按时间段分组
    final morningTransactions = transactions.where(
      (t) => t.date.hour >= 5 && t.date.hour < 12,
    ).toList();
    
    final afternoonTransactions = transactions.where(
      (t) => t.date.hour >= 12 && t.date.hour < 18,
    ).toList();
    
    final eveningTransactions = transactions.where(
      (t) => t.date.hour >= 18 || t.date.hour < 5,
    ).toList();

    // 计算各时段消费
    final morningTotal = morningTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    
    final afternoonTotal = afternoonTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    
    final eveningTotal = eveningTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    return {
      'morning': {
        'total': morningTotal,
        'count': morningTransactions.length,
        'average': morningTransactions.isEmpty
            ? 0
            : morningTotal / morningTransactions.length,
      },
      'afternoon': {
        'total': afternoonTotal,
        'count': afternoonTransactions.length,
        'average': afternoonTransactions.isEmpty
            ? 0
            : afternoonTotal / afternoonTransactions.length,
      },
      'evening': {
        'total': eveningTotal,
        'count': eveningTransactions.length,
        'average': eveningTransactions.isEmpty
            ? 0
            : eveningTotal / eveningTransactions.length,
      },
    };
  }
} 