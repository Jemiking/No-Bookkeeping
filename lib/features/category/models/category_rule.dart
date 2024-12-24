class CategoryRule {
  final String id;
  final String categoryId;
  final String name;
  final String condition;
  final Map<String, dynamic> parameters;
  final bool isEnabled;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryRule({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.condition,
    required this.parameters,
    this.isEnabled = true,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'condition': condition,
      'parameters': parameters,
      'isEnabled': isEnabled ? 1 : 0,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CategoryRule.fromMap(Map<String, dynamic> map) {
    return CategoryRule(
      id: map['id'],
      categoryId: map['categoryId'],
      name: map['name'],
      condition: map['condition'],
      parameters: Map<String, dynamic>.from(map['parameters']),
      isEnabled: map['isEnabled'] == 1,
      priority: map['priority'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
} 