import 'package:collection/collection.dart';
import '../models/tag.dart';
import '../../transaction/models/transaction.dart';
import '../../../core/utils/validation_utils.dart';

enum TagFilterMode {
  and, // 包含所有标签
  or, // 包含任一标签
  not, // 不包含指定标签
  exclusive, // 仅包含指定标签
}

enum TagFilterTimeRange {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

class TagFilterCriteria {
  final List<String> tagIds;
  final TagFilterMode mode;
  final TagFilterTimeRange timeRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final double? minAmount;
  final double? maxAmount;
  final List<TransactionType>? transactionTypes;
  final List<String>? categoryIds;
  final bool? isRecurring;
  final String? searchText;

  TagFilterCriteria({
    required this.tagIds,
    this.mode = TagFilterMode.and,
    this.timeRange = TagFilterTimeRange.thisMonth,
    this.customStartDate,
    this.customEndDate,
    this.minAmount,
    this.maxAmount,
    this.transactionTypes,
    this.categoryIds,
    this.isRecurring,
    this.searchText,
  }) {
    // 参数验证
    ValidationUtils.validateNotEmpty(tagIds, 'tagIds');
    ValidationUtils.validateNotNull(mode, 'mode');
    ValidationUtils.validateNotNull(timeRange, 'timeRange');
    
    // 验证自定义日期范围
    if (timeRange == TagFilterTimeRange.custom) {
      ValidationUtils.validateNotNull(customStartDate, 'customStartDate');
      ValidationUtils.validateNotNull(customEndDate, 'customEndDate');
      ValidationUtils.validateDateRange(customStartDate, customEndDate);
    }

    // 验证金额范围
    if (minAmount != null) ValidationUtils.validateAmount(minAmount!);
    if (maxAmount != null) ValidationUtils.validateAmount(maxAmount!);
    if (minAmount != null && maxAmount != null) {
      if (minAmount! > maxAmount!) {
        throw ValidationException(
          'Minimum amount cannot be greater than maximum amount',
          invalidValue: {'minAmount': minAmount, 'maxAmount': maxAmount},
        );
      }
    }

    // 验证分类ID
    if (categoryIds != null) {
      ValidationUtils.validateNotEmpty(categoryIds!, 'categoryIds');
      for (var id in categoryIds!) {
        ValidationUtils.validateId(id, 'categoryId');
      }
    }

    // 验证标签ID
    for (var id in tagIds) {
      ValidationUtils.validateId(id, 'tagId');
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

class TagFilterService {
  // 高级筛选
  static List<Transaction> filterTransactions(
    List<Transaction> transactions,
    TagFilterCriteria criteria,
  ) {
    // 参数验证
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotNull(criteria, 'criteria');

    // 应用标签筛选
    var filteredTransactions = _filterByTags(
      transactions,
      criteria.tagIds,
      criteria.mode,
    );

    // 应用时间范围筛选
    filteredTransactions = _filterByTimeRange(
      filteredTransactions,
      criteria.timeRange,
      criteria.customStartDate,
      criteria.customEndDate,
    );

    // 应用金额范围筛选
    if (criteria.minAmount != null || criteria.maxAmount != null) {
      filteredTransactions = _filterByAmount(
        filteredTransactions,
        criteria.minAmount,
        criteria.maxAmount,
      );
    }

    // 应用交易类型筛选
    if (criteria.transactionTypes != null) {
      filteredTransactions = _filterByTransactionTypes(
        filteredTransactions,
        criteria.transactionTypes!,
      );
    }

    // 应用分类筛选
    if (criteria.categoryIds != null) {
      filteredTransactions = _filterByCategories(
        filteredTransactions,
        criteria.categoryIds!,
      );
    }

    // 应用搜索文本筛选
    if (criteria.searchText != null) {
      filteredTransactions = _filterBySearchText(
        filteredTransactions,
        criteria.searchText!,
      );
    }

    return filteredTransactions;
  }

  // 标签筛选
  static List<Transaction> _filterByTags(
    List<Transaction> transactions,
    List<String> tagIds,
    TagFilterMode mode,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotEmpty(tagIds, 'tagIds');
    ValidationUtils.validateNotNull(mode, 'mode');

    switch (mode) {
      case TagFilterMode.and:
        return transactions.where((t) {
          return tagIds.every((tagId) => t.tagIds.contains(tagId));
        }).toList();

      case TagFilterMode.or:
        return transactions.where((t) {
          return tagIds.any((tagId) => t.tagIds.contains(tagId));
        }).toList();

      case TagFilterMode.not:
        return transactions.where((t) {
          return !tagIds.any((tagId) => t.tagIds.contains(tagId));
        }).toList();

      case TagFilterMode.exclusive:
        return transactions.where((t) {
          return t.tagIds.length == tagIds.length &&
                 tagIds.every((tagId) => t.tagIds.contains(tagId));
        }).toList();
    }
  }

  // 时间范围筛选
  static List<Transaction> _filterByTimeRange(
    List<Transaction> transactions,
    TagFilterTimeRange range,
    DateTime? customStartDate,
    DateTime? customEndDate,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotNull(range, 'range');

    if (range == TagFilterTimeRange.custom) {
      ValidationUtils.validateNotNull(customStartDate, 'customStartDate');
      ValidationUtils.validateNotNull(customEndDate, 'customEndDate');
      ValidationUtils.validateDateRange(customStartDate, customEndDate);
    }

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (range) {
      case TagFilterTimeRange.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;

      case TagFilterTimeRange.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate.add(const Duration(days: 7));
        break;

      case TagFilterTimeRange.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;

      case TagFilterTimeRange.thisYear:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1);
        break;

      case TagFilterTimeRange.custom:
        startDate = customStartDate!;
        endDate = customEndDate!;
        break;
    }

    return transactions.where((t) {
      return t.date.isAfter(startDate) && t.date.isBefore(endDate);
    }).toList();
  }

  // 金额范围筛选
  static List<Transaction> _filterByAmount(
    List<Transaction> transactions,
    double? minAmount,
    double? maxAmount,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');
    if (minAmount != null) ValidationUtils.validateAmount(minAmount);
    if (maxAmount != null) ValidationUtils.validateAmount(maxAmount);
    if (minAmount != null && maxAmount != null && minAmount > maxAmount) {
      throw ValidationException(
        'Minimum amount cannot be greater than maximum amount',
        invalidValue: {'minAmount': minAmount, 'maxAmount': maxAmount},
      );
    }

    return transactions.where((t) {
      if (minAmount != null && t.amount < minAmount) return false;
      if (maxAmount != null && t.amount > maxAmount) return false;
      return true;
    }).toList();
  }

  // 交易类型筛选
  static List<Transaction> _filterByTransactionTypes(
    List<Transaction> transactions,
    List<TransactionType> types,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotEmpty(types, 'types');

    return transactions.where((t) => types.contains(t.type)).toList();
  }

  // 分类筛选
  static List<Transaction> _filterByCategories(
    List<Transaction> transactions,
    List<String> categoryIds,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotEmpty(categoryIds, 'categoryIds');
    for (var id in categoryIds) {
      ValidationUtils.validateId(id, 'categoryId');
    }

    return transactions.where((t) {
      return t.categoryId != null && categoryIds.contains(t.categoryId);
    }).toList();
  }

  // 搜索文本筛选
  static List<Transaction> _filterBySearchText(
    List<Transaction> transactions,
    String searchText,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateStringNotEmpty(searchText, 'searchText');

    final keywords = searchText.toLowerCase().split(' ');
    return transactions.where((t) {
      final description = t.description?.toLowerCase() ?? '';
      return keywords.every((keyword) => description.contains(keyword));
    }).toList();
  }

  // 获取标签使用统计
  static Map<String, TagUsageStatistics> getTagUsageStatistics(
    List<Transaction> transactions,
    List<Tag> tags,
  ) {
    ValidationUtils.validateNotNull(transactions, 'transactions');
    ValidationUtils.validateNotEmpty(tags, 'tags');

    final statistics = <String, TagUsageStatistics>{};

    for (var tag in tags) {
      ValidationUtils.validateNotNull(tag.id, 'tag.id');
      
      final tagTransactions = transactions
          .where((t) => t.tagIds.contains(tag.id))
          .toList();

      final totalAmount = tagTransactions.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );

      final typeDistribution = groupBy(
        tagTransactions,
        (Transaction t) => t.type,
      ).map(
        (type, transactions) => MapEntry(
          type,
          transactions.length,
        ),
      );

      statistics[tag.id] = TagUsageStatistics(
        tagId: tag.id,
        usageCount: tagTransactions.length,
        totalAmount: totalAmount,
        typeDistribution: typeDistribution,
      );
    }

    return statistics;
  }
}

class TagUsageStatistics {
  final String tagId;
  final int usageCount;
  final double totalAmount;
  final Map<TransactionType, int> typeDistribution;

  TagUsageStatistics({
    required this.tagId,
    required this.usageCount,
    required this.totalAmount,
    required this.typeDistribution,
  }) {
    ValidationUtils.validateId(tagId, 'tagId');
    ValidationUtils.validateNonNegative(usageCount, 'usageCount');
    ValidationUtils.validateAmount(totalAmount);
    ValidationUtils.validateNotNull(typeDistribution, 'typeDistribution');
  }
} 