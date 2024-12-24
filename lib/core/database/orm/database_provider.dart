import 'package:sqflite/sqflite.dart';
import 'database_config.dart';

class DatabaseProvider {
  static Database? _database;

  // 私有构造函数
  DatabaseProvider._();

  // 单例实例
  static final DatabaseProvider instance = DatabaseProvider._();

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await DatabaseConfig.initDatabase();
    return _database!;
  }

  // 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // 清空数据库
  Future<void> clearDatabase() async {
    final db = await database;
    await DatabaseConfig.clearAllTables(db);
  }

  // 删除数据库
  Future<void> deleteDatabase() async {
    await close();
    await DatabaseConfig.deleteDatabase();
  }

  // 执行事务
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // 执行批处理
  Future<List<Object?>> batch(void Function(Batch batch) actions) async {
    final db = await database;
    final batch = db.batch();
    actions(batch);
    return await batch.commit();
  }

  // 执行原始SQL查询
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // 执行原始SQL更新
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  // 执行原始SQL删除
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }

  // 检查表是否存在
  Future<bool> isTableExists(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  // 获取表的所有列名
  Future<List<String>> getTableColumns(String tableName) async {
    final db = await database;
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.map((row) => row['name'] as String).toList();
  }

  // 获取数据库大小（字节）
  Future<int> getDatabaseSize() async {
    final db = await database;
    final result = await db.rawQuery('PRAGMA page_count, page_size');
    final pageCount = result.first['page_count'] as int;
    final pageSize = result.first['page_size'] as int;
    return pageCount * pageSize;
  }

  // 优化数据库
  Future<void> optimize() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  // 备份数据库
  Future<void> backup(String backupPath) async {
    final db = await database;
    await db.execute('VACUUM INTO ?', [backupPath]);
  }
} 