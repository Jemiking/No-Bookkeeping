import 'package:uuid/uuid.dart';
import 'transaction.dart';

class InstallmentTransaction {
  final String id;
  final String accountId;
  final double totalAmount;
  final String currency;
  final int totalInstallments;
  final int remainingInstallments;
  final double installmentAmount;
  final DateTime startDate;
  final String description;
  final String? categoryId;
  final List<String> tagIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  InstallmentTransaction({
    required this.id,
    required this.accountId,
    required this.totalAmount,
    required this.currency,
    required this.totalInstallments,
    required this.remainingInstallments,
    required this.installmentAmount,
    required this.startDate,
    required this.description,
    this.categoryId,
    required this.tagIds,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  InstallmentTransaction copyWith({
    String? accountId,
    double? totalAmount,
    String? currency,
    int? totalInstallments,
    int? remainingInstallments,
    double? installmentAmount,
    DateTime? startDate,
    String? description,
    String? categoryId,
    List<String>? tagIds,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return InstallmentTransaction(
      id: this.id,
      accountId: accountId ?? this.accountId,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      remainingInstallments: remainingInstallments ?? this.remainingInstallments,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      startDate: startDate ?? this.startDate,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      tagIds: tagIds ?? this.tagIds,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'totalAmount': totalAmount,
      'currency': currency,
      'totalInstallments': totalInstallments,
      'remainingInstallments': remainingInstallments,
      'installmentAmount': installmentAmount,
      'startDate': startDate.toIso8601String(),
      'description': description,
      'categoryId': categoryId,
      'tagIds': tagIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory InstallmentTransaction.fromJson(Map<String, dynamic> json) {
    return InstallmentTransaction(
      id: json['id'],
      accountId: json['accountId'],
      totalAmount: json['totalAmount'],
      currency: json['currency'],
      totalInstallments: json['totalInstallments'],
      remainingInstallments: json['remainingInstallments'],
      installmentAmount: json['installmentAmount'],
      startDate: DateTime.parse(json['startDate']),
      description: json['description'],
      categoryId: json['categoryId'],
      tagIds: List<String>.from(json['tagIds']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'],
    );
  }

  DateTime getNextInstallmentDate(DateTime from) {
    // 默认每月还款
    final nextMonth = DateTime(from.year, from.month + 1, from.day);
    return nextMonth;
  }

  bool shouldGenerateTransaction(DateTime date) {
    if (!isActive) return false;
    if (remainingInstallments <= 0) return false;
    if (date.isBefore(startDate)) return false;
    return true;
  }

  Transaction generateTransaction(DateTime date) {
    final now = DateTime.now();
    return Transaction(
      id: const Uuid().v4(),
      accountId: accountId,
      type: TransactionType.expense,
      amount: installmentAmount,
      currency: currency,
      categoryId: categoryId,
      tagIds: tagIds,
      date: date,
      description: '${description} (分期付款 ${totalInstallments - remainingInstallments + 1}/${totalInstallments})',
      status: TransactionStatus.completed,
      createdAt: now,
      updatedAt: now,
    );
  }

  static InstallmentTransaction create({
    required String accountId,
    required double totalAmount,
    required String currency,
    required int totalInstallments,
    required DateTime startDate,
    required String description,
    String? categoryId,
    List<String> tagIds = const [],
  }) {
    final now = DateTime.now();
    final installmentAmount = (totalAmount / totalInstallments).roundToDouble();
    
    return InstallmentTransaction(
      id: const Uuid().v4(),
      accountId: accountId,
      totalAmount: totalAmount,
      currency: currency,
      totalInstallments: totalInstallments,
      remainingInstallments: totalInstallments,
      installmentAmount: installmentAmount,
      startDate: startDate,
      description: description,
      categoryId: categoryId,
      tagIds: tagIds,
      createdAt: now,
      updatedAt: now,
    );
  }
} 