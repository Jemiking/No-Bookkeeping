import 'package:flutter/foundation.dart';

enum TransactionType {
  income,
  expense,
  transfer
}

class RecurringRule {
  final String id;
  final RecurringFrequency frequency;
  final int interval;
  final DateTime? endDate;
  final int? occurrences;

  RecurringRule({
    required this.id,
    required this.frequency,
    required this.interval,
    this.endDate,
    this.occurrences,
  });

  factory RecurringRule.fromJson(Map<String, dynamic> json) {
    return RecurringRule(
      id: json['id'] as String,
      frequency: RecurringFrequency.values[json['frequency'] as int],
      interval: json['interval'] as int,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      occurrences: json['occurrences'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frequency': frequency.index,
      'interval': interval,
      'endDate': endDate?.toIso8601String(),
      'occurrences': occurrences,
    };
  }
}

enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  yearly
}

@immutable
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String accountId;
  final String? toAccountId; // 用于转账交易
  final String categoryId;
  final List<String> tagIds;
  final DateTime dateTime;
  final String note;
  final String? attachmentPath;
  final bool isRecurring;
  final RecurringRule? recurringRule;
  final String? templateName; // 如果这是一个模板，则有模板名称

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    this.toAccountId,
    required this.categoryId,
    required this.tagIds,
    required this.dateTime,
    required this.note,
    this.attachmentPath,
    this.isRecurring = false,
    this.recurringRule,
    this.templateName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TransactionType.values[json['type'] as int],
      amount: json['amount'] as double,
      accountId: json['accountId'] as String,
      toAccountId: json['toAccountId'] as String?,
      categoryId: json['categoryId'] as String,
      tagIds: List<String>.from(json['tagIds'] as List),
      dateTime: DateTime.parse(json['dateTime'] as String),
      note: json['note'] as String,
      attachmentPath: json['attachmentPath'] as String?,
      isRecurring: json['isRecurring'] as bool,
      recurringRule: json['recurringRule'] != null 
          ? RecurringRule.fromJson(json['recurringRule'] as Map<String, dynamic>)
          : null,
      templateName: json['templateName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'amount': amount,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'categoryId': categoryId,
      'tagIds': tagIds,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
      'attachmentPath': attachmentPath,
      'isRecurring': isRecurring,
      'recurringRule': recurringRule?.toJson(),
      'templateName': templateName,
    };
  }

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    List<String>? tagIds,
    DateTime? dateTime,
    String? note,
    String? attachmentPath,
    bool? isRecurring,
    RecurringRule? recurringRule,
    String? templateName,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      tagIds: tagIds ?? this.tagIds,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRule: recurringRule ?? this.recurringRule,
      templateName: templateName ?? this.templateName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.type == type &&
        other.amount == amount &&
        other.accountId == accountId &&
        other.toAccountId == toAccountId &&
        other.categoryId == categoryId &&
        listEquals(other.tagIds, tagIds) &&
        other.dateTime == dateTime &&
        other.note == note &&
        other.attachmentPath == attachmentPath &&
        other.isRecurring == isRecurring &&
        other.recurringRule == recurringRule &&
        other.templateName == templateName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      amount,
      accountId,
      toAccountId,
      categoryId,
      Object.hashAll(tagIds),
      dateTime,
      note,
      attachmentPath,
      isRecurring,
      recurringRule,
      templateName,
    );
  }
} 