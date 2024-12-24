import 'package:sqflite/sqflite.dart';

abstract class TableDefinition {
  static const String usersTable = 'users';
  static const String accountsTable = 'accounts';
  static const String transactionsTable = 'transactions';
  static const String categoriesTable = 'categories';
  static const String tagsTable = 'tags';
  static const String tagRelationsTable = 'tag_relations';
  static const String budgetsTable = 'budgets';
  static const String attachmentsTable = 'attachments';
  static const String settingsTable = 'settings';

  // 通用列名
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnUserId = 'user_id';
  static const String columnStatus = 'status';
  static const String columnName = 'name';
  static const String columnDescription = 'description';

  // 数据类型定义
  static const String typeId = 'TEXT PRIMARY KEY';
  static const String typeText = 'TEXT';
  static const String typeInt = 'INTEGER';
  static const String typeReal = 'REAL';
  static const String typeBlob = 'BLOB';
  static const String typeBoolean = 'INTEGER';
  static const String typeTimestamp = 'INTEGER';

  // 约束定义
  static const String constraintNotNull = 'NOT NULL';
  static const String constraintUnique = 'UNIQUE';
  static const String constraintPrimaryKey = 'PRIMARY KEY';
  static const String constraintAutoIncrement = 'AUTOINCREMENT';
  static const String constraintDefault = 'DEFAULT';
  static const String constraintCheck = 'CHECK';
  static const String constraintForeignKey = 'FOREIGN KEY';
  static const String constraintReferences = 'REFERENCES';

  // 索引前缀
  static const String indexPrefix = 'idx_';

  // 创建表
  Future<void> createTable(Database db);

  // 删除表
  Future<void> dropTable(Database db);

  // 升级表
  Future<void> upgradeTable(Database db, int oldVersion, int newVersion);

  // 创建索引
  Future<void> createIndexes(Database db);

  // 验证表结构
  Future<bool> validateTable(Database db);
} 