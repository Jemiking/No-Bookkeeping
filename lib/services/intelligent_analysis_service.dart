import 'dart:async';
import 'dart:math' as math;
import 'package:collection/collection.dart';

class ConsumptionPattern {
  final String category;
  final double averageAmount;
  final String frequency;
  final List<String> preferredMerchants;
  final Map<String, double> timeDistribution;

  ConsumptionPattern({
    required this.category,
    required this.averageAmount,
    required this.frequency,
    required this.preferredMerchants,
    required this.timeDistribution,
  });
}

class ExpensePrediction {
  final String category;
  final double predictedAmount;
  final double confidence;
  final String timeframe;
  final List<String> influencingFactors;

  ExpensePrediction({
    required this.category,
    required this.predictedAmount,
    required this.confidence,
    required this.timeframe,
    required this.influencingFactors,
  });
}

class AnomalyDetection {
  final String transactionId;
  final String category;
  final double amount;
  final String reason;
  final double deviationScore;
  final DateTime timestamp;

  AnomalyDetection({
    required this.transactionId,
    required this.category,
    required this.amount,
    required this.reason,
    required this.deviationScore,
    required this.timestamp,
  });
}

class BudgetSuggestion {
  final String category;
  final double suggestedAmount;
  final String basis;
  final List<String> optimizationTips;
  final double potentialSavings;

  BudgetSuggestion({
    required this.category,
    required this.suggestedAmount,
    required this.basis,
    required this.optimizationTips,
    required this.potentialSavings,
  });
}

class ProductRecommendation {
  final String productId;
  final String name;
  final String category;
  final double relevanceScore;
  final List<String> features;
  final String reason;

  ProductRecommendation({
    required this.productId,
    required this.name,
    required this.category,
    required this.relevanceScore,
    required this.features,
    required this.reason,
  });
}

class IntelligentAnalysisService {
  // 消费模式分析
  Future<List<ConsumptionPattern>> analyzeConsumptionPatterns(
    List<Map<String, dynamic>> transactions,
    {Duration timeWindow = const Duration(days: 90)}
  ) async {
    final patterns = <ConsumptionPattern>[];
    final categories = _groupTransactionsByCategory(transactions);
    
    for (final category in categories.keys) {
      final categoryTransactions = categories[category]!;
      
      // 计算平均消费金额
      final averageAmount = categoryTransactions
          .map((t) => t['amount'] as double)
          .average;
          
      // 分析消费频率
      final frequency = _analyzeFrequency(categoryTransactions);
      
      // 获取首选商家
      final preferredMerchants = _analyzePreferredMerchants(categoryTransactions);
      
      // 分析时间分布
      final timeDistribution = _analyzeTimeDistribution(categoryTransactions);
      
      patterns.add(ConsumptionPattern(
        category: category,
        averageAmount: averageAmount,
        frequency: frequency,
        preferredMerchants: preferredMerchants,
        timeDistribution: timeDistribution,
      ));
    }
    
    return patterns;
  }

  // 支出预测
  Future<List<ExpensePrediction>> predictExpenses(
    List<Map<String, dynamic>> historicalData,
    {int predictionMonths = 3}
  ) async {
    final predictions = <ExpensePrediction>[];
    final categories = _groupTransactionsByCategory(historicalData);
    
    for (final category in categories.keys) {
      final categoryData = categories[category]!;
      
      // 使用时间序列分析预测未来支出
      final predictedAmount = _predictAmountUsingTimeSeries(categoryData);
      
      // 计算预测置信度
      final confidence = _calculatePredictionConfidence(categoryData);
      
      // 识别影响因素
      final factors = _identifyInfluencingFactors(categoryData);
      
      predictions.add(ExpensePrediction(
        category: category,
        predictedAmount: predictedAmount,
        confidence: confidence,
        timeframe: '$predictionMonths months',
        influencingFactors: factors,
      ));
    }
    
    return predictions;
  }

  // 异常检测
  Future<List<AnomalyDetection>> detectAnomalies(
    List<Map<String, dynamic>> transactions,
    {double threshold = 2.0}
  ) async {
    final anomalies = <AnomalyDetection>[];
    final categories = _groupTransactionsByCategory(transactions);
    
    for (final category in categories.keys) {
      final categoryTransactions = categories[category]!;
      
      // 计算类别平均值和标准差
      final amounts = categoryTransactions
          .map((t) => t['amount'] as double)
          .toList();
      final mean = amounts.average;
      final stdDev = _calculateStandardDeviation(amounts);
      
      // 检测异常交易
      for (final transaction in categoryTransactions) {
        final amount = transaction['amount'] as double;
        final deviationScore = (amount - mean).abs() / stdDev;
        
        if (deviationScore > threshold) {
          anomalies.add(AnomalyDetection(
            transactionId: transaction['id'] as String,
            category: category,
            amount: amount,
            reason: _determineAnomalyReason(deviationScore, mean, amount),
            deviationScore: deviationScore,
            timestamp: DateTime.parse(transaction['timestamp'] as String),
          ));
        }
      }
    }
    
    return anomalies;
  }

  // 预算建议
  Future<List<BudgetSuggestion>> suggestBudgets(
    List<Map<String, dynamic>> transactions,
    Map<String, double> currentBudgets,
  ) async {
    final suggestions = <BudgetSuggestion>[];
    final patterns = await analyzeConsumptionPatterns(
      transactions,
      timeWindow: const Duration(days: 90),
    );
    
    for (final pattern in patterns) {
      final currentBudget = currentBudgets[pattern.category] ?? 0.0;
      final suggestedAmount = _calculateSuggestedBudget(
        pattern.averageAmount,
        currentBudget,
      );
      
      // 生成优化建议
      final optimizationTips = _generateOptimizationTips(
        pattern,
        currentBudget,
        suggestedAmount,
      );
      
      // 计算潜在节省
      final potentialSavings = currentBudget - suggestedAmount;
      
      suggestions.add(BudgetSuggestion(
        category: pattern.category,
        suggestedAmount: suggestedAmount,
        basis: _generateBudgetBasis(pattern),
        optimizationTips: optimizationTips,
        potentialSavings: potentialSavings > 0 ? potentialSavings : 0,
      ));
    }
    
    return suggestions;
  }

  // 产品推荐
  Future<List<ProductRecommendation>> recommendProducts(
    List<Map<String, dynamic>> transactions,
    List<Map<String, dynamic>> availableProducts,
  ) async {
    final recommendations = <ProductRecommendation>[];
    final patterns = await analyzeConsumptionPatterns(
      transactions,
      timeWindow: const Duration(days: 90),
    );
    
    for (final pattern in patterns) {
      // 基于消费模式匹配相关产品
      final relevantProducts = _findRelevantProducts(
        pattern,
        availableProducts,
      );
      
      for (final product in relevantProducts) {
        // 计算相关性得分
        final relevanceScore = _calculateRelevanceScore(
          pattern,
          product,
        );
        
        if (relevanceScore > 0.7) { // 只推荐相关性较高的产品
          recommendations.add(ProductRecommendation(
            productId: product['id'] as String,
            name: product['name'] as String,
            category: product['category'] as String,
            relevanceScore: relevanceScore,
            features: List<String>.from(product['features'] as List),
            reason: _generateRecommendationReason(pattern, product),
          ));
        }
      }
    }
    
    // 按相关性得分排序
    recommendations.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    
    return recommendations;
  }

  // 辅助方法
  Map<String, List<Map<String, dynamic>>> _groupTransactionsByCategory(
    List<Map<String, dynamic>> transactions,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    
    for (final transaction in transactions) {
      final category = transaction['category'] as String;
      grouped.update(
        category,
        (list) => list..add(transaction),
        ifAbsent: () => [transaction],
      );
    }
    
    return grouped;
  }

  String _analyzeFrequency(List<Map<String, dynamic>> transactions) {
    // 实现频率分析逻辑
    return 'weekly'; // 示例返回值
  }

  List<String> _analyzePreferredMerchants(
    List<Map<String, dynamic>> transactions,
  ) {
    // 实现首选商家分析逻辑
    return ['Merchant A', 'Merchant B']; // 示例返回值
  }

  Map<String, double> _analyzeTimeDistribution(
    List<Map<String, dynamic>> transactions,
  ) {
    // 实现时间分布分析逻辑
    return {'morning': 0.3, 'afternoon': 0.5, 'evening': 0.2}; // 示例返回值
  }

  double _predictAmountUsingTimeSeries(List<Map<String, dynamic>> data) {
    // 实现时间序列预测逻辑
    return 1000.0; // 示例返回值
  }

  double _calculatePredictionConfidence(List<Map<String, dynamic>> data) {
    // 实现置信度计算逻辑
    return 0.85; // 示例返回值
  }

  List<String> _identifyInfluencingFactors(List<Map<String, dynamic>> data) {
    // 实现影响因素识别逻辑
    return ['季节性', '节假日']; // 示例���回值
  }

  double _calculateStandardDeviation(List<double> values) {
    final mean = values.average;
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    return math.sqrt(squaredDiffs.average);
  }

  String _determineAnomalyReason(
    double deviationScore,
    double mean,
    double amount,
  ) {
    // 实现异常原因判断逻辑
    return '金额显著高于平均水平'; // 示例返回值
  }

  double _calculateSuggestedBudget(double averageAmount, double currentBudget) {
    // 实现预算建议计算逻辑
    return averageAmount * 1.1; // 示例返回值
  }

  List<String> _generateOptimizationTips(
    ConsumptionPattern pattern,
    double currentBudget,
    double suggestedAmount,
  ) {
    // 实现优化建议生成逻辑
    return ['减少非必要支出', '选择更经济的替代方案']; // 示例返回值
  }

  String _generateBudgetBasis(ConsumptionPattern pattern) {
    // 实现预算建议依据生成逻辑
    return '基于历史消费模式和当前收入水平'; // 示例返回值
  }

  List<Map<String, dynamic>> _findRelevantProducts(
    ConsumptionPattern pattern,
    List<Map<String, dynamic>> products,
  ) {
    // 实现相关产品查找逻辑
    return products.where((p) => p['category'] == pattern.category).toList();
  }

  double _calculateRelevanceScore(
    ConsumptionPattern pattern,
    Map<String, dynamic> product,
  ) {
    // 实现相关性得分计算逻辑
    return 0.8; // 示例返回值
  }

  String _generateRecommendationReason(
    ConsumptionPattern pattern,
    Map<String, dynamic> product,
  ) {
    // 实现推荐原因生成逻辑
    return '基于您的消费习惯和偏好'; // 示例返回值
  }

  // 预测支出
  Future<Map<String, double>> predictMonthlyExpenses({
    Duration timeWindow = const Duration(days: 90)
  }) async {
    // TODO: 实现月度支出预测
    return {};
  }

  // 检测异常
  Future<List<Map<String, dynamic>>> detectMonthlyAnomalies({
    double threshold = 2.0
  }) async {
    // TODO: 实现月度异常检测
    return [];
  }
} 