import 'package:flutter/foundation.dart';

/// 分类类型枚举
enum CategoryType {
  /// 收入
  income,
  /// 支出
  expense,
  /// 转账
  transfer,
}

/// 分类模型类
class Category {
  /// 分类ID
  final int? id;

  /// 分类名称
  final String name;

  /// 分类类型
  final CategoryType type;

  /// 父分类ID
  final int? parentId;

  /// 图标
  final String? icon;

  /// 颜色
  final int? color;

  /// 排序顺序
  final int order;

  /// 预算金额
  final double? budget;

  /// 是否系统预设
  final bool isSystem;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 构造函数
  Category({
    this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.icon,
    this.color,
    this.order = 0,
    this.budget,
    this.isSystem = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON映射创建Category实例
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      name: json['name'] as String,
      type: CategoryType.values[json['type'] as int],
      parentId: json['parent_id'] as int?,
      icon: json['icon'] as String?,
      color: json['color'] as int?,
      order: json['order'] as int? ?? 0,
      budget: json['budget'] as double?,
      isSystem: json['is_system'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'parent_id': parentId,
      'icon': icon,
      'color': color,
      'order': order,
      'budget': budget,
      'is_system': isSystem,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 创建Category的副本
  Category copyWith({
    int? id,
    String? name,
    CategoryType? type,
    int? parentId,
    String? icon,
    int? color,
    int? order,
    double? budget,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      budget: budget ?? this.budget,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          parentId == other.parentId &&
          icon == other.icon &&
          color == other.color &&
          order == other.order &&
          budget == other.budget &&
          isSystem == other.isSystem;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      parentId.hashCode ^
      icon.hashCode ^
      color.hashCode ^
      order.hashCode ^
      budget.hashCode ^
      isSystem.hashCode;

  @override
  String toString() {
    return 'Category{id: $id, name: $name, type: $type, '
        'parentId: $parentId, order: $order, isSystem: $isSystem}';
  }
} 