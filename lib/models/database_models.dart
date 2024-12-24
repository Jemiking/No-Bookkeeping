import 'package:flutter/foundation.dart';

/// 基础模型接口
abstract class DatabaseModel {
  Map<String, dynamic> toMap();
  String get tableName;
}

/// 账户数据库实体模型
class AccountEntity implements DatabaseModel {
  final int? id;
  final String name;
  final double balance;
  final String? createdAt;
  final String? updatedAt;

  AccountEntity({
    this.id,
    required this.name,
    required this.balance,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String get tableName => 'accounts';

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'balance': balance,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  factory AccountEntity.fromMap(Map<String, dynamic> map) {
    return AccountEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      balance: map['balance'] as double,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  AccountEntity copyWith({
    int? id,
    String? name,
    double? balance,
    String? createdAt,
    String? updatedAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 交易数据库实体模型
class TransactionEntity implements DatabaseModel {
  final int? id;
  final int accountId;
  final int categoryId;
  final double amount;
  final String type;
  final String? description;
  final String date;
  final String? createdAt;
  final String? updatedAt;

  TransactionEntity({
    this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String get tableName => 'transactions';

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      categoryId: map['category_id'] as int,
      amount: map['amount'] as double,
      type: map['type'] as String,
      description: map['description'] as String?,
      date: map['date'] as String,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  TransactionEntity copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    double? amount,
    String? type,
    String? description,
    String? date,
    String? createdAt,
    String? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 分类数据库实体模型
class CategoryEntity implements DatabaseModel {
  final int? id;
  final String name;
  final String type;
  final String? createdAt;
  final String? updatedAt;

  CategoryEntity({
    this.id,
    required this.name,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String get tableName => 'categories';

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  factory CategoryEntity.fromMap(Map<String, dynamic> map) {
    return CategoryEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? type,
    String? createdAt,
    String? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 预算数据库实体模型
class BudgetEntity implements DatabaseModel {
  final int? id;
  final String name;
  final double amount;
  final String? createdAt;
  final String? updatedAt;

  BudgetEntity({
    this.id,
    required this.name,
    required this.amount,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String get tableName => 'budgets';

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  factory BudgetEntity.fromMap(Map<String, dynamic> map) {
    return BudgetEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: map['amount'] as double,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  BudgetEntity copyWith({
    int? id,
    String? name,
    double? amount,
    String? createdAt,
    String? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 标签模型
class Tag implements DatabaseModel {
  final int? id;
  final String name;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tag({
    this.id,
    required this.name,
    this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  String get tableName => 'tags';

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color': color,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Tag.fromMap(Map<String, dynamic> map) => Tag(
    id: map['id'] as int?,
    name: map['name'] as String,
    color: map['color'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
} 