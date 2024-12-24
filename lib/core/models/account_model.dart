import 'base_model.dart';

/// Account model class
class Account extends BaseModel
    with UserAssociated, Named, Typed, Describable, Colored, Iconic, Archivable {
  @override
  final String userId;
  @override
  final String name;
  @override
  final String type;
  final String currency;
  final double initialBalance;
  final double currentBalance;
  @override
  final String? color;
  @override
  final String? icon;
  @override
  final String? description;
  @override
  final bool isArchived;

  Account({
    required String id,
    required this.userId,
    required this.name,
    required this.type,
    required this.currency,
    required this.initialBalance,
    required this.currentBalance,
    this.color,
    this.icon,
    this.description,
    this.isArchived = false,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Create Account from map
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      currency: map['currency'] as String,
      initialBalance: map['initial_balance'] as double,
      currentBalance: map['current_balance'] as double,
      color: map['color'] as String?,
      icon: map['icon'] as String?,
      description: map['description'] as String?,
      isArchived: (map['is_archived'] as int?) == 1,
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
      'currency': currency,
      'initial_balance': initialBalance,
      'current_balance': currentBalance,
      'color': color,
      'icon': icon,
      'description': description,
      'is_archived': isArchived ? 1 : 0,
      'created_at': BaseModel.toDbTimestamp(createdAt),
      'updated_at': BaseModel.toDbTimestamp(updatedAt),
    };
  }

  @override
  Account copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? currency,
    double? initialBalance,
    double? currentBalance,
    String? color,
    String? icon,
    String? description,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Account{id: $id, userId: $userId, name: $name, type: $type, currency: $currency, '
        'initialBalance: $initialBalance, currentBalance: $currentBalance, color: $color, '
        'icon: $icon, description: $description, isArchived: $isArchived, '
        'createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

/// Account model builder
class AccountBuilder extends BaseModelBuilder<Account> {
  String? userId;
  String? name;
  String? type;
  String? currency;
  double? initialBalance;
  double? currentBalance;
  String? color;
  String? icon;
  String? description;
  bool isArchived = false;

  @override
  Account build() {
    assert(id != null, 'Account id cannot be null');
    assert(userId != null, 'Account userId cannot be null');
    assert(name != null, 'Account name cannot be null');
    assert(type != null, 'Account type cannot be null');
    assert(currency != null, 'Account currency cannot be null');
    assert(initialBalance != null, 'Account initialBalance cannot be null');
    assert(currentBalance != null, 'Account currentBalance cannot be null');
    assert(createdAt != null, 'Account createdAt cannot be null');
    assert(updatedAt != null, 'Account updatedAt cannot be null');

    return Account(
      id: id!,
      userId: userId!,
      name: name!,
      type: type!,
      currency: currency!,
      initialBalance: initialBalance!,
      currentBalance: currentBalance!,
      color: color,
      icon: icon,
      description: description,
      isArchived: isArchived,
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
    currency = null;
    initialBalance = null;
    currentBalance = null;
    color = null;
    icon = null;
    description = null;
    isArchived = false;
  }
} 