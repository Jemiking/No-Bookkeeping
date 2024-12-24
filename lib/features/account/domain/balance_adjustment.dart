class BalanceAdjustment {
  final String id;
  final String accountId;
  final double amount;
  final String reason;
  final String status;
  final DateTime createdAt;
  final DateTime? appliedAt;
  final String createdBy;
  final String? approvedBy;
  final String? notes;

  const BalanceAdjustment({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.appliedAt,
    required this.createdBy,
    this.approvedBy,
    this.notes,
  });

  factory BalanceAdjustment.fromMap(Map<String, dynamic> map) {
    return BalanceAdjustment(
      id: map['id'] as String,
      accountId: map['account_id'] as String,
      amount: map['amount'] as double,
      reason: map['reason'] as String,
      status: map['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      appliedAt: map['applied_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['applied_at'] as int)
          : null,
      createdBy: map['created_by'] as String,
      approvedBy: map['approved_by'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'amount': amount,
      'reason': reason,
      'status': status,
      'created_at': createdAt.millisecondsSinceEpoch,
      'applied_at': appliedAt?.millisecondsSinceEpoch,
      'created_by': createdBy,
      'approved_by': approvedBy,
      'notes': notes,
    };
  }

  BalanceAdjustment copyWith({
    String? id,
    String? accountId,
    double? amount,
    String? reason,
    String? status,
    DateTime? createdAt,
    DateTime? appliedAt,
    String? createdBy,
    String? approvedBy,
    String? notes,
  }) {
    return BalanceAdjustment(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      appliedAt: appliedAt ?? this.appliedAt,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'BalanceAdjustment(id: $id, accountId: $accountId, amount: $amount, '
        'reason: $reason, status: $status, createdAt: $createdAt, '
        'appliedAt: $appliedAt, createdBy: $createdBy, '
        'approvedBy: $approvedBy, notes: $notes)';
  }
} 