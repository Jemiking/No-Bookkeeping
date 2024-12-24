class TagRelation {
  final String id;
  final String tagId;
  final String entityId;
  final String entityType;
  final DateTime createdAt;

  TagRelation({
    required this.id,
    required this.tagId,
    required this.entityId,
    required this.entityType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagId': tagId,
      'entityId': entityId,
      'entityType': entityType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TagRelation.fromMap(Map<String, dynamic> map) {
    return TagRelation(
      id: map['id'],
      tagId: map['tagId'],
      entityId: map['entityId'],
      entityType: map['entityType'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}