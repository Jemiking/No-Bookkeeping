import 'package:sqflite/sqflite.dart';
import '../domain/batch_operation.dart';

class BatchOperationRepository {
  final Database database;

  BatchOperationRepository(this.database);

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS batch_operations (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        transactionIds TEXT NOT NULL,
        updateData TEXT,
        createdAt TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        error TEXT
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS batch_operation_results (
        batchId TEXT PRIMARY KEY,
        isSuccess INTEGER NOT NULL,
        successfulIds TEXT NOT NULL,
        failedIds TEXT NOT NULL,
        errors TEXT NOT NULL,
        FOREIGN KEY (batchId) REFERENCES batch_operations (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<String> create(BatchOperation operation) async {
    await database.insert('batch_operations', {
      'id': operation.id,
      'type': operation.type.toString(),
      'transactionIds': operation.transactionIds.join(','),
      'updateData': operation.updateData?.toString(),
      'createdAt': operation.createdAt.toIso8601String(),
      'isCompleted': operation.isCompleted ? 1 : 0,
      'error': operation.error,
    });
    return operation.id;
  }

  Future<BatchOperation?> get(String id) async {
    final maps = await database.query(
      'batch_operations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    final map = maps.first;
    return BatchOperation(
      id: map['id'] as String,
      type: BatchOperationType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      transactionIds: (map['transactionIds'] as String).split(','),
      updateData: map['updateData'] != null
          ? Map<String, dynamic>.from(
              // 简单的字符串转换，实际应用中应该使用 JSON 序列化
              map['updateData'] as Map<String, dynamic>,
            )
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
      error: map['error'] as String?,
    );
  }

  Future<List<BatchOperation>> getAll() async {
    final maps = await database.query('batch_operations');
    return maps.map((map) {
      return BatchOperation(
        id: map['id'] as String,
        type: BatchOperationType.values.firstWhere(
          (e) => e.toString() == map['type'],
        ),
        transactionIds: (map['transactionIds'] as String).split(','),
        updateData: map['updateData'] != null
            ? Map<String, dynamic>.from(
                // 简单的字符串转换，实际应用中应该使用 JSON 序列化
                map['updateData'] as Map<String, dynamic>,
              )
            : null,
        createdAt: DateTime.parse(map['createdAt'] as String),
        isCompleted: (map['isCompleted'] as int) == 1,
        error: map['error'] as String?,
      );
    }).toList();
  }

  Future<List<BatchOperation>> getPending() async {
    final maps = await database.query(
      'batch_operations',
      where: 'isCompleted = ?',
      whereArgs: [0],
    );
    return maps.map((map) {
      return BatchOperation(
        id: map['id'] as String,
        type: BatchOperationType.values.firstWhere(
          (e) => e.toString() == map['type'],
        ),
        transactionIds: (map['transactionIds'] as String).split(','),
        updateData: map['updateData'] != null
            ? Map<String, dynamic>.from(
                // 简单的字符串转换，实际应用中应该使用 JSON 序列化
                map['updateData'] as Map<String, dynamic>,
              )
            : null,
        createdAt: DateTime.parse(map['createdAt'] as String),
        isCompleted: (map['isCompleted'] as int) == 1,
        error: map['error'] as String?,
      );
    }).toList();
  }

  Future<void> markAsCompleted(String id, {String? error}) async {
    await database.update(
      'batch_operations',
      {
        'isCompleted': 1,
        'error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    await database.delete(
      'batch_operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveResult(BatchOperationResult result) async {
    await database.insert('batch_operation_results', {
      'batchId': result.batchId,
      'isSuccess': result.isSuccess ? 1 : 0,
      'successfulIds': result.successfulIds.join(','),
      'failedIds': result.failedIds.join(','),
      'errors': result.errors.toString(), // 简单的字符串转换，实际应用中应该使用 JSON 序列化
    });
  }

  Future<BatchOperationResult?> getResult(String batchId) async {
    final maps = await database.query(
      'batch_operation_results',
      where: 'batchId = ?',
      whereArgs: [batchId],
    );

    if (maps.isEmpty) {
      return null;
    }

    final map = maps.first;
    return BatchOperationResult(
      batchId: map['batchId'] as String,
      isSuccess: (map['isSuccess'] as int) == 1,
      successfulIds: (map['successfulIds'] as String).split(','),
      failedIds: (map['failedIds'] as String).split(','),
      errors: Map<String, String>.from(
        // 简单的字符串转换，实际应用中应该使用 JSON 序列化
        map['errors'] as Map<String, String>,
      ),
    );
  }

  Future<void> deleteResult(String batchId) async {
    await database.delete(
      'batch_operation_results',
      where: 'batchId = ?',
      whereArgs: [batchId],
    );
  }
} 