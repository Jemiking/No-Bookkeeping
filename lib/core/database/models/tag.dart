import 'package:flutter/foundation.dart';

/// 标签模型类
class Tag {
  /// 标签ID
  final int? id;

  /// 标签名称
  final String name;

  /// 图标
  final String? icon;

  /// 颜色
  final int? color;

  /// 使用次数
  int useCount;

  /// 是否系统预设
  final bool isSystem;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 构造函数
  Tag({
    this.id,
    required this.name,
    this.icon,
    this.color,
    this.useCount = 0,
    this.isSystem = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON映射创建Tag实例
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int?,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as int?,
      useCount: json['use_count'] as int? ?? 0,
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
      'icon': icon,
      'color': color,
      'use_count': useCount,
      'is_system': isSystem,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 创建Tag的副本
  Tag copyWith({
    int? id,
    String? name,
    String? icon,
    int? color,
    int? useCount,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      useCount: useCount ?? this.useCount,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 增加使用次数
  void incrementUseCount() {
    useCount++;
  }

  /// 减少使用次数
  void decrementUseCount() {
    if (useCount > 0) {
      useCount--;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          color == other.color &&
          useCount == other.useCount &&
          isSystem == other.isSystem;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      icon.hashCode ^
      color.hashCode ^
      useCount.hashCode ^
      isSystem.hashCode;

  @override
  String toString() {
    return 'Tag{id: $id, name: $name, useCount: $useCount, isSystem: $isSystem}';
  }
} 