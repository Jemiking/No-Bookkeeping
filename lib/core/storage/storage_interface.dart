import 'storage_error.dart';

abstract class StorageInterface {
  Future<void> initialize();
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
  });
  Future<StorageResult> insert(String table, Map<String, dynamic> data);
  Future<StorageResult> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  });
  Future<StorageResult> delete(String table, {String? where, List<dynamic>? whereArgs});
  Future<void> close();
}

class StorageResult {
  final List<Map<String, dynamic>>? data;
  final StorageError? error;
  
  StorageResult({this.data, this.error});
  
  bool get hasError => error != null;
} 