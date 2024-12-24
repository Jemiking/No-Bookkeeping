import 'package:collection/collection.dart';
import '../models/tag.dart';
import '../../transaction/models/transaction.dart';
import '../../../core/utils/validation_utils.dart';

class TagRecommendationService {
  // 基于历史交易推荐标签
  static List<Tag> recommendTagsBasedOnHistory(
    Transaction newTransaction,
    List<Transaction> historicalTransactions,
    List<Tag> availableTags,
  ) {
    // 参数验证
    ValidationUtils.validateNotNull(newTransaction, 'newTransaction');
    ValidationUtils.validateNotEmpty(historicalTransactions, 'historicalTransactions');
    ValidationUtils.validateNotEmpty(availableTags, 'availableTags');

    // 按相似度排序的历史交易
    final similarTransactions = _findSimilarTransactions(
      newTransaction,
      historicalTransactions,
    );

    // 收集历史交易中使用的标签及其权重
    final tagWeights = _calculateTagWeights(similarTransactions);

    // 根据权重排序并返回推荐标签
    return _getRecommendedTags(tagWeights, availableTags);
  }

  // 基于交易描述推荐标签
  static List<Tag> recommendTagsBasedOnDescription(
    String description,
    List<Transaction> historicalTransactions,
    List<Tag> availableTags,
  ) {
    // 参数验证
    ValidationUtils.validateStringNotEmpty(description, 'description');
    ValidationUtils.validateNotEmpty(historicalTransactions, 'historicalTransactions');
    ValidationUtils.validateNotEmpty(availableTags, 'availableTags');

    // 分词处理
    final keywords = _extractKeywords(description.toLowerCase());

    // 计算每个标签与关键词的相关性
    final tagRelevance = _calculateTagRelevance(
      keywords,
      historicalTransactions,
      availableTags,
    );

    // 返回相关性最高的标签
    return _getRecommendedTagsByRelevance(tagRelevance, availableTags);
  }

  // 基于交易金额和类型推荐标签
  static List<Tag> recommendTagsBasedOnAmountAndType(
    Transaction newTransaction,
    List<Transaction> historicalTransactions,
    List<Tag> availableTags,
  ) {
    // 参数验证
    ValidationUtils.validateNotNull(newTransaction, 'newTransaction');
    ValidationUtils.validateNotEmpty(historicalTransactions, 'historicalTransactions');
    ValidationUtils.validateNotEmpty(availableTags, 'availableTags');
    ValidationUtils.validateAmount(newTransaction.amount);

    // 查找金额范围相似的交易
    final similarAmountTransactions = historicalTransactions.where((t) {
      if (newTransaction.amount == 0) return t.amount == 0;
      final amountDiff = (t.amount - newTransaction.amount).abs();
      return amountDiff / newTransaction.amount <= 0.2; // 金额差异在20%以内
    }).toList();

    // 筛选相同类型的交易
    final sameTypeTransactions = similarAmountTransactions
        .where((t) => t.type == newTransaction.type)
        .toList();

    // 计算标签权重
    final tagWeights = _calculateTagWeights(sameTypeTransactions);

    // 返回推荐标签
    return _getRecommendedTags(tagWeights, availableTags);
  }

  // 基于时间模式推荐标签
  static List<Tag> recommendTagsBasedOnTimePattern(
    DateTime transactionTime,
    List<Transaction> historicalTransactions,
    List<Tag> availableTags,
  ) {
    // 参数验证
    ValidationUtils.validateNotNull(transactionTime, 'transactionTime');
    ValidationUtils.validateNotEmpty(historicalTransactions, 'historicalTransactions');
    ValidationUtils.validateNotEmpty(availableTags, 'availableTags');

    // 查找相似时间段的交易
    final similarTimeTransactions = historicalTransactions.where((t) {
      return t.date.hour == transactionTime.hour &&
             t.date.minute - transactionTime.minute <= 30; // 30分钟内
    }).toList();

    // 计算标签权重
    final tagWeights = _calculateTagWeights(similarTimeTransactions);

    // 返回推荐标签
    return _getRecommendedTags(tagWeights, availableTags);
  }

  // 查找相似交易
  static List<Transaction> _findSimilarTransactions(
    Transaction newTransaction,
    List<Transaction> historicalTransactions,
  ) {
    ValidationUtils.validateNotNull(newTransaction, 'newTransaction');
    ValidationUtils.validateNotEmpty(historicalTransactions, 'historicalTransactions');

    return historicalTransactions
        .map((t) => MapEntry(t, _calculateTransactionSimilarity(newTransaction, t)))
        .sorted((a, b) => b.value.compareTo(a.value))
        .take(10)
        .map((e) => e.key)
        .toList();
  }

  // 计算交易相似度
  static double _calculateTransactionSimilarity(
    Transaction t1,
    Transaction t2,
  ) {
    ValidationUtils.validateNotNull(t1, 't1');
    ValidationUtils.validateNotNull(t2, 't2');

    double similarity = 0;

    // 类型相同
    if (t1.type == t2.type) similarity += 0.3;

    // 金额相似度
    final amountDiff = (t1.amount - t2.amount).abs();
    if (t1.amount != 0) {
      if (amountDiff <= t1.amount * 0.1) similarity += 0.3;
      else if (amountDiff <= t1.amount * 0.2) similarity += 0.2;
      else if (amountDiff <= t1.amount * 0.3) similarity += 0.1;
    } else if (t2.amount == 0) {
      similarity += 0.3;
    }

    // 描述相似度
    if (t1.description != null && t2.description != null) {
      final desc1 = _extractKeywords(t1.description!.toLowerCase());
      final desc2 = _extractKeywords(t2.description!.toLowerCase());
      if (desc1.isNotEmpty) {
        final commonWords = desc1.intersection(desc2);
        similarity += 0.4 * commonWords.length / desc1.length;
      }
    }

    return similarity;
  }

  // 计算标签权重
  static Map<String, double> _calculateTagWeights(List<Transaction> transactions) {
    ValidationUtils.validateNotNull(transactions, 'transactions');

    final weights = <String, double>{};
    final totalTransactions = transactions.length;

    if (totalTransactions == 0) return weights;

    // 计算每个标签的出现频率
    for (var transaction in transactions) {
      for (var tagId in transaction.tagIds) {
        weights[tagId] = (weights[tagId] ?? 0) + 1;
      }
    }

    // 归一化权重
    weights.forEach((tagId, count) {
      weights[tagId] = count / totalTransactions;
    });

    return weights;
  }

  // 提取关键词
  static Set<String> _extractKeywords(String text) {
    ValidationUtils.validateNotNull(text, 'text');

    // 简单的分词处理，实际项目中可以使用更复杂的分词算法
    return text
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toSet();
  }

  // 计算标签相关性
  static Map<String, double> _calculateTagRelevance(
    Set<String> keywords,
    List<Transaction> historicalTransactions,
    List<Tag> availableTags,
  ) {
    ValidationUtils.validateNotNull(keywords, 'keywords');
    ValidationUtils.validateNotEmpty(historicalTransactions, 'historicalTransactions');
    ValidationUtils.validateNotEmpty(availableTags, 'availableTags');

    final relevance = <String, double>{};

    if (keywords.isEmpty) return relevance;

    for (var tag in availableTags) {
      // 计算标签名称与关键词的匹配度
      final tagKeywords = _extractKeywords(tag.name.toLowerCase());
      final commonWords = keywords.intersection(tagKeywords);
      double score = commonWords.length / keywords.length;

      // 考虑历史使用频率
      final usageCount = historicalTransactions
          .where((t) => t.tagIds.contains(tag.id))
          .length;
      score += 0.5 * usageCount / historicalTransactions.length;

      relevance[tag.id] = score;
    }

    return relevance;
  }

  // 获取推荐标签
  static List<Tag> _getRecommendedTags(
    Map<String, double> tagWeights,
    List<Tag> availableTags,
  ) {
    ValidationUtils.validateNotNull(tagWeights, 'tagWeights');
    ValidationUtils.validateNotEmpty(availableTags, 'availableTags');

    // 按权重排序
    final sortedTagIds = tagWeights.entries
        .sorted((a, b) => b.value.compareTo(a.value))
        .take(5)
        .map((e) => e.key)
        .toList();

    // 转换为Tag对象
    return sortedTagIds
        .map((id) => availableTags.firstWhere(
              (tag) => tag.id == id,
              orElse: () => throw ValidationException(
                'Tag not found',
                invalidValue: id,
                paramName: 'tagId',
              ),
            ))
        .toList();
  }

  // 获取基于相关性的推荐标签
  static List<Tag> _getRecommendedTagsByRelevance(
    Map<String, double> tagRelevance,
    List<Tag> availableTags,
  ) {
    ValidationUtils.validateNotNull(tagRelevance, 'tagRelevance');
    ValidationUtils.validateNotEmpty(availableTags, 'availableTags');

    // 按相关性排序
    final sortedTagIds = tagRelevance.entries
        .sorted((a, b) => b.value.compareTo(a.value))
        .take(5)
        .map((e) => e.key)
        .toList();

    // 转换为Tag对象
    return sortedTagIds
        .map((id) => availableTags.firstWhere(
              (tag) => tag.id == id,
              orElse: () => throw ValidationException(
                'Tag not found',
                invalidValue: id,
                paramName: 'tagId',
              ),
            ))
        .toList();
  }
} 