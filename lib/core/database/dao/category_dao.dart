import 'package:sqflite/sqflite.dart';
import '../database_provider.dart';
import '../models/category.dart';

/// 分类数据访问对象类
class CategoryDao {
  /// 数据库提供者
  final DatabaseProvider _provider;

  /// 表名
  static const String table = 'categories';

  /// 构造函数
  CategoryDao(this._provider);

  /// 插入分类
  Future<int> insert(Category category) async {
    final db = await _provider.database;
    return await db.insert(
      table,
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新分类
  Future<int> update(Category category) async {
    final db = await _provider.database;
    return await db.update(
      table,
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// 删除分类
  Future<int> delete(int id) async {
    final db = await _provider.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取分类
  Future<Category?> get(int id) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Category.fromJson(maps.first);
  }

  /// 获取所有分类
  Future<List<Category>> getAll() async {
    final db = await _provider.database;
    final maps = await db.query(table);
    return maps.map((map) => Category.fromJson(map)).toList();
  }

  /// 获取父分类的子分类
  Future<List<Category>> getChildren(int parentId) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );
    return maps.map((map) => Category.fromJson(map)).toList();
  }

  /// 获取根分类（没有父分类的分类）
  Future<List<Category>> getRootCategories() async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'parent_id IS NULL',
    );
    return maps.map((map) => Category.fromJson(map)).toList();
  }

  /// 获取分类树
  Future<List<Category>> getCategoryTree() async {
    final allCategories = await getAll();
    final rootCategories = allCategories.where((c) => c.parentId == null).toList();
    
    for (final root in rootCategories) {
      _buildCategoryTree(root, allCategories);
    }
    
    return rootCategories;
  }

  /// 递归构建分类树
  void _buildCategoryTree(Category parent, List<Category> allCategories) {
    final children = allCategories.where((c) => c.parentId == parent.id).toList();
    parent.children = children;
    
    for (final child in children) {
      _buildCategoryTree(child, allCategories);
    }
  }

  /// 搜索分类
  Future<List<Category>> search({
    String? keyword,
    List<CategoryType>? types,
    bool? isSystem,
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

    if (isSystem != null) {
      conditions.add('is_system = ?');
      arguments.add(isSystem ? 1 : 0);
    }

    if (isActive != null) {
      conditions.add('is_active = ?');
      arguments.add(isActive ? 1 : 0);
    }

    String query = 'SELECT * FROM $table';
    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }
    query += ' ORDER BY sort_order ASC, name ASC';

    final maps = await db.rawQuery(query, arguments);
    return maps.map((map) => Category.fromJson(map)).toList();
  }

  /// 获取分类统计信息
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await _provider.database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_count,
        COUNT(CASE WHEN parent_id IS NULL THEN 1 END) as root_count,
        COUNT(CASE WHEN parent_id IS NOT NULL THEN 1 END) as child_count,
        COUNT(CASE WHEN is_system = 1 THEN 1 END) as system_count,
        COUNT(CASE WHEN is_active = 1 THEN 1 END) as active_count,
        MAX(sort_order) as max_sort_order
      FROM $table
    ''');
    return result.first;
  }

  /// 更新分类排序
  Future<void> updateOrder(List<Map<String, dynamic>> updates) async {
    final db = await _provider.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final update in updates) {
        batch.update(
          table,
          {'sort_order': update['sort_order']},
          where: 'id = ?',
          whereArgs: [update['id']],
        );
      }
      await batch.commit();
    });
  }

  /// 批量更新分类状态
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

  /// 获取分类使用统计
  Future<List<Map<String, dynamic>>> getUsageStatistics() async {
    final db = await _provider.database;
    return await db.rawQuery('''
      SELECT 
        c.id,
        c.name,
        COUNT(t.id) as transaction_count,
        SUM(CASE WHEN t.type = 0 THEN t.amount ELSE 0 END) as total_income,
        SUM(CASE WHEN t.type = 1 THEN t.amount ELSE 0 END) as total_expense,
        AVG(t.amount) as average_amount,
        MAX(t.date) as last_used
      FROM $table c
      LEFT JOIN transactions t ON c.id = t.category_id
      GROUP BY c.id, c.name
      ORDER BY transaction_count DESC
    ''');
  }
} 