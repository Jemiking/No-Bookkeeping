import 'base_model.dart';

/// Budget model class
class Budget extends BaseModel
    with UserAssociated, Named, Describable, Colored, Monetary, DateRanged {
  @override
  final String userId;
  final String? categoryId;
  @override
  final String name;
  @override
  final double amount;
  @override
  final String currency;
  final String period;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final String? color;
  @override
  final String? description;

  Budget({
    required String id,
    required this.userId,
    this.categoryId,
    required this.name,
    required this.amount,
    required this.currency,
    required this.period,
    required this.startDate,
    this.endDate,
    this.color,
    this.description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Create Budget from map
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String?,
      name: map['name'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      period: map['period'] as String,
      startDate: BaseModel.fromDbTimestamp(map['start_date'] as int),
      endDate: map['end_date'] != null
          ? BaseModel.fromDbTimestamp(map['end_date'] as int)
          : null,
      color: map['color'] as String?,
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
      'category_id': categoryId,
      'name': name,
      'amount': amount,
      'currency': currency,
      'period': period,
      'start_date': BaseModel.toDbTimestamp(startDate),
      'end_date': endDate != null ? BaseModel.toDbTimestamp(endDate!) : null,
      'color': color,
      'description': description,
      'created_at': BaseModel.toDbTimestamp(createdAt),
      'updated_at': BaseModel.toDbTimestamp(updatedAt),
    };
  }

  @override
  Budget copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? name,
    double? amount,
    String? currency,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    String? color,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Budget{id: $id, userId: $userId, categoryId: $categoryId, name: $name, '
        'amount: $amount, currency: $currency, period: $period, startDate: $startDate, '
        'endDate: $endDate, color: $color, description: $description, '
        'createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

/// Budget model builder
class BudgetBuilder extends BaseModelBuilder<Budget> {
  String? userId;
  String? categoryId;
  String? name;
  double? amount;
  String? currency;
  String? period;
  DateTime? startDate;
  DateTime? endDate;
  String? color;
  String? description;

  @override
  Budget build() {
    assert(id != null, 'Budget id cannot be null');
    assert(userId != null, 'Budget userId cannot be null');
    assert(name != null, 'Budget name cannot be null');
    assert(amount != null, 'Budget amount cannot be null');
    assert(currency != null, 'Budget currency cannot be null');
    assert(period != null, 'Budget period cannot be null');
    assert(startDate != null, 'Budget startDate cannot be null');
    assert(createdAt != null, 'Budget createdAt cannot be null');
    assert(updatedAt != null, 'Budget updatedAt cannot be null');

    return Budget(
      id: id!,
      userId: userId!,
      categoryId: categoryId,
      name: name!,
      amount: amount!,
      currency: currency!,
      period: period!,
      startDate: startDate!,
      endDate: endDate,
      color: color,
      description: description,
      createdAt: createdAt!,
      updatedAt: updatedAt!,
    );
  }

  @override
  void reset() {
    super.reset();
    userId = null;
    categoryId = null;
    name = null;
    amount = null;
    currency = null;
    period = null;
    startDate = null;
    endDate = null;
    color = null;
    description = null;
  }
} 