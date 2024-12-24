class CustomCategory {
  final String id;
  final String name;
  final String? parentId;
  final String? icon;
  final String? color;
  final Map<String, dynamic> customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.icon,
    this.color,
    this.customFields = const {},
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
      'customFields': customFields,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CustomCategory.fromMap(Map<String, dynamic> map) {
    return CustomCategory(
      id: map['id'],
      name: map['name'],
      parentId: map['parentId'],
      icon: map['icon'],
      color: map['color'],
      customFields: Map<String, dynamic>.from(map['customFields']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
} 