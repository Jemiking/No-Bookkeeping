class Category {
  final String id;
  final String name;
  final String? parentId;
  final String? icon;
  final String? color;
  final String? description;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.parentId,
    this.icon,
    this.color,
    this.description,
    this.isSystem = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'icon': icon,
      'color': color,
      'description': description,
      'isSystem': isSystem ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      parentId: map['parentId'],
      icon: map['icon'],
      color: map['color'],
      description: map['description'],
      isSystem: map['isSystem'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Category copyWith({
    String? name,
    String? parentId,
    String? icon,
    String? color,
    String? description,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      isSystem: isSystem,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 