import 'package:flutter/foundation.dart';

/// Base model class for all database models
abstract class BaseModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert model to map
  Map<String, dynamic> toMap();

  /// Create a copy of the model with updated fields
  BaseModel copyWith();

  /// Convert timestamps to database format
  static int toDbTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  /// Convert database timestamp to DateTime
  static DateTime fromDbTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => hashValues(id, createdAt, updatedAt);

  @override
  String toString() {
    return '$runtimeType{id: $id, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

/// Mixin for models with user association
mixin UserAssociated {
  String get userId;
}

/// Mixin for models with description
mixin Describable {
  String? get description;
}

/// Mixin for models with type
mixin Typed {
  String get type;
}

/// Mixin for models with name
mixin Named {
  String get name;
}

/// Mixin for models with color
mixin Colored {
  String? get color;
}

/// Mixin for models with icon
mixin Iconic {
  String? get icon;
}

/// Mixin for models that can be archived
mixin Archivable {
  bool get isArchived;
}

/// Mixin for models with amount
mixin Monetary {
  double get amount;
  String get currency;
}

/// Mixin for models with date range
mixin DateRanged {
  DateTime get startDate;
  DateTime? get endDate;
}

/// Base model builder class
abstract class BaseModelBuilder<T extends BaseModel> {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;

  /// Build the model
  T build();

  /// Reset the builder
  void reset() {
    id = null;
    createdAt = null;
    updatedAt = null;
  }

  /// Set creation timestamp
  void setCreatedNow() {
    createdAt = DateTime.now();
    updatedAt = createdAt;
  }

  /// Set update timestamp
  void setUpdatedNow() {
    updatedAt = DateTime.now();
  }
} 