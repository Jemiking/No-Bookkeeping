import 'package:uuid/uuid.dart';
import 'transaction.dart';

enum RecurringPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

class RecurringTransaction {
  final String id;
  final String accountId;
  final String? toAccountId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String? categoryId;
  final List<String> tagIds;
  final String description;
  final RecurringPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final int? repeatCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  RecurringTransaction({
    required this.id,
    required this.accountId,
    this.toAccountId,
    required this.type,
    required this.amount,
    required this.currency,
    this.categoryId,
    required this.tagIds,
    required this.description,
    required this.period,
    required this.startDate,
    this.endDate,
    this.repeatCount,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  RecurringTransaction copyWith({
    String? accountId,
    String? toAccountId,
    TransactionType? type,
    double? amount,
    String? currency,
    String? categoryId,
    List<String>? tagIds,
    String? description,
    RecurringPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    int? repeatCount,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return RecurringTransaction(
      id: this.id,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      tagIds: tagIds ?? this.tagIds,
      description: description ?? this.description,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      repeatCount: repeatCount ?? this.repeatCount,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'type': type.toString(),
      'amount': amount,
      'currency': currency,
      'categoryId': categoryId,
      'tagIds': tagIds,
      'description': description,
      'period': period.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'repeatCount': repeatCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      accountId: json['accountId'],
      toAccountId: json['toAccountId'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      amount: json['amount'],
      currency: json['currency'],
      categoryId: json['categoryId'],
      tagIds: List<String>.from(json['tagIds']),
      description: json['description'],
      period: RecurringPeriod.values.firstWhere(
        (e) => e.toString() == json['period'],
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      repeatCount: json['repeatCount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'],
    );
  }

  DateTime getNextOccurrence(DateTime from) {
    switch (period) {
      case RecurringPeriod.daily:
        return from.add(const Duration(days: 1));
      case RecurringPeriod.weekly:
        return from.add(const Duration(days: 7));
      case RecurringPeriod.monthly:
        // 处理月末日期
        final nextMonth = DateTime(from.year, from.month + 1, 1);
        final lastDayOfNextMonth = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
        final targetDay = from.day > lastDayOfNextMonth ? lastDayOfNextMonth : from.day;
        return DateTime(from.year, from.month + 1, targetDay);
      case RecurringPeriod.yearly:
        return DateTime(from.year + 1, from.month, from.day);
    }
  }

  bool shouldGenerateTransaction(DateTime date) {
    if (!isActive) return false;
    if (date.isBefore(startDate)) return false;
    if (endDate != null && date.isAfter(endDate!)) return false;
    return true;
  }

  Transaction generateTransaction(DateTime date) {
    final now = DateTime.now();
    return Transaction(
      id: const Uuid().v4(),
      accountId: accountId,
      toAccountId: toAccountId,
      type: type,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      tagIds: tagIds,
      date: date,
      description: description,
      status: TransactionStatus.completed,
      createdAt: now,
      updatedAt: now,
    );
  }
} 