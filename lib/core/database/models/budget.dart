import 'package:flutter/foundation.dart';

/// 预算周期枚举
enum BudgetPeriod {
  /// 每日
  daily,
  /// 每周
  weekly,
  /// 每月
  monthly,
  /// 每年
  yearly,
  /// 自定义
  custom,
}

/// 预算类型枚举
enum BudgetType {
  /// 总预算
  total,
  /// 分类预算
  category,
  /// 标签预算
  tag,
}

/// 预算状态枚举
enum BudgetStatus {
  /// 正常
  active,
  /// 已暂停
  paused,
  /// 已结束
  ended,
  /// 已删除
  deleted,
}

/// 预算模型类
class Budget {
  /// 预算ID
  final int? id;

  /// 预算名称
  final String name;

  /// 预算金额
  final double amount;

  /// 已使用金额
  double usedAmount;

  /// 预算周期
  final BudgetPeriod period;

  /// 预算类型
  final BudgetType type;

  /// 预算状态
  final BudgetStatus status;

  /// 关联的分类ID（分类预算时使用）
  final int? categoryId;

  /// 关联的标签ID（标签预算时使用）
  final int? tagId;

  /// 开始日期
  final DateTime startDate;

  /// 结束日期
  final DateTime? endDate;

  /// 提醒阈值（百分比，例如���80表示使用达到80%时提醒）
  final double? alertThreshold;

  /// 备注
  final String? note;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 构造函数
  Budget({
    this.id,
    required this.name,
    required this.amount,
    this.usedAmount = 0.0,
    required this.period,
    required this.type,
    this.status = BudgetStatus.active,
    this.categoryId,
    this.tagId,
    required this.startDate,
    this.endDate,
    this.alertThreshold,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    // 验证分类预算必须有分类ID
    if (type == BudgetType.category && categoryId == null) {
      throw ArgumentError('Category budget must have a category ID');
    }
    // 验证标签预算必须有标签ID
    if (type == BudgetType.tag && tagId == null) {
      throw ArgumentError('Tag budget must have a tag ID');
    }
    // 验证自定义周期必须有结束日期
    if (period == BudgetPeriod.custom && endDate == null) {
      throw ArgumentError('Custom period budget must have an end date');
    }
  }

  /// 从JSON映射创建Budget实例
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int?,
      name: json['name'] as String,
      amount: json['amount'] as double,
      usedAmount: json['used_amount'] as double? ?? 0.0,
      period: BudgetPeriod.values[json['period'] as int],
      type: BudgetType.values[json['type'] as int],
      status: BudgetStatus.values[json['status'] as int],
      categoryId: json['category_id'] as int?,
      tagId: json['tag_id'] as int?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      alertThreshold: json['alert_threshold'] as double?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'used_amount': usedAmount,
      'period': period.index,
      'type': type.index,
      'status': status.index,
      'category_id': categoryId,
      'tag_id': tagId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'alert_threshold': alertThreshold,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 创建Budget的副本
  Budget copyWith({
    int? id,
    String? name,
    double? amount,
    double? usedAmount,
    BudgetPeriod? period,
    BudgetType? type,
    BudgetStatus? status,
    int? categoryId,
    int? tagId,
    DateTime? startDate,
    DateTime? endDate,
    double? alertThreshold,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      usedAmount: usedAmount ?? this.usedAmount,
      period: period ?? this.period,
      type: type ?? this.type,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      tagId: tagId ?? this.tagId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 计算预算使用百分比
  double get usagePercentage => (usedAmount / amount) * 100;

  /// 检查是否超出预算
  bool get isOverBudget => usedAmount > amount;

  /// 检查是否达到提醒阈值
  bool get shouldAlert =>
      alertThreshold != null && usagePercentage >= alertThreshold!;

  /// 更新已使用金额
  void updateUsedAmount(double amount) {
    usedAmount = amount;
  }

  /// 增加使用金额
  void addUsedAmount(double amount) {
    usedAmount += amount;
  }

  /// 减少使用金额
  void subtractUsedAmount(double amount) {
    usedAmount = (usedAmount - amount).clamp(0, double.infinity);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Budget &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          amount == other.amount &&
          usedAmount == other.usedAmount &&
          period == other.period &&
          type == other.type &&
          status == other.status &&
          categoryId == other.categoryId &&
          tagId == other.tagId &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          alertThreshold == other.alertThreshold &&
          note == other.note;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      amount.hashCode ^
      usedAmount.hashCode ^
      period.hashCode ^
      type.hashCode ^
      status.hashCode ^
      categoryId.hashCode ^
      tagId.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      alertThreshold.hashCode ^
      note.hashCode;

  @override
  String toString() {
    return 'Budget{id: $id, name: $name, amount: $amount, '
        'usedAmount: $usedAmount, period: $period, type: $type, '
        'status: $status}';
  }
} 