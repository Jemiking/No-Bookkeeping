class AccountGroup {
  final String id;
  String name;
  String? description;
  List<String> accountIds;
  DateTime createdAt;
  DateTime updatedAt;

  AccountGroup({
    required this.id,
    required this.name,
    this.description,
    required this.accountIds,
    required this.createdAt,
    required this.updatedAt,
  });

  AccountGroup copyWith({
    String? name,
    String? description,
    List<String>? accountIds,
    DateTime? updatedAt,
  }) {
    return AccountGroup(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      accountIds: accountIds ?? this.accountIds,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'accountIds': accountIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AccountGroup.fromJson(Map<String, dynamic> json) {
    return AccountGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      accountIds: List<String>.from(json['accountIds']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 