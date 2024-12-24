import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database/tag_table.dart';
import '../models/tag.dart';
import 'tag_service.dart';

class TagServiceImpl implements TagService {
  final Database _db;
  final Uuid _uuid = const Uuid();

  TagServiceImpl(this._db);

  @override
  Future<String> createTag(Tag tag) async {
    final String id = _uuid.v4();
    final now = DateTime.now();
    
    final data = tag.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    ).toJson();
    
    await _db.insert(TagTable.tableName, data);
    return id;
  }

  @override
  Future<Tag> getTag(String id) async {
    final List<Map<String, dynamic>> results = await _db.query(
      TagTable.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isEmpty) {
      throw Exception('Tag not found');
    }
    
    return Tag.fromJson(results.first);
  }

  @override
  Future<List<Tag>> getTags({String? searchQuery}) async {
    String? whereClause;
    List<dynamic>? whereArgs;
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause = 'name LIKE ? OR description LIKE ?';
      whereArgs = ['%$searchQuery%', '%$searchQuery%'];
    }
    
    final List<Map<String, dynamic>> results = await _db.query(
      TagTable.tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );
    
    return results.map((data) => Tag.fromJson(data)).toList();
  }

  @override
  Future<void> updateTag(Tag tag) async {
    final now = DateTime.now();
    final data = tag.copyWith(updatedAt: now).toJson();
    
    final count = await _db.update(
      TagTable.tableName,
      data,
      where: 'id = ?',
      whereArgs: [tag.id],
    );
    
    if (count == 0) {
      throw Exception('Tag not found');
    }
  }

  @override
  Future<void> deleteTag(String id) async {
    // 检查是否是系统标签
    final tag = await getTag(id);
    if (tag.isSystem) {
      throw Exception('Cannot delete system tag');
    }
    
    final count = await _db.delete(
      TagTable.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (count == 0) {
      throw Exception('Tag not found');
    }
  }

  @override
  Future<void> batchCreateTags(List<Tag> tags) async {
    await _db.transaction((txn) async {
      for (final tag in tags) {
        final String id = _uuid.v4();
        final now = DateTime.now();
        final data = tag.copyWith(
          id: id,
          createdAt: now,
          updatedAt: now,
        ).toJson();
        await txn.insert(TagTable.tableName, data);
      }
    });
  }

  @override
  Future<void> batchUpdateTags(List<Tag> tags) async {
    await _db.transaction((txn) async {
      for (final tag in tags) {
        final now = DateTime.now();
        final data = tag.copyWith(updatedAt: now).toJson();
        await txn.update(
          TagTable.tableName,
          data,
          where: 'id = ?',
          whereArgs: [tag.id],
        );
      }
    });
  }

  @override
  Future<void> batchDeleteTags(List<String> ids) async {
    await _db.transaction((txn) async {
      // 检查是否包含系统标签
      final tags = await Future.wait(ids.map((id) => getTag(id)));
      if (tags.any((tag) => tag.isSystem)) {
        throw Exception('Cannot delete system tags');
      }
      
      for (final id in ids) {
        await txn.delete(
          TagTable.tableName,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  @override
  Future<void> addTagsToTransaction(String transactionId, List<String> tagIds) async {
    await _db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      
      // 先删除现有的关联
      await txn.delete(
        TagTable.transactionTagsTable,
        where: 'transactionId = ?',
        whereArgs: [transactionId],
      );
      
      // 添加新的关联
      for (final tagId in tagIds) {
        await txn.insert(TagTable.transactionTagsTable, {
          'transactionId': transactionId,
          'tagId': tagId,
          'createdAt': now,
        });
      }
    });
  }

  @override
  Future<void> removeTagsFromTransaction(String transactionId, List<String> tagIds) async {
    await _db.delete(
      TagTable.transactionTagsTable,
      where: 'transactionId = ? AND tagId IN (${tagIds.map((_) => '?').join(', ')})',
      whereArgs: [transactionId, ...tagIds],
    );
  }

  @override
  Future<List<Tag>> getTagsByTransaction(String transactionId) async {
    final List<Map<String, dynamic>> results = await _db.rawQuery('''
      SELECT t.*
      FROM ${TagTable.tableName} t
      INNER JOIN ${TagTable.transactionTagsTable} tt ON t.id = tt.tagId
      WHERE tt.transactionId = ?
      ORDER BY t.name ASC
    ''', [transactionId]);
    
    return results.map((data) => Tag.fromJson(data)).toList();
  }

  @override
  Future<List<String>> getTransactionsByTag(String tagId) async {
    final List<Map<String, dynamic>> results = await _db.query(
      TagTable.transactionTagsTable,
      columns: ['transactionId'],
      where: 'tagId = ?',
      whereArgs: [tagId],
    );
    
    return results.map((data) => data['transactionId'] as String).toList();
  }

  @override
  Future<Map<String, int>> getTagUsageCount() async {
    final List<Map<String, dynamic>> results = await _db.rawQuery('''
      SELECT tagId, COUNT(*) as count
      FROM ${TagTable.transactionTagsTable}
      GROUP BY tagId
    ''');
    
    final Map<String, int> usageCount = {};
    for (final row in results) {
      usageCount[row['tagId'] as String] = row['count'] as int;
    }
    
    return usageCount;
  }

  @override
  Future<Map<String, double>> getTagTotalAmount({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (startDate != null) {
      whereClause += ' AND t.dateTime >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND t.dateTime <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    final List<Map<String, dynamic>> results = await _db.rawQuery('''
      SELECT tt.tagId, SUM(t.amount) as total
      FROM transactions t
      INNER JOIN ${TagTable.transactionTagsTable} tt ON t.id = tt.transactionId
      WHERE $whereClause
      GROUP BY tt.tagId
    ''', whereArgs);
    
    final Map<String, double> tagTotals = {};
    for (final row in results) {
      tagTotals[row['tagId'] as String] = row['total'] as double;
    }
    
    return tagTotals;
  }

  @override
  Future<List<Tag>> getSystemTags() async {
    final List<Map<String, dynamic>> results = await _db.query(
      TagTable.tableName,
      where: 'isSystem = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    
    return results.map((data) => Tag.fromJson(data)).toList();
  }

  @override
  Future<void> initializeSystemTags() async {
    await _db.transaction((txn) async {
      final now = DateTime.now();
      
      for (final tagData in TagTable.systemTags) {
        final String id = _uuid.v4();
        final data = {
          ...tagData,
          'id': id,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };
        
        // 检查是否已存在同名的系统标签
        final List<Map<String, dynamic>> existing = await txn.query(
          TagTable.tableName,
          where: 'name = ? AND isSystem = ?',
          whereArgs: [tagData['name'], 1],
        );
        
        if (existing.isEmpty) {
          await txn.insert(TagTable.tableName, data);
        }
      }
    });
  }
} 