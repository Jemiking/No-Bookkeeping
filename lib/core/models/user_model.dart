import 'base_model.dart';

/// User model class
class User extends BaseModel with Named {
  final String name;
  final String? email;
  final String? avatarUrl;

  User({
    required String id,
    required this.name,
    this.email,
    this.avatarUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Create User from map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: BaseModel.fromDbTimestamp(map['created_at'] as int),
      updatedAt: BaseModel.fromDbTimestamp(map['updated_at'] as int),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': BaseModel.toDbTimestamp(createdAt),
      'updated_at': BaseModel.toDbTimestamp(updatedAt),
    };
  }

  @override
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

/// User model builder
class UserBuilder extends BaseModelBuilder<User> {
  String? name;
  String? email;
  String? avatarUrl;

  @override
  User build() {
    assert(id != null, 'User id cannot be null');
    assert(name != null, 'User name cannot be null');
    assert(createdAt != null, 'User createdAt cannot be null');
    assert(updatedAt != null, 'User updatedAt cannot be null');

    return User(
      id: id!,
      name: name!,
      email: email,
      avatarUrl: avatarUrl,
      createdAt: createdAt!,
      updatedAt: updatedAt!,
    );
  }

  @override
  void reset() {
    super.reset();
    name = null;
    email = null;
    avatarUrl = null;
  }
} 