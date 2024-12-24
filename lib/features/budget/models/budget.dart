import 'package:flutter/foundation.dart';

class Budget {
  final String id;
  final String name;
  final double amount;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final String currency;
  final bool isActive;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    this.spent = 0.0,
    required this.startDate,
    required this.endDate,
    required this.currency,
    this.isActive = true,
  });

  double get remaining => amount - spent;
  double get progress => (spent / amount) * 100;
  bool get isOverBudget => spent > amount;

  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    double? spent,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
    bool? isActive,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'currency': currency,
      'isActive': isActive,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      spent: json['spent'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      currency: json['currency'],
      isActive: json['isActive'],
    );
  }
} 