import 'package:sqflite/sqflite.dart';
import '../database_provider.dart';
import '../models/budget.dart';

/// 预算数据访问对象类
class BudgetDao {
  /// 数据库提供者
  final DatabaseProvider _provider;

  /// 表名
  static const String table = 'budgets';
  static const String categoryTable = 'budget_categories';

  /// 构造函数
  BudgetDao(this._provider);

  /// 插入预算
  Future<int> insert(Budget budget) async {
    return await _provider.transaction((txn) async {
      // 插入预算记录
      final id = await txn.insert(
        table,
        budget.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 如果有分类，插入分类关联
      if (budget.categoryIds != null && budget.categoryIds!.isNotEmpty) {
        final batch = txn.batch();
        for (final categoryId in budget.categoryIds!) {
          batch.insert(
            categoryTable,
            {
              'budget_id': id,
              'category_id': categoryId,
            },
          );
        }
        await batch.commit();
      }

      return id;
    });
  }

  /// 更新预算
  Future<int> update(Budget budget) async {
    return await _provider.transaction((txn) async {
      // 更新预算记录
      final count = await txn.update(
        table,
        budget.toJson(),
        where: 'id = ?',
        whereArgs: [budget.id],
      );

      // 更新分类关联
      if (budget.id != null) {
        // 删除旧的分类关联
        await txn.delete(
          categoryTable,
          where: 'budget_id = ?',
          whereArgs: [budget.id],
        );

        // 插入新的分类关联
        if (budget.categoryIds != null && budget.categoryIds!.isNotEmpty) {
          final batch = txn.batch();
          for (final categoryId in budget.categoryIds!) {
            batch.insert(
              categoryTable,
              {
                'budget_id': budget.id,
                'category_id': categoryId,
              },
            );
          }
          await batch.commit();
        }
      }

      return count;
    });
  }

  /// 删除预算
  Future<int> delete(int id) async {
    return await _provider.transaction((txn) async {
      // 删除分类关联
      await txn.delete(
        categoryTable,
        where: 'budget_id = ?',
        whereArgs: [id],
      );

      // 删除预算记录
      return await txn.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  /// 获取预算
  Future<Budget?> get(int id) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    // 获取分类ID列表
    final categoryMaps = await db.query(
      categoryTable,
      columns: ['category_id'],
      where: 'budget_id = ?',
      whereArgs: [id],
    );

    final categoryIds = categoryMaps.map((m) => m['category_id'] as int).toList();
    final map = maps.first;
    map['category_ids'] = categoryIds;

    return Budget.fromJson(map);
  }

  /// 获取所有预算
  Future<List<Budget>> getAll() async {
    final db = await _provider.database;
    final maps = await db.query(table);
    return _attachCategoryIds(maps);
  }

  /// 获取活跃预算
  Future<List<Budget>> getActive() async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return _attachCategoryIds(maps);
  }

  /// 获取分类的预算
  Future<List<Budget>> getByCategory(int categoryId) async {
    final db = await _provider.database;
    final budgetIds = await db.query(
      categoryTable,
      columns: ['budget_id'],
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );

    if (budgetIds.isEmpty) {
      return [];
    }

    final ids = budgetIds.map((m) => m['budget_id'] as int).toList();
    final maps = await db.query(
      table,
      where: 'id IN (${List.filled(ids.length, '?').join(', ')})',
      whereArgs: ids,
    );
    return _attachCategoryIds(maps);
  }

  /// 获取日期范围内的预算
  Future<List<Budget>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: '(start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?) OR (start_date <= ? AND end_date >= ?)',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
        start.toIso8601String(),
        end.toIso8601String(),
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );
    return _attachCategoryIds(maps);
  }

  /// 搜索预算
  Future<List<Budget>> search({
    String? keyword,
    List<BudgetType>? types,
    List<int>? categoryIds,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    bool? isActive,
  }) async {
    final db = await _provider.database;
    final conditions = <String>[];
    final arguments = <dynamic>[];

    if (keyword != null && keyword.isNotEmpty) {
      conditions.add('(name LIKE ? OR description LIKE ?)');
      arguments.addAll(['%$keyword%', '%$keyword%']);
    }

    if (types != null && types.isNotEmpty) {
      conditions.add('type IN (${List.filled(types.length, '?').join(', ')})');
      arguments.addAll(types.map((t) => t.index));
    }

    if (startDate != null) {
      conditions.add('start_date >= ?');
      arguments.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      conditions.add('end_date <= ?');
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

    if (isActive != null) {
      conditions.add('is_active = ?');
      arguments.add(isActive ? 1 : 0);
    }

    String query = 'SELECT DISTINCT b.* FROM $table b';
    
    if (categoryIds != null && categoryIds.isNotEmpty) {
      query += ' INNER JOIN $categoryTable bc ON b.id = bc.budget_id';
      conditions.add('bc.category_id IN (${List.filled(categoryIds.length, '?').join(', ')})');
      arguments.addAll(categoryIds);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY start_date DESC';

    final maps = await db.rawQuery(query, arguments);
    return _attachCategoryIds(maps);
  }

  /// 获取预算统计信息
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await _provider.database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_count,
        COUNT(CASE WHEN is_active = 1 THEN 1 END) as active_count,
        SUM(amount) as total_amount,
        AVG(amount) as average_amount,
        MIN(amount) as min_amount,
        MAX(amount) as max_amount,
        AVG(JULIANDAY(end_date) - JULIANDAY(start_date)) as average_duration
      FROM $table
    ''');
    return result.first;
  }

  /// 获取预算进度
  Future<Map<String, dynamic>> getProgress(int id) async {
    final db = await _provider.database;
    final budget = await get(id);
    if (budget == null) {
      return {};
    }

    String transactionQuery = '''
      SELECT 
        COUNT(t.id) as transaction_count,
        SUM(t.amount) as total_spent,
        MIN(t.date) as first_transaction,
        MAX(t.date) as last_transaction
      FROM transactions t
      WHERE t.date BETWEEN ? AND ?
    ''';

    final arguments = [budget.startDate.toIso8601String(), budget.endDate.toIso8601String()];

    if (budget.categoryIds != null && budget.categoryIds!.isNotEmpty) {
      transactionQuery += '''
        AND t.category_id IN (${List.filled(budget.categoryIds!.length, '?').join(', ')})
      ''';
      arguments.addAll(budget.categoryIds!);
    }

    final result = await db.rawQuery(transactionQuery, arguments);
    final stats = result.first;

    final totalSpent = (stats['total_spent'] as num?)?.toDouble() ?? 0.0;
    final progress = totalSpent / budget.amount;
    final transactionCount = stats['transaction_count'] as int? ?? 0;
    final firstTransaction = stats['first_transaction'] != null 
        ? DateTime.parse(stats['first_transaction'] as String)
        : null;
    final lastTransaction = stats['last_transaction'] != null
        ? DateTime.parse(stats['last_transaction'] as String)
        : null;

    final now = DateTime.now();
    final totalDays = budget.endDate.difference(budget.startDate).inDays;
    final elapsedDays = now.difference(budget.startDate).inDays;
    final timeProgress = elapsedDays / totalDays;

    return {
      'budget_id': id,
      'total_spent': totalSpent,
      'remaining': budget.amount - totalSpent,
      'progress': progress,
      'time_progress': timeProgress,
      'transaction_count': transactionCount,
      'first_transaction': firstTransaction?.toIso8601String(),
      'last_transaction': lastTransaction?.toIso8601String(),
      'is_over_budget': totalSpent > budget.amount,
      'days_remaining': budget.endDate.difference(now).inDays,
      'daily_average': transactionCount > 0 ? totalSpent / elapsedDays : 0.0,
      'projected_total': transactionCount > 0 ? (totalSpent / elapsedDays) * totalDays : 0.0,
    };
  }

  /// 批量更新预算状态
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

  /// 为预算列表附加分类ID
  Future<List<Budget>> _attachCategoryIds(List<Map<String, dynamic>> maps) async {
    if (maps.isEmpty) {
      return [];
    }

    final db = await _provider.database;
    final budgets = <Budget>[];

    for (final map in maps) {
      final budgetId = map['id'] as int;
      final categoryMaps = await db.query(
        categoryTable,
        columns: ['category_id'],
        where: 'budget_id = ?',
        whereArgs: [budgetId],
      );

      final categoryIds = categoryMaps.map((m) => m['category_id'] as int).toList();
      map['category_ids'] = categoryIds;
      budgets.add(Budget.fromJson(map));
    }

    return budgets;
  }
} 