import 'package:flutter/foundation.dart';

/// 交易类型枚举
enum TransactionType {
  /// 收入
  income,
  /// 支出
  expense,
  /// 转账
  transfer,
}

/// 交易状态枚举
enum TransactionStatus {
  /// 已完成
  completed,
  /// 待确认
  pending,
  /// 已取消
  cancelled,
  /// 已删除
  deleted,
}

/// 交易记录模型类
class Transaction {
  /// 交易ID
  final int? id;

  /// 交易类型
  final TransactionType type;

  /// 交易状态
  final TransactionStatus status;

  /// 金额
  final double amount;

  /// 账户ID
  final int accountId;

  /// 目标账户ID（转账时使用）
  final int? toAccountId;

  /// 分类ID
  final int? categoryId;

  /// 标签ID列表
  final List<int>? tagIds;

  /// 交易日期
  final DateTime date;

  /// 备注
  final String? note;

  /// 位置
  final String? location;

  /// 附件列表
  final List<String>? attachments;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 构造函数
  Transaction({
    this.id,
    required this.type,
    this.status = TransactionStatus.completed,
    required this.amount,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    this.tagIds,
    DateTime? date,
    this.note,
    this.location,
    this.attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    // 验证转账交易必须有目标账户
    if (type == TransactionType.transfer && toAccountId == null) {
      throw ArgumentError('Transfer transaction must have a target account');
    }
  }

  /// 从JSON映射创建Transaction实例
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      type: TransactionType.values[json['type'] as int],
      status: TransactionStatus.values[json['status'] as int],
      amount: json['amount'] as double,
      accountId: json['account_id'] as int,
      toAccountId: json['to_account_id'] as int?,
      categoryId: json['category_id'] as int?,
      tagIds: (json['tag_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      location: json['location'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'status': status.index,
      'amount': amount,
      'account_id': accountId,
      'to_account_id': toAccountId,
      'category_id': categoryId,
      'tag_ids': tagIds,
      'date': date.toIso8601String(),
      'note': note,
      'location': location,
      'attachments': attachments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 创建Transaction的副本
  Transaction copyWith({
    int? id,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    int? accountId,
    int? toAccountId,
    int? categoryId,
    List<int>? tagIds,
    DateTime? date,
    String? note,
    String? location,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      tagIds: tagIds ?? this.tagIds,
      date: date ?? this.date,
      note: note ?? this.note,
      location: location ?? this.location,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          status == other.status &&
          amount == other.amount &&
          accountId == other.accountId &&
          toAccountId == other.toAccountId &&
          categoryId == other.categoryId &&
          listEquals(tagIds, other.tagIds) &&
          date == other.date &&
          note == other.note &&
          location == other.location &&
          listEquals(attachments, other.attachments);

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      status.hashCode ^
      amount.hashCode ^
      accountId.hashCode ^
      toAccountId.hashCode ^
      categoryId.hashCode ^
      tagIds.hashCode ^
      date.hashCode ^
      note.hashCode ^
      location.hashCode ^
      attachments.hashCode;

  @override
  String toString() {
    return 'Transaction{id: $id, type: $type, status: $status, '
        'amount: $amount, accountId: $accountId, toAccountId: $toAccountId, '
        'categoryId: $categoryId, date: $date}';
  }
} 