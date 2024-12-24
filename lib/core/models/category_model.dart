import 'base_model.dart';

/// Category model class
class Category extends BaseModel
    with UserAssociated, Named, Typed, Describable, Colored, Iconic {
  @override
  final String userId;
  @override
  final String name;
  @override
  final String type;
  @override
  final String? icon;
  @override
  final String? color;
  final String? parentId;
  @override
  final String? description;

  Category({
    required String id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.parentId,
    this.description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Create Category from map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      parentId: map['parent_id'] as String?,
      description: map['description'] as String?,
      createdAt: BaseModel.fromDbTimestamp(map['created_at'] as int),
      updatedAt: BaseModel.fromDbTimestamp(map['updated_at'] as int),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'parent_id': parentId,
      'description': description,
      'created_at': BaseModel.toDbTimestamp(createdAt),
      'updated_at': BaseModel.toDbTimestamp(updatedAt),
    };
  }

  @override
  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? icon,
    String? color,
    String? parentId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, userId: $userId, name: $name, type: $type, '
        'icon: $icon, color: $color, parentId: $parentId, description: $description, '
        'createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

/// Category model builder
class CategoryBuilder extends BaseModelBuilder<Category> {
  String? userId;
  String? name;
  String? type;
  String? icon;
  String? color;
  String? parentId;
  String? description;

  @override
  Category build() {
    assert(id != null, 'Category id cannot be null');
    assert(userId != null, 'Category userId cannot be null');
    assert(name != null, 'Category name cannot be null');
    assert(type != null, 'Category type cannot be null');
    assert(createdAt != null, 'Category createdAt cannot be null');
    assert(updatedAt != null, 'Category updatedAt cannot be null');

    return Category(
      id: id!,
      userId: userId!,
      name: name!,
      type: type!,
      icon: icon,
      color: color,
      parentId: parentId,
      description: description,
      createdAt: createdAt!,
      updatedAt: updatedAt!,
    );
  }

  @override
  void reset() {
    super.reset();
    userId = null;
    name = null;
    type = null;
    icon = null;
    color = null;
    parentId = null;
    description = null;
  }
} 