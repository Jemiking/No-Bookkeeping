import 'package:sqflite/sqflite.dart';

class QueryOptimizer {
  // 查询优化配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 10;
  static const Duration queryCacheExpiration = Duration(minutes: 5);

  // 查询缓存
  static final Map<String, _QueryCacheEntry> _queryCache = {};

  // 优化分页查询
  static String optimizePageQuery({
    required String baseQuery,
    required int offset,
    required int limit,
    String? orderBy,
    bool useCache = true,
  }) {
    // 验证并调整分页参数
    final adjustedLimit = limit.clamp(minPageSize, maxPageSize);
    final adjustedOffset = offset >= 0 ? offset : 0;

    // 构建优化后的查询
    final optimizedQuery = '''
      WITH filtered_results AS (
        $baseQuery
      )
      SELECT *
      FROM filtered_results
      ${orderBy != null ? 'ORDER BY $orderBy' : ''}
      LIMIT $adjustedLimit OFFSET $adjustedOffset
    ''';

    return optimizedQuery;
  }

  // 优化聚合查询
  static String optimizeAggregateQuery({
    required String baseQuery,
    required String aggregateFunction,
    required String aggregateColumn,
    String? groupBy,
    String? having,
  }) {
    // 构建优化后的查询
    final optimizedQuery = '''
      WITH base_data AS (
        $baseQuery
      )
      SELECT 
        ${groupBy ?? '1 as group_key'},
        $aggregateFunction($aggregateColumn) as aggregate_result
      FROM base_data
      ${groupBy != null ? 'GROUP BY $groupBy' : ''}
      ${having != null ? 'HAVING $having' : ''}
    ''';

    return optimizedQuery;
  }

  // 优化JOIN查询
  static String optimizeJoinQuery({
    required String baseTable,
    required List<_JoinClause> joins,
    String? where,
    String? orderBy,
    List<String>? columns,
  }) {
    // 构建选择的列
    final selectedColumns = columns?.join(', ') ?? '*';

    // 构建JOIN子句
    final joinClauses = joins.map((join) {
      return '${join.type} ${join.table} ON ${join.condition}';
    }).join('\n');

    // 构建优化后的查询
    final optimizedQuery = '''
      SELECT $selectedColumns
      FROM $baseTable
      $joinClauses
      ${where != null ? 'WHERE $where' : ''}
      ${orderBy != null ? 'ORDER BY $orderBy' : ''}
    ''';

    return optimizedQuery;
  }

  // 优化子查询
  static String optimizeSubquery({
    required String outerQuery,
    required String innerQuery,
    String? where,
  }) {
    // 构建优化后的查询
    final optimizedQuery = '''
      WITH inner_results AS (
        $innerQuery
      )
      SELECT *
      FROM ($outerQuery) outer_query
      ${where != null ? 'WHERE $where' : ''}
    ''';

    return optimizedQuery;
  }

  // 缓存查询结果
  static Future<List<Map<String, dynamic>>> cacheQuery(
    Database db,
    String sql,
    List<dynamic>? arguments,
    String cacheKey,
  ) async {
    // 检查缓存是否有效
    final cacheEntry = _queryCache[cacheKey];
    if (cacheEntry != null && !cacheEntry.isExpired) {
      return cacheEntry.data;
    }

    // 执行查询
    final results = await db.rawQuery(sql, arguments);

    // 更新缓存
    _queryCache[cacheKey] = _QueryCacheEntry(
      data: results,
      timestamp: DateTime.now(),
    );

    return results;
  }

  // 清除查询缓存
  static void clearQueryCache() {
    _queryCache.clear();
  }

  // 移除过期缓存
  static void removeExpiredCache() {
    final now = DateTime.now();
    _queryCache.removeWhere((key, entry) => entry.isExpired);
  }

  // 生成查询计划
  static Future<String> explainQuery(Database db, String sql) async {
    final results = await db.rawQuery('EXPLAIN QUERY PLAN $sql');
    return results.map((row) => row.toString()).join('\n');
  }

  // 分析查询性能
  static Future<Map<String, dynamic>> analyzeQuery(
    Database db,
    String sql,
    List<dynamic>? arguments,
  ) async {
    final startTime = DateTime.now();
    final results = await db.rawQuery(sql, arguments);
    final endTime = DateTime.now();

    return {
      'execution_time': endTime.difference(startTime),
      'row_count': results.length,
      'query_plan': await explainQuery(db, sql),
    };
  }
}

// 查询缓存条目
class _QueryCacheEntry {
  final List<Map<String, dynamic>> data;
  final DateTime timestamp;

  _QueryCacheEntry({
    required this.data,
    required this.timestamp,
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp) > QueryOptimizer.queryCacheExpiration;
}

// JOIN子句
class _JoinClause {
  final String type;
  final String table;
  final String condition;

  _JoinClause({
    required this.type,
    required this.table,
    required this.condition,
  });
} 