import 'package:flutter/foundation.dart';

enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly
}

class PeriodicBudget {
  final String id;
  final String name;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final bool isActive;
  final String? categoryId;
  final double spent;
  final String notes;

  PeriodicBudget({
    required this.id,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    this.isActive = true,
    this.categoryId,
    this.spent = 0,
    this.notes = '',
  });

  DateTime get endDate {
    switch (period) {
      case BudgetPeriod.daily:
        return startDate.add(const Duration(days: 1));
      case BudgetPeriod.weekly:
        return startDate.add(const Duration(days: 7));
      case BudgetPeriod.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case BudgetPeriod.quarterly:
        return DateTime(startDate.year, startDate.month + 3, startDate.day);
      case BudgetPeriod.yearly:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
    }
  }

  double get remaining => amount - spent;
  double get progress => (spent / amount) * 100;
  bool get isOverBudget => spent > amount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'period': period.toString(),
      'startDate': startDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'categoryId': categoryId,
      'spent': spent,
      'notes': notes,
    };
  }

  factory PeriodicBudget.fromJson(Map<String, dynamic> json) {
    return PeriodicBudget(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      period: BudgetPeriod.values.firstWhere(
        (e) => e.toString() == json['period'],
      ),
      startDate: DateTime.parse(json['startDate']),
      isActive: json['isActive'] == 1,
      categoryId: json['categoryId'],
      spent: json['spent'] ?? 0,
      notes: json['notes'] ?? '',
    );
  }

  PeriodicBudget copyWith({
    String? id,
    String? name,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    bool? isActive,
    String? categoryId,
    double? spent,
    String? notes,
  }) {
    return PeriodicBudget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId ?? this.categoryId,
      spent: spent ?? this.spent,
      notes: notes ?? this.notes,
    );
  }
} 