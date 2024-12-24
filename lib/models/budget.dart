class Budget {
  final String? id;
  final String name;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    this.id,
    required this.name,
    required this.amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 