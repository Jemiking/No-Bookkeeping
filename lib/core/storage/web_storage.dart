import 'dart:html' as html;
import 'dart:convert';
import 'storage_interface.dart';
import 'storage_error.dart';

class WebStorageImpl implements StorageInterface {
  final html.Storage _localStorage = html.window.localStorage;

  @override
  Future<void> initialize() async {
    // Web存储不需要特殊初始化
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
      final String? data = _localStorage['${table}_data'];
      if (data == null) {
        return StorageResult(data: []);
      }

      List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
        (jsonDecode(data) as List).map((item) => Map<String, dynamic>.from(item))
      );

      // 应用查询条件
      if (where != null) {
        items = items.where((item) => _matchesWhere(item, where, whereArgs)).toList();
      }

      // 应用排序
      if (orderBy != null) {
        final orderParts = orderBy.split(' ');
        final field = orderParts[0];
        final isDesc = orderParts.length > 1 && orderParts[1].toLowerCase() == 'desc';
        items.sort((a, b) {
          final aValue = a[field];
          final bValue = b[field];
          return isDesc ? _compare(bValue, aValue) : _compare(aValue, bValue);
        });
      }

      // 应用分页
      if (offset != null || limit != null) {
        final startIndex = offset ?? 0;
        final endIndex = limit != null ? startIndex + limit : items.length;
        items = items.sublist(startIndex, endIndex.clamp(0, items.length));
      }

      return StorageResult(data: items);
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
      final String? existingData = _localStorage['${table}_data'];
      final List<Map<String, dynamic>> items = existingData != null
          ? List<Map<String, dynamic>>.from(
              (jsonDecode(existingData) as List).map((item) => Map<String, dynamic>.from(item))
            )
          : [];

      items.add(data);
      _localStorage['${table}_data'] = jsonEncode(items);

      return StorageResult(data: [data]);
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
      final String? existingData = _localStorage['${table}_data'];
      if (existingData == null) {
        return StorageResult(data: [{'updated': 0}]);
      }

      List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
        (jsonDecode(existingData) as List).map((item) => Map<String, dynamic>.from(item))
      );

      int updatedCount = 0;
      for (var i = 0; i < items.length; i++) {
        if (where == null || _matchesWhere(items[i], where, whereArgs)) {
          items[i].addAll(values);
          updatedCount++;
        }
      }

      _localStorage['${table}_data'] = jsonEncode(items);
      return StorageResult(data: [{'updated': updatedCount}]);
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
      if (where == null) {
        _localStorage.remove('${table}_data');
        return StorageResult(data: [{'deleted': 1}]);
      }

      final String? existingData = _localStorage['${table}_data'];
      if (existingData == null) {
        return StorageResult(data: [{'deleted': 0}]);
      }

      List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
        (jsonDecode(existingData) as List).map((item) => Map<String, dynamic>.from(item))
      );

      final initialLength = items.length;
      items.removeWhere((item) => _matchesWhere(item, where, whereArgs));
      final deletedCount = initialLength - items.length;

      _localStorage['${table}_data'] = jsonEncode(items);
      return StorageResult(data: [{'deleted': deletedCount}]);
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
    // Web存储不需要特殊清理
  }

  bool _matchesWhere(Map<String, dynamic> item, String where, List<Object?>? whereArgs) {
    // 简单的WHERE条件解析
    final parts = where.split(' ');
    if (parts.length != 3) return true;

    final field = parts[0];
    final operator = parts[1];
    final value = whereArgs?.firstOrNull;

    final itemValue = item[field];

    switch (operator) {
      case '=':
        return itemValue == value;
      case '>':
        return _compare(itemValue, value) > 0;
      case '<':
        return _compare(itemValue, value) < 0;
      case '>=':
        return _compare(itemValue, value) >= 0;
      case '<=':
        return _compare(itemValue, value) <= 0;
      case '!=':
        return itemValue != value;
      default:
        return true;
    }
  }

  int _compare(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    if (a is num && b is num) {
      return a.compareTo(b);
    }

    if (a is String && b is String) {
      return a.compareTo(b);
    }

    if (a is DateTime && b is DateTime) {
      return a.compareTo(b);
    }

    return a.toString().compareTo(b.toString());
  }
} 