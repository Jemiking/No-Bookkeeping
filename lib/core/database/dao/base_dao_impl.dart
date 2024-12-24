import 'package:sqflite/sqflite.dart';
import 'base_dao.dart';

/// 基础DAO实现类
abstract class BaseDaoImpl<T> implements BaseDao<T> {
  final Database _db;
  
  BaseDaoImpl(this._db);

  @override
  Future<Database> get database async => _db;

  @override
  Future<String> insert(T entity) async {
    final db = await database;
    final id = await db.insert(
      tableName,
      toMap(entity),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id.toString();
  }

  @override
  Future<List<String>> insertAll(List<T> entities) async {
    final db = await database;
    final batch = db.batch();
    
    for (var entity in entities) {
      batch.insert(
        tableName,
        toMap(entity),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    final results = await batch.commit();
    return results.map((id) => id.toString()).toList();
  }

  @override
  Future<int> update(T entity) async {
    final db = await database;
    return await db.update(
      tableName,
      toMap(entity),
      where: 'id = ?',
      whereArgs: [getEntityId(entity)],
    );
  }

  @override
  Future<int> updateAll(List<T> entities) async {
    final db = await database;
    final batch = db.batch();
    
    for (var entity in entities) {
      batch.update(
        tableName,
        toMap(entity),
        where: 'id = ?',
        whereArgs: [getEntityId(entity)],
      );
    }
    
    final results = await batch.commit();
    return results.length;
  }

  @override
  Future<int> delete(String id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteAll(List<String> ids) async {
    final db = await database;
    final batch = db.batch();
    
    for (var id in ids) {
      batch.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    
    final results = await batch.commit();
    return results.length;
  }

  @override
  Future<T?> findById(String id) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  @override
  Future<List<T>> findAll() async {
    final db = await database;
    final maps = await db.query(tableName);
    return maps.map((map) => fromMap(map)).toList();
  }

  @override
  Future<List<T>> findWhere(String where, List whereArgs) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  @override
  Future<List<T>> findPage(int offset, int limit, {String? orderBy}) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  @override
  Future<int> count() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> countWhere(String where, List whereArgs) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE $where',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<bool> exists(String id) async {
    final count = await countWhere('id = ?', [id]);
    return count > 0;
  }

  @override
  Future<void> clear() async {
    final db = await database;
    await db.delete(tableName);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  @override
  Future<void> batch(void Function(Batch batch) actions) async {
    final db = await database;
    final batch = db.batch();
    actions(batch);
    await batch.commit();
  }

  @override
  bool validate(T entity) {
    // 默认实现，子类可以重写此方法添加具体的验证逻辑
    return true;
  }
} 