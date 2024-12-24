import 'package:collection/collection.dart';
import '../models/transaction.dart';
import '../../tag/models/tag.dart';
import '../../../core/utils/validation_utils.dart';

enum StatisticsDimension {
  category,
  tag,
  date,
  amount,
  custom
}

enum AggregationType {
  sum,
  average,
  count,
  maximum,
  minimum
}

class StatisticsFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categoryIds;
  final List<String>? tagIds;
  final double? minAmount;
  final double? maxAmount;
  final String? customField;
  final String? customValue;

  StatisticsFilter({
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.tagIds,
    this.minAmount,
    this.maxAmount,
    this.customField,
    this.customValue,
  }) {
    // 验证日期范围
    ValidationUtils.validateDateRange(startDate, endDate);

    // 验证金额范围
    if (minAmount != null) ValidationUtils.validateAmount(minAmount!);
    if (maxAmount != null) ValidationUtils.validateAmount(maxAmount!);
    if (minAmount != null && maxAmount != null && minAmount! > maxAmount!) {
      throw ValidationException(
        'Minimum amount cannot be greater than maximum amount',
        invalidValue: {'minAmount': minAmount, 'maxAmount': maxAmount},
      );
    }

    // 验证分类ID
    if (categoryIds != null) {
      ValidationUtils.validateNotEmpty(categoryIds!, 'categoryIds');
      for (var id in categoryIds!) {
        ValidationUtils.validateId(id, 'categoryId');
      }
    }

    // 验证标签ID
    if (tagIds != null) {
      ValidationUtils.validateNotEmpty(tagIds!, 'tagIds');
      for (var id in tagIds!) {
        ValidationUtils.validateId(id, 'tagId');
      }
    }

    // 验证自定义字段
    if (customField != null) {
      ValidationUtils.validateStringNotEmpty(customField!, 'customField');
      ValidationUtils.validateNotNull(customValue, 'customValue');
    }
  }

  bool matches(Transaction transaction) {
    ValidationUtils.validateNotNull(transaction, 'transaction');

    if (startDate != null && transaction.date.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && transaction.date.isAfter(endDate!)) {
      return false;
    }
    if (categoryIds != null && !categoryIds!.contains(transaction.categoryId)) {
      return false;
    }
    if (tagIds != null && !tagIds!.any((id) => transaction.tagIds.contains(id))) {
      return false;
    }
    if (minAmount != null && transaction.amount < minAmount!) {
      return false;
    }
    if (maxAmount != null && transaction.amount > maxAmount!) {
      return false;
    }
    if (customField != null && customValue != null) {
      // 根据自定义字段进行过滤
      switch (customField) {
        case 'description':
          return transaction.description?.contains(customValue!) ?? false;
        case 'paymentMethod':
          return transaction.paymentMethod == customValue;
        // 添加更多自定义字段的处理
        default:
          return true;
      }
    }
    return true;
  }
}

class StatisticsResult {
  final Map<String, dynamic> data;
  final StatisticsDimension dimension;
  final AggregationType aggregationType;
  final int totalCount;
  final double totalAmount;

  StatisticsResult({
    required this.data,
    required this.dimension,
    required this.aggregationType,
    required this.totalCount,
    required this.totalAmount,
  }) {
    ValidationUtils.validateNotNull(data, 'data');
    ValidationUtils.validateNotNull(dimension, 'dimension');
    ValidationUtils.validateNotNull(aggregationType, 'aggregationType');
    ValidationUtils.validateNonNegative(totalCount, 'totalCount');
    ValidationUtils.validateAmount(totalAmount);
  }
}

class CustomStatisticsService {
  static StatisticsResult generateStatistics({
    required List<Transaction> transactions,
    required List<Tag> tags,
    required StatisticsDimension dimension,
    required AggregationType aggregationType,
    StatisticsFilter? filter,
  }) {
    // 参数验证
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotEmpty(tags, 'tags');
    ValidationUtils.validateNotNull(dimension, 'dimension');
    ValidationUtils.validateNotNull(aggregationType, 'aggregationType');
    if (filter != null) {
      ValidationUtils.validateNotNull(filter, 'filter');
    }

    // 应用过滤器
    var filteredTransactions = transactions;
    if (filter != null) {
      filteredTransactions = transactions
          .where((t) => filter.matches(t))
          .toList();
    }

    // 计算总计
    final totalCount = filteredTransactions.length;
    final totalAmount = filteredTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    // 根据维度分组
    final groupedData = _groupByDimension(
      filteredTransactions,
      dimension,
      tags,
    );

    // 根据聚合类型计算结果
    final result = _aggregate(
      groupedData,
      aggregationType,
    );

    return StatisticsResult(
      data: result,
      dimension: dimension,
      aggregationType: aggregationType,
      totalCount: totalCount,
      totalAmount: totalAmount,
    );
  }

  static Map<String, List<Transaction>> _groupByDimension(
    List<Transaction> transactions,
    StatisticsDimension dimension,
    List<Tag> tags,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotNull(dimension, 'dimension');
    ValidationUtils.validateNotEmpty(tags, 'tags');

    switch (dimension) {
      case StatisticsDimension.category:
        return groupBy(
          transactions,
          (Transaction t) => t.categoryId ?? 'uncategorized',
        );
      
      case StatisticsDimension.tag:
        final result = <String, List<Transaction>>{};
        // 一个交易可能有多个标签，需要特殊处理
        for (var transaction in transactions) {
          for (var tagId in transaction.tagIds) {
            ValidationUtils.validateId(tagId, 'tagId');
            if (!result.containsKey(tagId)) {
              result[tagId] = [];
            }
            result[tagId]!.add(transaction);
          }
        }
        return result;
      
      case StatisticsDimension.date:
        return groupBy(
          transactions,
          (Transaction t) => '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}',
        );
      
      case StatisticsDimension.amount:
        // 按金额范围分组
        return groupBy(
          transactions,
          (Transaction t) {
            ValidationUtils.validateAmount(t.amount);
            if (t.amount < 100) return '<100';
            if (t.amount < 500) return '100-500';
            if (t.amount < 1000) return '500-1000';
            if (t.amount < 5000) return '1000-5000';
            return '>5000';
          },
        );
      
      case StatisticsDimension.custom:
        // 可以根据需要添加更多自定义维度
        return groupBy(
          transactions,
          (Transaction t) => t.paymentMethod,
        );
      
      default:
        throw ValidationException(
          'Unsupported statistics dimension',
          invalidValue: dimension,
        );
    }
  }

  static Map<String, dynamic> _aggregate(
    Map<String, List<Transaction>> groupedData,
    AggregationType aggregationType,
  ) {
    ValidationUtils.validateNotNull(groupedData, 'groupedData');
    ValidationUtils.validateNotNull(aggregationType, 'aggregationType');

    final result = <String, dynamic>{};

    for (var entry in groupedData.entries) {
      switch (aggregationType) {
        case AggregationType.sum:
          result[entry.key] = entry.value.fold<double>(
            0,
            (sum, t) => sum + t.amount,
          );
          break;
        
        case AggregationType.average:
          if (entry.value.isNotEmpty) {
            result[entry.key] = entry.value.fold<double>(
              0,
              (sum, t) => sum + t.amount,
            ) / entry.value.length;
          } else {
            result[entry.key] = 0.0;
          }
          break;
        
        case AggregationType.count:
          result[entry.key] = entry.value.length;
          break;
        
        case AggregationType.maximum:
          if (entry.value.isNotEmpty) {
            result[entry.key] = entry.value
                .map((t) => t.amount)
                .reduce((a, b) => a > b ? a : b);
          } else {
            result[entry.key] = 0.0;
          }
          break;
        
        case AggregationType.minimum:
          if (entry.value.isNotEmpty) {
            result[entry.key] = entry.value
                .map((t) => t.amount)
                .reduce((a, b) => a < b ? a : b);
          } else {
            result[entry.key] = 0.0;
          }
          break;
        
        default:
          throw ValidationException(
            'Unsupported aggregation type',
            invalidValue: aggregationType,
          );
      }
    }

    return result;
  }
} 