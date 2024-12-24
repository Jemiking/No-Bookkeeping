import 'package:sqflite/sqflite.dart';
import '../database_provider.dart';
import '../models/tag.dart';

/// 标签数据访问对象类
class TagDao {
  /// 数据库提供者
  final DatabaseProvider _provider;

  /// 表名
  static const String table = 'tags';
  static const String transactionTagTable = 'transaction_tags';

  /// 构造函数
  TagDao(this._provider);

  /// 插入标签
  Future<int> insert(Tag tag) async {
    final db = await _provider.database;
    return await db.insert(
      table,
      tag.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新标签
  Future<int> update(Tag tag) async {
    final db = await _provider.database;
    return await db.update(
      table,
      tag.toJson(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  /// 删除标签
  Future<int> delete(int id) async {
    return await _provider.transaction((txn) async {
      // 删除标签关联
      await txn.delete(
        transactionTagTable,
        where: 'tag_id = ?',
        whereArgs: [id],
      );

      // 删除标签
      return await txn.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  /// 获取标签
  Future<Tag?> get(int id) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Tag.fromJson(maps.first);
  }

  /// 获取所有标签
  Future<List<Tag>> getAll() async {
    final db = await _provider.database;
    final maps = await db.query(table);
    return maps.map((map) => Tag.fromJson(map)).toList();
  }

  /// 获取交易的标签
  Future<List<Tag>> getByTransaction(int transactionId) async {
    final db = await _provider.database;
    final maps = await db.rawQuery('''
      SELECT t.*
      FROM $table t
      INNER JOIN $transactionTagTable tt ON t.id = tt.tag_id
      WHERE tt.transaction_id = ?
    ''', [transactionId]);
    return maps.map((map) => Tag.fromJson(map)).toList();
  }

  /// 搜索标签
  Future<List<Tag>> search({
    String? keyword,
    bool? isSystem,
    bool? isActive,
    int? minUseCount,
    int? maxUseCount,
  }) async {
    final db = await _provider.database;
    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (keyword != null && keyword.isNotEmpty) {
      conditions.add('(name LIKE ? OR description LIKE ?)');
      arguments.addAll(['%$keyword%', '%$keyword%']);
    }

    if (isSystem != null) {
      conditions.add('is_system = ?');
      arguments.add(isSystem ? 1 : 0);
    }

    if (isActive != null) {
      conditions.add('is_active = ?');
      arguments.add(isActive ? 1 : 0);
    }

    if (minUseCount != null) {
      conditions.add('use_count >= ?');
      arguments.add(minUseCount);
    }

    if (maxUseCount != null) {
      conditions.add('use_count <= ?');
      arguments.add(maxUseCount);
    }

    String query = 'SELECT * FROM $table';
    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }
    query += ' ORDER BY use_count DESC, name ASC';

    final maps = await db.rawQuery(query, arguments);
    return maps.map((map) => Tag.fromJson(map)).toList();
  }

  /// 获取标签统计信息
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await _provider.database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_count,
        COUNT(CASE WHEN is_system = 1 THEN 1 END) as system_count,
        COUNT(CASE WHEN is_active = 1 THEN 1 END) as active_count,
        SUM(use_count) as total_uses,
        AVG(use_count) as average_uses,
        MAX(use_count) as max_uses,
        MIN(use_count) as min_uses
      FROM $table
    ''');
    return result.first;
  }

  /// 批量更新标签状态
  Future<int> updateStatus(List<int> ids, {bool? isActive}) async {
    final db = await _provider.database;
    final values = <String, dynamic>{};
    
    if (isActive != null) {
      values['is_active'] = isActive ? 1 : 0;
    }
    
    if (values.isEmpty) {
      return 0;
    }

    return await db.update(
      table,
      values,
      where: 'id IN (${List.filled(ids.length, '?').join(', ')})',
      whereArgs: ids,
    );
  }

  /// 增加标签使用次数
  Future<void> incrementUseCount(int id) async {
    final db = await _provider.database;
    await db.rawUpdate('''
      UPDATE $table
      SET use_count = use_count + 1
      WHERE id = ?
    ''', [id]);
  }

  /// 减少标签使用次数
  Future<void> decrementUseCount(int id) async {
    final db = await _provider.database;
    await db.rawUpdate('''
      UPDATE $table
      SET use_count = CASE 
        WHEN use_count > 0 THEN use_count - 1
        ELSE 0
      END
      WHERE id = ?
    ''', [id]);
  }

  /// 获取标签使用统计
  Future<List<Map<String, dynamic>>> getUsageStatistics() async {
    final db = await _provider.database;
    return await db.rawQuery('''
      SELECT 
        t.id,
        t.name,
        COUNT(DISTINCT tt.transaction_id) as transaction_count,
        t.use_count,
        (
          SELECT MAX(tr.date)
          FROM $transactionTagTable tt2
          INNER JOIN transactions tr ON tt2.transaction_id = tr.id
          WHERE tt2.tag_id = t.id
        ) as last_used
      FROM $table t
      LEFT JOIN $transactionTagTable tt ON t.id = tt.tag_id
      GROUP BY t.id, t.name
      ORDER BY transaction_count DESC, t.use_count DESC
    ''');
  }

  /// 获取相关标签
  Future<List<Tag>> getRelatedTags(int tagId) async {
    final db = await _provider.database;
    return await db.transaction((txn) async {
      // 获取当前标签的所有交易
      final transactionIds = await txn.query(
        transactionTagTable,
        columns: ['transaction_id'],
        where: 'tag_id = ?',
        whereArgs: [tagId],
      );

      if (transactionIds.isEmpty) {
        return [];
      }

      // 获取这些交易中使用的其他标签
      final ids = transactionIds.map((m) => m['transaction_id'] as int).toList();
      final maps = await txn.rawQuery('''
        SELECT t.*, COUNT(DISTINCT tt.transaction_id) as common_transactions
        FROM $table t
        INNER JOIN $transactionTagTable tt ON t.id = tt.tag_id
        WHERE tt.transaction_id IN (${List.filled(ids.length, '?').join(', ')})
        AND t.id != ?
        GROUP BY t.id
        ORDER BY common_transactions DESC
        LIMIT 10
      ''', [...ids, tagId]);

      return maps.map((map) => Tag.fromJson(map)).toList();
    });
  }

  /// 合并标签
  Future<bool> mergeTags(int sourceId, int targetId) async {
    if (sourceId == targetId) {
      return false;
    }

    return await _provider.transaction((txn) async {
      try {
        // 获取源标签的使用次数
        final sourceMaps = await txn.query(
          table,
          columns: ['use_count'],
          where: 'id = ?',
          whereArgs: [sourceId],
        );

        if (sourceMaps.isEmpty) {
          return false;
        }

        final sourceUseCount = sourceMaps.first['use_count'] as int;

        // 更新目标标签的使用次数
        await txn.rawUpdate('''
          UPDATE $table
          SET use_count = use_count + ?
          WHERE id = ?
        ''', [sourceUseCount, targetId]);

        // 更新交易标签关联
        await txn.rawUpdate('''
          UPDATE $transactionTagTable
          SET tag_id = ?
          WHERE tag_id = ?
        ''', [targetId, sourceId]);

        // 删除源标签
        await txn.delete(
          table,
          where: 'id = ?',
          whereArgs: [sourceId],
        );

        return true;
      } catch (e) {
        return false;
      }
    });
  }
} 