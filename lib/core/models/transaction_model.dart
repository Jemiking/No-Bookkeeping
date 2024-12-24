import 'base_model.dart';

/// Transaction model class
class Transaction extends BaseModel
    with UserAssociated, Typed, Describable, Monetary {
  @override
  final String userId;
  final String accountId;
  final String? categoryId;
  @override
  final String type;
  @override
  final double amount;
  @override
  final String currency;
  final DateTime date;
  @override
  final String? description;
  final String? notes;
  final String? location;
  final bool isReconciled;
  final List<String> tagIds;

  Transaction({
    required String id,
    required this.userId,
    required this.accountId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.date,
    this.description,
    this.notes,
    this.location,
    this.isReconciled = false,
    this.tagIds = const [],
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Create Transaction from map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      accountId: map['account_id'] as String,
      categoryId: map['category_id'] as String?,
      type: map['type'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      date: BaseModel.fromDbTimestamp(map['date'] as int),
      description: map['description'] as String?,
      notes: map['notes'] as String?,
      location: map['location'] as String?,
      isReconciled: (map['is_reconciled'] as int?) == 1,
      tagIds: (map['tag_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: BaseModel.fromDbTimestamp(map['created_at'] as int),
      updatedAt: BaseModel.fromDbTimestamp(map['updated_at'] as int),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'date': BaseModel.toDbTimestamp(date),
      'description': description,
      'notes': notes,
      'location': location,
      'is_reconciled': isReconciled ? 1 : 0,
      'tag_ids': tagIds,
      'created_at': BaseModel.toDbTimestamp(createdAt),
      'updated_at': BaseModel.toDbTimestamp(updatedAt),
    };
  }

  @override
  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? categoryId,
    String? type,
    double? amount,
    String? currency,
    DateTime? date,
    String? description,
    String? notes,
    String? location,
    bool? isReconciled,
    List<String>? tagIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      isReconciled: isReconciled ?? this.isReconciled,
      tagIds: tagIds ?? this.tagIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, userId: $userId, accountId: $accountId, '
        'categoryId: $categoryId, type: $type, amount: $amount, currency: $currency, '
        'date: $date, description: $description, notes: $notes, location: $location, '
        'isReconciled: $isReconciled, tagIds: $tagIds, createdAt: $createdAt, '
        'updatedAt: $updatedAt}';
  }
}

/// Transaction model builder
class TransactionBuilder extends BaseModelBuilder<Transaction> {
  String? userId;
  String? accountId;
  String? categoryId;
  String? type;
  double? amount;
  String? currency;
  DateTime? date;
  String? description;
  String? notes;
  String? location;
  bool isReconciled = false;
  List<String> tagIds = [];

  @override
  Transaction build() {
    assert(id != null, 'Transaction id cannot be null');
    assert(userId != null, 'Transaction userId cannot be null');
    assert(accountId != null, 'Transaction accountId cannot be null');
    assert(type != null, 'Transaction type cannot be null');
    assert(amount != null, 'Transaction amount cannot be null');
    assert(currency != null, 'Transaction currency cannot be null');
    assert(date != null, 'Transaction date cannot be null');
    assert(createdAt != null, 'Transaction createdAt cannot be null');
    assert(updatedAt != null, 'Transaction updatedAt cannot be null');

    return Transaction(
      id: id!,
      userId: userId!,
      accountId: accountId!,
      categoryId: categoryId,
      type: type!,
      amount: amount!,
      currency: currency!,
      date: date!,
      description: description,
      notes: notes,
      location: location,
      isReconciled: isReconciled,
      tagIds: tagIds,
      createdAt: createdAt!,
      updatedAt: updatedAt!,
    );
  }

  @override
  void reset() {
    super.reset();
    userId = null;
    accountId = null;
    categoryId = null;
    type = null;
    amount = null;
    currency = null;
    date = null;
    description = null;
    notes = null;
    location = null;
    isReconciled = false;
    tagIds = [];
  }
} 