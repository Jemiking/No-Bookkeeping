import 'base_model.dart';

/// Tag model class
class Tag extends BaseModel with UserAssociated, Named, Colored {
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? color;

  Tag({
    required String id,
    required this.userId,
    required this.name,
    this.color,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Create Tag from map
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      color: map['color'] as String?,
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
      'color': color,
      'created_at': BaseModel.toDbTimestamp(createdAt),
      'updated_at': BaseModel.toDbTimestamp(updatedAt),
    };
  }

  @override
  Tag copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tag(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Tag{id: $id, userId: $userId, name: $name, color: $color, '
        'createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

/// Tag model builder
class TagBuilder extends BaseModelBuilder<Tag> {
  String? userId;
  String? name;
  String? color;

  @override
  Tag build() {
    assert(id != null, 'Tag id cannot be null');
    assert(userId != null, 'Tag userId cannot be null');
    assert(name != null, 'Tag name cannot be null');
    assert(createdAt != null, 'Tag createdAt cannot be null');
    assert(updatedAt != null, 'Tag updatedAt cannot be null');

    return Tag(
      id: id!,
      userId: userId!,
      name: name!,
      color: color,
      createdAt: createdAt!,
      updatedAt: updatedAt!,
    );
  }

  @override
  void reset() {
    super.reset();
    userId = null;
    name = null;
    color = null;
  }
} 