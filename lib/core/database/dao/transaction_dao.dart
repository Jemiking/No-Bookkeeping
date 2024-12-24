import 'package:sqflite/sqflite.dart';
import '../database_provider.dart';
import '../models/transaction.dart';

/// 交易数据访问对象类
class TransactionDao {
  /// 数据库提供者
  final DatabaseProvider _provider;

  /// 表名
  static const String table = 'transactions';
  static const String tagTable = 'transaction_tags';

  /// 构造函数
  TransactionDao(this._provider);

  /// 插入交易记录
  Future<int> insert(Transaction transaction) async {
    return await _provider.transaction((txn) async {
      // 插入交易记录
      final id = await txn.insert(
        table,
        transaction.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 如果有标签，插入标签关联
      if (transaction.tagIds != null && transaction.tagIds!.isNotEmpty) {
        final batch = txn.batch();
        for (final tagId in transaction.tagIds!) {
          batch.insert(
            tagTable,
            {
              'transaction_id': id,
              'tag_id': tagId,
            },
          );
        }
        await batch.commit();
      }

      return id;
    });
  }

  /// 更新交易记录
  Future<int> update(Transaction transaction) async {
    return await _provider.transaction((txn) async {
      // 更新交易记录
      final count = await txn.update(
        table,
        transaction.toJson(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      // 更新标签关联
      if (transaction.id != null) {
        // 删除旧的标签关联
        await txn.delete(
          tagTable,
          where: 'transaction_id = ?',
          whereArgs: [transaction.id],
        );

        // 插入新的标签关联
        if (transaction.tagIds != null && transaction.tagIds!.isNotEmpty) {
          final batch = txn.batch();
          for (final tagId in transaction.tagIds!) {
            batch.insert(
              tagTable,
              {
                'transaction_id': transaction.id,
                'tag_id': tagId,
              },
            );
          }
          await batch.commit();
        }
      }

      return count;
    });
  }

  /// 删除交易记录
  Future<int> delete(int id) async {
    return await _provider.transaction((txn) async {
      // 删除标签关联
      await txn.delete(
        tagTable,
        where: 'transaction_id = ?',
        whereArgs: [id],
      );

      // 删除交易记录
      return await txn.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  /// 获取交易记录
  Future<Transaction?> get(int id) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    // 获取标签ID列表
    final tagMaps = await db.query(
      tagTable,
      columns: ['tag_id'],
      where: 'transaction_id = ?',
      whereArgs: [id],
    );

    final tagIds = tagMaps.map((m) => m['tag_id'] as int).toList();
    final map = maps.first;
    map['tag_ids'] = tagIds;

    return Transaction.fromJson(map);
  }

  /// 获取所有交易记录
  Future<List<Transaction>> getAll() async {
    final db = await _provider.database;
    final maps = await db.query(table);
    return _attachTagIds(maps);
  }

  /// 获取账户的交易记录
  Future<List<Transaction>> getByAccount(int accountId) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'account_id = ? OR to_account_id = ?',
      whereArgs: [accountId, accountId],
      orderBy: 'date DESC',
    );
    return _attachTagIds(maps);
  }

  /// 获取分类的交易记录
  Future<List<Transaction>> getByCategory(int categoryId) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return _attachTagIds(maps);
  }

  /// 获取标签的交易记录
  Future<List<Transaction>> getByTag(int tagId) async {
    final db = await _provider.database;
    final transactionIds = await db.query(
      tagTable,
      columns: ['transaction_id'],
      where: 'tag_id = ?',
      whereArgs: [tagId],
    );

    if (transactionIds.isEmpty) {
      return [];
    }

    final ids = transactionIds.map((m) => m['transaction_id'] as int).toList();
    final maps = await db.query(
      table,
      where: 'id IN (${List.filled(ids.length, '?').join(', ')})',
      whereArgs: ids,
      orderBy: 'date DESC',
    );
    return _attachTagIds(maps);
  }

  /// 获取日期范围内的交易记录
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return _attachTagIds(maps);
  }

  /// 搜索交易记录
  Future<List<Transaction>> search({
    String? keyword,
    List<TransactionType>? types,
    List<int>? accountIds,
    List<int>? categoryIds,
    List<int>? tagIds,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    TransactionStatus? status,
  }) async {
    final db = await _provider.database;
    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (keyword != null && keyword.isNotEmpty) {
      conditions.add('(note LIKE ? OR location LIKE ?)');
      arguments.addAll(['%$keyword%', '%$keyword%']);
    }

    if (types != null && types.isNotEmpty) {
      conditions.add('type IN (${List.filled(types.length, '?').join(', ')})');
      arguments.addAll(types.map((t) => t.index));
    }

    if (accountIds != null && accountIds.isNotEmpty) {
      conditions.add('(account_id IN (${List.filled(accountIds.length, '?').join(', ')}) OR to_account_id IN (${List.filled(accountIds.length, '?').join(', ')}))');
      arguments.addAll(accountIds);
      arguments.addAll(accountIds);
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      conditions.add('category_id IN (${List.filled(categoryIds.length, '?').join(', ')})');
      arguments.addAll(categoryIds);
    }

    if (startDate != null) {
      conditions.add('date >= ?');
      arguments.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      conditions.add('date <= ?');
      arguments.add(endDate.toIso8601String());
    }

    if (minAmount != null) {
      conditions.add('amount >= ?');
      arguments.add(minAmount);
    }

    if (maxAmount != null) {
      conditions.add('amount <= ?');
      arguments.add(maxAmount);
    }

    if (status != null) {
      conditions.add('status = ?');
      arguments.add(status.index);
    }

    String query = 'SELECT DISTINCT t.* FROM $table t';
    
    if (tagIds != null && tagIds.isNotEmpty) {
      query += ' INNER JOIN $tagTable tt ON t.id = tt.transaction_id';
      conditions.add('tt.tag_id IN (${List.filled(tagIds.length, '?').join(', ')})');
      arguments.addAll(tagIds);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY date DESC';

    final maps = await db.rawQuery(query, arguments);
    return _attachTagIds(maps);
  }

  /// 获取统计数据
  Future<Map<String, dynamic>> getStatistics({
    List<int>? accountIds,
    List<int>? categoryIds,
    List<int>? tagIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _provider.database;
    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (accountIds != null && accountIds.isNotEmpty) {
      conditions.add('account_id IN (${List.filled(accountIds.length, '?').join(', ')})');
      arguments.addAll(accountIds);
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      conditions.add('category_id IN (${List.filled(categoryIds.length, '?').join(', ')})');
      arguments.addAll(categoryIds);
    }

    if (startDate != null) {
      conditions.add('date >= ?');
      arguments.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      conditions.add('date <= ?');
      arguments.add(endDate.toIso8601String());
    }

    String baseQuery = '''
      SELECT 
        COUNT(*) as total_count,
        SUM(CASE WHEN type = ${TransactionType.income.index} THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN type = ${TransactionType.expense.index} THEN amount ELSE 0 END) as total_expense,
        SUM(CASE WHEN type = ${TransactionType.transfer.index} THEN amount ELSE 0 END) as total_transfer,
        AVG(amount) as average_amount,
        MIN(amount) as min_amount,
        MAX(amount) as max_amount
      FROM $table
    ''';

    if (tagIds != null && tagIds.isNotEmpty) {
      baseQuery = '''
        SELECT 
          COUNT(DISTINCT t.id) as total_count,
          SUM(CASE WHEN t.type = ${TransactionType.income.index} THEN t.amount ELSE 0 END) as total_income,
          SUM(CASE WHEN t.type = ${TransactionType.expense.index} THEN t.amount ELSE 0 END) as total_expense,
          SUM(CASE WHEN t.type = ${TransactionType.transfer.index} THEN t.amount ELSE 0 END) as total_transfer,
          AVG(t.amount) as average_amount,
          MIN(t.amount) as min_amount,
          MAX(t.amount) as max_amount
        FROM $table t
        INNER JOIN $tagTable tt ON t.id = tt.transaction_id
        WHERE tt.tag_id IN (${List.filled(tagIds.length, '?').join(', ')})
      ''';
      arguments.addAll(tagIds);

      if (conditions.isNotEmpty) {
        baseQuery += ' AND ${conditions.join(' AND ')}';
      }
    } else if (conditions.isNotEmpty) {
      baseQuery += ' WHERE ${conditions.join(' AND ')}';
    }

    final result = await db.rawQuery(baseQuery, arguments);
    return result.first;
  }

  /// 为交易记录列表附加标签ID
  Future<List<Transaction>> _attachTagIds(List<Map<String, dynamic>> maps) async {
    if (maps.isEmpty) {
      return [];
    }

    final db = await _provider.database;
    final transactions = <Transaction>[];

    for (final map in maps) {
      final transactionId = map['id'] as int;
      final tagMaps = await db.query(
        tagTable,
        columns: ['tag_id'],
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      final tagIds = tagMaps.map((m) => m['tag_id'] as int).toList();
      map['tag_ids'] = tagIds;
      transactions.add(Transaction.fromJson(map));
    }

    return transactions;
  }
} 