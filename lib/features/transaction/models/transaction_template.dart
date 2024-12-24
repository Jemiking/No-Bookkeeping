class TransactionTemplate {
  final String id;
  final String name;
  final double amount;
  final String categoryId;
  final String accountId;
  final String? description;
  final List<String> tagIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionTemplate({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    this.description,
    required this.tagIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'categoryId': categoryId,
      'accountId': accountId,
      'description': description,
      'tagIds': tagIds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransactionTemplate.fromMap(Map<String, dynamic> map) {
    return TransactionTemplate(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      categoryId: map['categoryId'],
      accountId: map['accountId'],
      description: map['description'],
      tagIds: (map['tagIds'] as String).split(','),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
} 