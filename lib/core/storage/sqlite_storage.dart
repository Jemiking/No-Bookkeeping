import 'package:sqflite/sqflite.dart';
import 'storage_interface.dart';
import 'storage_error.dart';

class SQLiteStorage implements StorageInterface {
  late Database _db;
  
  @override
  Future<void> initialize() async {
    try {
      _db = await openDatabase(
        'app_database.db',
        version: 1,
        onCreate: (Database db, int version) async {
          // 在这里创建数据库表
        },
      );
    } catch (e, stackTrace) {
      throw StorageError(
        code: 'INIT_ERROR',
        message: 'Failed to initialize SQLite database',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<StorageResult> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final List<Map<String, dynamic>> result = await _db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      return StorageResult(data: result);
    } catch (e, stackTrace) {
      return StorageResult(
        error: StorageError(
          code: 'QUERY_ERROR',
          message: 'Failed to execute query',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<StorageResult> insert(String table, Map<String, dynamic> data) async {
    try {
      final id = await _db.insert(table, data);
      return StorageResult(data: [{'id': id, ...data}]);
    } catch (e, stackTrace) {
      return StorageResult(
        error: StorageError(
          code: 'INSERT_ERROR',
          message: 'Failed to insert data',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<StorageResult> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final count = await _db.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
      );
      return StorageResult(data: [{'updated': count}]);
    } catch (e, stackTrace) {
      return StorageResult(
        error: StorageError(
          code: 'UPDATE_ERROR',
          message: 'Failed to update data',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<StorageResult> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final count = await _db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      return StorageResult(data: [{'deleted': count}]);
    } catch (e, stackTrace) {
      return StorageResult(
        error: StorageError(
          code: 'DELETE_ERROR',
          message: 'Failed to delete data',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _db.close();
  }
} 