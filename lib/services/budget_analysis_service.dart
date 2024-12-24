import 'package:collection/collection.dart';
import '../models/budget.dart';
import '../models/category_budget.dart';
import '../models/periodic_budget.dart';
import '../utils/validation_utils.dart';

class BudgetAnalysis {
  final Map<String, double> categoryDistribution;
  final Map<String, double> monthlyTrends;
  final Map<String, double> budgetUtilization;
  final Map<String, double> savingsRate;
  final Map<String, List<double>> historicalPerformance;
  final Map<String, double> predictedSpending;
  final List<String> recommendations;

  BudgetAnalysis({
    required this.categoryDistribution,
    required this.monthlyTrends,
    required this.budgetUtilization,
    required this.savingsRate,
    required this.historicalPerformance,
    required this.predictedSpending,
    required this.recommendations,
  });
}

class BudgetAnalysisService {
  // 生成预算分析报告
  static BudgetAnalysis generateAnalysis({
    required List<Budget> budgets,
    required List<CategoryBudget> categoryBudgets,
    required List<PeriodicBudget> periodicBudgets,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // 参数验证
    ValidationUtils.validateNotNull(budgets, 'budgets');
    ValidationUtils.validateNotNull(categoryBudgets, 'categoryBudgets');
    ValidationUtils.validateNotNull(periodicBudgets, 'periodicBudgets');
    ValidationUtils.validateNotNull(startDate, 'startDate');
    ValidationUtils.validateNotNull(endDate, 'endDate');
    ValidationUtils.validateDateRange(startDate, endDate);

    return BudgetAnalysis(
      categoryDistribution: _analyzeCategoryDistribution(categoryBudgets),
      monthlyTrends: _analyzeMonthlyTrends(budgets),
      budgetUtilization: _analyzeBudgetUtilization(budgets, categoryBudgets, periodicBudgets),
      savingsRate: _analyzeSavingsRate(budgets),
      historicalPerformance: _analyzeHistoricalPerformance(budgets, categoryBudgets, periodicBudgets),
      predictedSpending: _predictFutureSpending(budgets, categoryBudgets, periodicBudgets),
      recommendations: _generateRecommendations(budgets, categoryBudgets, periodicBudgets),
    );
  }

  // 分析分类预算分布
  static Map<String, double> _analyzeCategoryDistribution(
    List<CategoryBudget> categoryBudgets,
  ) {
    final distribution = <String, double>{};
    final totalBudget = categoryBudgets.fold<double>(
      0,
      (sum, budget) => sum + budget.amount,
    );

    for (var budget in categoryBudgets) {
      distribution[budget.categoryId] = (budget.amount / totalBudget) * 100;
    }

    return distribution;
  }

  // 分析月度趋势
  static Map<String, double> _analyzeMonthlyTrends(List<Budget> budgets) {
    final trends = <String, double>{};
    final monthlyGroups = groupBy(
      budgets,
      (Budget b) => '${b.startDate.year}-${b.startDate.month.toString().padLeft(2, '0')}',
    );

    for (var entry in monthlyGroups.entries) {
      final totalAmount = entry.value.fold<double>(
        0,
        (sum, b) => sum + b.amount,
      );
      trends[entry.key] = totalAmount;
    }

    return trends;
  }

  // 分析预算使用率
  static Map<String, double> _analyzeBudgetUtilization(
    List<Budget> budgets,
    List<CategoryBudget> categoryBudgets,
    List<PeriodicBudget> periodicBudgets,
  ) {
    final utilization = <String, double>{};

    // 总预算使用率
    for (var budget in budgets) {
      utilization['总预算'] = (budget.spent / budget.amount) * 100;
    }

    // 分类预算使用率
    for (var budget in categoryBudgets) {
      utilization['分类-${budget.categoryId}'] = (budget.spent / budget.amount) * 100;
    }

    // 周期预算使用率
    for (var budget in periodicBudgets) {
      utilization['周期-${budget.id}'] = (budget.spent / budget.amount) * 100;
    }

    return utilization;
  }

  // 分析节省率
  static Map<String, double> _analyzeSavingsRate(List<Budget> budgets) {
    final savingsRate = <String, double>{};

    for (var budget in budgets) {
      final savings = budget.amount - budget.spent;
      savingsRate[budget.id] = (savings / budget.amount) * 100;
    }

    return savingsRate;
  }

  // 分析历史表现
  static Map<String, List<double>> _analyzeHistoricalPerformance(
    List<Budget> budgets,
    List<CategoryBudget> categoryBudgets,
    List<PeriodicBudget> periodicBudgets,
  ) {
    final performance = <String, List<double>>{};

    // 总预算历史表现
    performance['总预算'] = budgets.map((b) => (b.spent / b.amount) * 100).toList();

    // 分类预算历史表现
    final categoryGroups = groupBy(categoryBudgets, (b) => b.categoryId);
    for (var entry in categoryGroups.entries) {
      performance['分类-${entry.key}'] = entry.value
          .map((b) => (b.spent / b.amount) * 100)
          .toList();
    }

    // 周期预算历史表现
    for (var budget in periodicBudgets) {
      performance['周期-${budget.id}'] = [
        (budget.spent / budget.amount) * 100
      ];
    }

    return performance;
  }

  // 预测未来支出
  static Map<String, double> _predictFutureSpending(
    List<Budget> budgets,
    List<CategoryBudget> categoryBudgets,
    List<PeriodicBudget> periodicBudgets,
  ) {
    final predictions = <String, double>{};

    // 使用简单移动平均预测
    // 总预算预测
    if (budgets.length >= 3) {
      final spentValues = budgets.map((b) => b.spent).toList();
      predictions['总预算'] = _calculateMovingAverage(spentValues, 3).last;
    }

    // 分类预算预测
    final categoryGroups = groupBy(categoryBudgets, (b) => b.categoryId);
    for (var entry in categoryGroups.entries) {
      if (entry.value.length >= 3) {
        final spentValues = entry.value.map((b) => b.spent).toList();
        predictions['分类-${entry.key}'] = _calculateMovingAverage(spentValues, 3).last;
      }
    }

    return predictions;
  }

  // 生成预算建议
  static List<String> _generateRecommendations(
    List<Budget> budgets,
    List<CategoryBudget> categoryBudgets,
    List<PeriodicBudget> periodicBudgets,
  ) {
    final recommendations = <String>[];

    // 分析总预算使用情况
    for (var budget in budgets) {
      final utilizationRate = (budget.spent / budget.amount) * 100;
      if (utilizationRate > 90) {
        recommendations.add('总预算使用率已达${utilizationRate.toStringAsFixed(1)}%，建议增加预算或控制支出');
      } else if (utilizationRate < 50) {
        recommendations.add('总预算使用率较低(${utilizationRate.toStringAsFixed(1)}%)，可以考虑调整预算金额');
      }
    }

    // 分析分类预算
    for (var budget in categoryBudgets) {
      final utilizationRate = (budget.spent / budget.amount) * 100;
      if (utilizationRate > 90) {
        recommendations.add('分类"${budget.categoryId}"预算即将用完，建议调整预算或控制支出');
      }
    }

    // 分析周期预算
    for (var budget in periodicBudgets) {
      final utilizationRate = (budget.spent / budget.amount) * 100;
      if (utilizationRate > 90) {
        recommendations.add('周期预算"${budget.name}"使用率过高，建议适当调整');
      }
    }

    return recommendations;
  }

  // 计算移动平均
  static List<double> _calculateMovingAverage(List<double> values, int period) {
    if (values.length < period) return values;

    final result = <double>[];
    for (var i = 0; i <= values.length - period; i++) {
      final sum = values.sublist(i, i + period).reduce((a, b) => a + b);
      result.add(sum / period);
    }
    return result;
  }
} 