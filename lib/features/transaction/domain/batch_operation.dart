import 'package:uuid/uuid.dart';
import 'transaction.dart';

enum BatchOperationType {
  delete,
  update,
  archive,
  unarchive,
  changeCategory,
  changeAccount,
  addTags,
  removeTags,
}

class BatchOperation {
  final String id;
  final BatchOperationType type;
  final List<String> transactionIds;
  final Map<String, dynamic>? updateData;
  final DateTime createdAt;
  final bool isCompleted;
  final String? error;

  BatchOperation({
    required this.id,
    required this.type,
    required this.transactionIds,
    this.updateData,
    required this.createdAt,
    this.isCompleted = false,
    this.error,
  });

  BatchOperation copyWith({
    String? id,
    BatchOperationType? type,
    List<String>? transactionIds,
    Map<String, dynamic>? updateData,
    DateTime? createdAt,
    bool? isCompleted,
    String? error,
  }) {
    return BatchOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      transactionIds: transactionIds ?? this.transactionIds,
      updateData: updateData ?? this.updateData,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'transactionIds': transactionIds,
      'updateData': updateData,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'error': error,
    };
  }

  factory BatchOperation.fromJson(Map<String, dynamic> json) {
    return BatchOperation(
      id: json['id'],
      type: BatchOperationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      transactionIds: List<String>.from(json['transactionIds']),
      updateData: json['updateData'],
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'],
      error: json['error'],
    );
  }

  static BatchOperation createBatchOperation({
    required BatchOperationType type,
    required List<String> transactionIds,
    Map<String, dynamic>? updateData,
  }) {
    return BatchOperation(
      id: const Uuid().v4(),
      type: type,
      transactionIds: transactionIds,
      updateData: updateData,
      createdAt: DateTime.now(),
    );
  }
}

class BatchOperationResult {
  final String batchId;
  final bool isSuccess;
  final List<String> successfulIds;
  final List<String> failedIds;
  final Map<String, String> errors;

  BatchOperationResult({
    required this.batchId,
    required this.isSuccess,
    required this.successfulIds,
    required this.failedIds,
    required this.errors,
  });

  BatchOperationResult copyWith({
    String? batchId,
    bool? isSuccess,
    List<String>? successfulIds,
    List<String>? failedIds,
    Map<String, String>? errors,
  }) {
    return BatchOperationResult(
      batchId: batchId ?? this.batchId,
      isSuccess: isSuccess ?? this.isSuccess,
      successfulIds: successfulIds ?? this.successfulIds,
      failedIds: failedIds ?? this.failedIds,
      errors: errors ?? this.errors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'isSuccess': isSuccess,
      'successfulIds': successfulIds,
      'failedIds': failedIds,
      'errors': errors,
    };
  }

  factory BatchOperationResult.fromJson(Map<String, dynamic> json) {
    return BatchOperationResult(
      batchId: json['batchId'],
      isSuccess: json['isSuccess'],
      successfulIds: List<String>.from(json['successfulIds']),
      failedIds: List<String>.from(json['failedIds']),
      errors: Map<String, String>.from(json['errors']),
    );
  }

  static BatchOperationResult createSuccessResult(String batchId, List<String> successfulIds) {
    return BatchOperationResult(
      batchId: batchId,
      isSuccess: true,
      successfulIds: successfulIds,
      failedIds: [],
      errors: {},
    );
  }

  static BatchOperationResult createPartialSuccessResult(
    String batchId,
    List<String> successfulIds,
    List<String> failedIds,
    Map<String, String> errors,
  ) {
    return BatchOperationResult(
      batchId: batchId,
      isSuccess: false,
      successfulIds: successfulIds,
      failedIds: failedIds,
      errors: errors,
    );
  }

  static BatchOperationResult createFailureResult(
    String batchId,
    List<String> failedIds,
    Map<String, String> errors,
  ) {
    return BatchOperationResult(
      batchId: batchId,
      isSuccess: false,
      successfulIds: [],
      failedIds: failedIds,
      errors: errors,
    );
  }
} 