enum TransactionType {
  income,
  expense,
  transfer,
}

enum TransactionStatus {
  pending,
  completed,
  cancelled,
}

class Transaction {
  final String id;
  final String accountId;
  final String? toAccountId; // 用于转账交易
  final TransactionType type;
  double amount;
  String currency;
  String? categoryId;
  List<String> tagIds;
  DateTime date;
  String? description;
  TransactionStatus status;
  DateTime createdAt;
  DateTime updatedAt;

  Transaction({
    required this.id,
    required this.accountId,
    this.toAccountId,
    required this.type,
    required this.amount,
    required this.currency,
    this.categoryId,
    required this.tagIds,
    required this.date,
    this.description,
    this.status = TransactionStatus.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    String? accountId,
    String? toAccountId,
    TransactionType? type,
    double? amount,
    String? currency,
    String? categoryId,
    List<String>? tagIds,
    DateTime? date,
    String? description,
    TransactionStatus? status,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: this.id,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      tagIds: tagIds ?? this.tagIds,
      date: date ?? this.date,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'type': type.toString(),
      'amount': amount,
      'currency': currency,
      'categoryId': categoryId,
      'tagIds': tagIds,
      'date': date.toIso8601String(),
      'description': description,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      accountId: json['accountId'],
      toAccountId: json['toAccountId'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      amount: json['amount'],
      currency: json['currency'],
      categoryId: json['categoryId'],
      tagIds: List<String>.from(json['tagIds']),
      date: DateTime.parse(json['date']),
      description: json['description'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 