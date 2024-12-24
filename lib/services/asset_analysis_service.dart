import 'package:collection/collection.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../utils/validation_utils.dart';

class AssetAnalysis {
  final Map<String, double> assetDistribution;
  final Map<String, double> assetTrends;
  final Map<String, double> assetGrowth;
  final Map<String, double> returnRates;
  final Map<String, double> riskMetrics;
  final Map<String, List<double>> historicalValues;
  final List<String> recommendations;

  AssetAnalysis({
    required this.assetDistribution,
    required this.assetTrends,
    required this.assetGrowth,
    required this.returnRates,
    required this.riskMetrics,
    required this.historicalValues,
    required this.recommendations,
  });
}

class AssetAnalysisService {
  // 生成资产分析报告
  static AssetAnalysis generateAnalysis({
    required List<Account> accounts,
    required List<Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // 参数验证
    ValidationUtils.validateNotNull(accounts, 'accounts');
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotNull(startDate, 'startDate');
    ValidationUtils.validateNotNull(endDate, 'endDate');
    ValidationUtils.validateDateRange(startDate, endDate);

    // 过滤日期范围内的交易
    final filteredTransactions = transactions.where((t) =>
      t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      t.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();

    return AssetAnalysis(
      assetDistribution: _analyzeAssetDistribution(accounts),
      assetTrends: _analyzeAssetTrends(accounts, filteredTransactions),
      assetGrowth: _analyzeAssetGrowth(accounts, filteredTransactions),
      returnRates: _calculateReturnRates(accounts, filteredTransactions),
      riskMetrics: _calculateRiskMetrics(accounts, filteredTransactions),
      historicalValues: _calculateHistoricalValues(accounts, filteredTransactions),
      recommendations: _generateRecommendations(accounts, filteredTransactions),
    );
  }

  // 分析资产分布
  static Map<String, double> _analyzeAssetDistribution(List<Account> accounts) {
    final distribution = <String, double>{};
    final totalAssets = accounts.fold<double>(
      0,
      (sum, account) => sum + account.balance,
    );

    for (var account in accounts) {
      distribution[account.name] = (account.balance / totalAssets) * 100;
    }

    return distribution;
  }

  // 分析资产趋势
  static Map<String, double> _analyzeAssetTrends(
    List<Account> accounts,
    List<Transaction> transactions,
  ) {
    final trends = <String, double>{};
    final monthlyGroups = groupBy(
      transactions,
      (Transaction t) => '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}',
    );

    for (var entry in monthlyGroups.entries) {
      final totalAssets = accounts.fold<double>(
        0,
        (sum, account) => sum + _calculateAccountBalanceAtDate(
          account,
          transactions,
          DateTime.parse('${entry.key}-01'),
        ),
      );
      trends[entry.key] = totalAssets;
    }

    return trends;
  }

  // 分析资产增长
  static Map<String, double> _analyzeAssetGrowth(
    List<Account> accounts,
    List<Transaction> transactions,
  ) {
    final growth = <String, double>{};
    
    for (var account in accounts) {
      final initialBalance = _calculateAccountBalanceAtDate(
        account,
        transactions,
        transactions.first.date,
      );
      final finalBalance = account.balance;
      
      if (initialBalance != 0) {
        growth[account.name] = ((finalBalance - initialBalance) / initialBalance) * 100;
      } else {
        growth[account.name] = 0;
      }
    }

    return growth;
  }

  // 计算收益率
  static Map<String, double> _calculateReturnRates(
    List<Account> accounts,
    List<Transaction> transactions,
  ) {
    final returnRates = <String, double>{};
    
    for (var account in accounts) {
      final monthlyBalances = <double>[];
      var currentDate = transactions.first.date;
      final lastDate = transactions.last.date;
      
      while (currentDate.isBefore(lastDate)) {
        monthlyBalances.add(_calculateAccountBalanceAtDate(
          account,
          transactions,
          currentDate,
        ));
        currentDate = DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
      }
      
      if (monthlyBalances.length >= 2) {
        final initialBalance = monthlyBalances.first;
        final finalBalance = monthlyBalances.last;
        final months = monthlyBalances.length - 1;
        
        if (initialBalance != 0) {
          // 计算年化收益率
          final annualizedReturn = (pow((finalBalance / initialBalance), (12 / months)) - 1) * 100;
          returnRates[account.name] = annualizedReturn;
        } else {
          returnRates[account.name] = 0;
        }
      }
    }

    return returnRates;
  }

  // 计算风险指标
  static Map<String, double> _calculateRiskMetrics(
    List<Account> accounts,
    List<Transaction> transactions,
  ) {
    final riskMetrics = <String, double>{};
    
    for (var account in accounts) {
      final monthlyReturns = <double>[];
      var currentDate = transactions.first.date;
      final lastDate = transactions.last.date;
      var previousBalance = _calculateAccountBalanceAtDate(
        account,
        transactions,
        currentDate,
      );
      
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
      while (currentDate.isBefore(lastDate)) {
        final currentBalance = _calculateAccountBalanceAtDate(
          account,
          transactions,
          currentDate,
        );
        
        if (previousBalance != 0) {
          final monthlyReturn = ((currentBalance - previousBalance) / previousBalance) * 100;
          monthlyReturns.add(monthlyReturn);
        }
        
        previousBalance = currentBalance;
        currentDate = DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
      }
      
      if (monthlyReturns.isNotEmpty) {
        // 计算波动率（标准差）
        final mean = monthlyReturns.average;
        final squaredDiffs = monthlyReturns.map((r) => pow(r - mean, 2));
        final variance = squaredDiffs.average;
        final volatility = sqrt(variance);
        
        riskMetrics[account.name] = volatility;
      } else {
        riskMetrics[account.name] = 0;
      }
    }

    return riskMetrics;
  }

  // 计算历史价值
  static Map<String, List<double>> _calculateHistoricalValues(
    List<Account> accounts,
    List<Transaction> transactions,
  ) {
    final historicalValues = <String, List<double>>{};
    
    for (var account in accounts) {
      final values = <double>[];
      var currentDate = transactions.first.date;
      final lastDate = transactions.last.date;
      
      while (currentDate.isBefore(lastDate)) {
        values.add(_calculateAccountBalanceAtDate(
          account,
          transactions,
          currentDate,
        ));
        currentDate = DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
      }
      
      historicalValues[account.name] = values;
    }

    return historicalValues;
  }

  // 生成投资建议
  static List<String> _generateRecommendations(
    List<Account> accounts,
    List<Transaction> transactions,
  ) {
    final recommendations = <String>[];
    
    // 分析资产分布
    final distribution = _analyzeAssetDistribution(accounts);
    final maxPercentage = distribution.values.reduce(max);
    if (maxPercentage > 50) {
      final concentratedAsset = distribution.entries
          .firstWhere((entry) => entry.value == maxPercentage);
      recommendations.add(
        '您在${concentratedAsset.key}的资产占比过高(${maxPercentage.toStringAsFixed(1)}%)，'
        '建议适当分散投资以降低风险',
      );
    }

    // 分析收益率
    final returnRates = _calculateReturnRates(accounts, transactions);
    final avgReturn = returnRates.values.average;
    if (avgReturn < 0) {
      recommendations.add(
        '您的整体投资收益率为负(${avgReturn.toStringAsFixed(1)}%)，'
        '建议重新评估投资策略',
      );
    }

    // 分析风险
    final riskMetrics = _calculateRiskMetrics(accounts, transactions);
    final avgRisk = riskMetrics.values.average;
    if (avgRisk > 20) {
      recommendations.add(
        '您的投资组合波动率较高(${avgRisk.toStringAsFixed(1)}%)，'
        '建议适当增加稳健型资产的配置',
      );
    }

    // 分析增长趋势
    final growth = _analyzeAssetGrowth(accounts, transactions);
    final avgGrowth = growth.values.average;
    if (avgGrowth < 5) {
      recommendations.add(
        '您的资产增长率较低(${avgGrowth.toStringAsFixed(1)}%)，'
        '建议寻找更好的投资机会',
      );
    }

    return recommendations;
  }

  // 计算指定日期的账户余额
  static double _calculateAccountBalanceAtDate(
    Account account,
    List<Transaction> transactions,
    DateTime date,
  ) {
    final relevantTransactions = transactions.where((t) =>
      t.accountId == account.id &&
      t.date.isBefore(date.add(const Duration(days: 1)))
    ).toList();

    return relevantTransactions.fold<double>(
      0,
      (balance, transaction) => balance + transaction.amount,
    );
  }
}

// 辅助函数：计算幂
double pow(double x, double exponent) {
  return exp(log(x) * exponent);
}

// 辅助函数：计算平方根
double sqrt(double x) {
  return pow(x, 0.5);
}

// 辅助函数：计算自然对数
double log(double x) {
  return ln(x);
}

// 辅助函数：计算e的x次方
double exp(double x) {
  return e * x;
}

// 常量：自然对数的底数e
const double e = 2.718281828459045; 