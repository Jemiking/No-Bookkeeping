import 'package:sqflite/sqflite.dart';

class QueryBuilder {
  String? _table;
  List<String> _columns = ['*'];
  String? _where;
  List<dynamic> _whereArgs = [];
  String? _groupBy;
  String? _having;
  String? _orderBy;
  int? _limit;
  int? _offset;
  List<String> _joins = [];
  bool _distinct = false;

  // 设置表名
  QueryBuilder from(String table) {
    _table = table;
    return this;
  }

  // 设置查询列
  QueryBuilder select(List<String> columns) {
    _columns = columns;
    return this;
  }

  // 设置是否去重
  QueryBuilder distinct(bool distinct) {
    _distinct = distinct;
    return this;
  }

  // 添加WHERE条件
  QueryBuilder where(String where, [List<dynamic>? whereArgs]) {
    if (_where == null) {
      _where = where;
      if (whereArgs != null) _whereArgs = whereArgs;
    } else {
      _where = '$_where AND ($where)';
      if (whereArgs != null) _whereArgs.addAll(whereArgs);
    }
    return this;
  }

  // 添加OR WHERE条件
  QueryBuilder orWhere(String where, [List<dynamic>? whereArgs]) {
    if (_where == null) {
      _where = where;
      if (whereArgs != null) _whereArgs = whereArgs;
    } else {
      _where = '$_where OR ($where)';
      if (whereArgs != null) _whereArgs.addAll(whereArgs);
    }
    return this;
  }

  // 添加IN条件
  QueryBuilder whereIn(String column, List<dynamic> values) {
    final placeholders = List.filled(values.length, '?').join(',');
    return where('$column IN ($placeholders)', values);
  }

  // 添加NOT IN条件
  QueryBuilder whereNotIn(String column, List<dynamic> values) {
    final placeholders = List.filled(values.length, '?').join(',');
    return where('$column NOT IN ($placeholders)', values);
  }

  // 添加BETWEEN条件
  QueryBuilder whereBetween(String column, dynamic from, dynamic to) {
    return where('$column BETWEEN ? AND ?', [from, to]);
  }

  // 添加NULL条件
  QueryBuilder whereNull(String column) {
    return where('$column IS NULL');
  }

  // 添加NOT NULL条件
  QueryBuilder whereNotNull(String column) {
    return where('$column IS NOT NULL');
  }

  // 添加LIKE条件
  QueryBuilder whereLike(String column, String pattern) {
    return where('$column LIKE ?', [pattern]);
  }

  // 添加JOIN
  QueryBuilder join(String table, String condition, [String type = 'INNER']) {
    _joins.add('$type JOIN $table ON $condition');
    return this;
  }

  // 添加LEFT JOIN
  QueryBuilder leftJoin(String table, String condition) {
    return join(table, condition, 'LEFT');
  }

  // 添加RIGHT JOIN
  QueryBuilder rightJoin(String table, String condition) {
    return join(table, condition, 'RIGHT');
  }

  // 设置GROUP BY
  QueryBuilder groupBy(String groupBy) {
    _groupBy = groupBy;
    return this;
  }

  // 设置HAVING
  QueryBuilder having(String having) {
    _having = having;
    return this;
  }

  // 设置ORDER BY
  QueryBuilder orderBy(String orderBy) {
    _orderBy = orderBy;
    return this;
  }

  // 设置LIMIT
  QueryBuilder limit(int limit) {
    _limit = limit;
    return this;
  }

  // 设置OFFSET
  QueryBuilder offset(int offset) {
    _offset = offset;
    return this;
  }

  // 构建查询
  String build() {
    if (_table == null) {
      throw Exception('Table name is required');
    }

    final query = StringBuffer();

    // SELECT
    query.write('SELECT ');
    if (_distinct) query.write('DISTINCT ');
    query.write(_columns.join(', '));

    // FROM
    query.write('\nFROM $_table');

    // JOIN
    if (_joins.isNotEmpty) {
      query.write('\n');
      query.write(_joins.join('\n'));
    }

    // WHERE
    if (_where != null) {
      query.write('\nWHERE $_where');
    }

    // GROUP BY
    if (_groupBy != null) {
      query.write('\nGROUP BY $_groupBy');
    }

    // HAVING
    if (_having != null) {
      query.write('\nHAVING $_having');
    }

    // ORDER BY
    if (_orderBy != null) {
      query.write('\nORDER BY $_orderBy');
    }

    // LIMIT & OFFSET
    if (_limit != null) {
      query.write('\nLIMIT $_limit');
      if (_offset != null) {
        query.write(' OFFSET $_offset');
      }
    }

    return query.toString();
  }

  // 获取查询参数
  List<dynamic> getArguments() {
    return _whereArgs;
  }

  // 执行查询
  Future<List<Map<String, dynamic>>> execute(Database db) async {
    return await db.rawQuery(build(), getArguments());
  }

  // 执行查询并返回第一条记录
  Future<Map<String, dynamic>?> first(Database db) async {
    final results = await execute(db);
    return results.isEmpty ? null : results.first;
  }

  // 执行查询并返回单个值
  Future<T?> value<T>(Database db) async {
    final result = await first(db);
    return result?.values.first as T?;
  }

  // 执行COUNT查询
  Future<int> count(Database db) async {
    final originalColumns = _columns;
    _columns = ['COUNT(*) as count'];
    final result = await first(db);
    _columns = originalColumns;
    return result?['count'] as int? ?? 0;
  }
} 