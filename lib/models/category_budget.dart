import 'package:flutter/foundation.dart';

class CategoryBudget {
  final String id;
  final String categoryId;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final double spent;
  final double remaining;

  CategoryBudget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.notes = '',
    this.spent = 0,
    this.remaining = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
      'spent': spent,
      'remaining': remaining,
    };
  }

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: json['amount'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      notes: json['notes'] ?? '',
      spent: json['spent'] ?? 0,
      remaining: json['remaining'] ?? 0,
    );
  }

  CategoryBudget copyWith({
    String? id,
    String? categoryId,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    double? spent,
    double? remaining,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      spent: spent ?? this.spent,
      remaining: remaining ?? this.remaining,
    );
  }
} 