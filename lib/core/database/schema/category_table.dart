import 'package:sqflite/sqflite.dart';
import '../table_definition.dart';

class CategoryTable {
  static const String tableName = 'categories';

  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnParentId = 'parent_id';
  static const String columnName = 'name';
  static const String columnType = 'type';
  static const String columnDescription = 'description';
  static const String columnIcon = 'icon';
  static const String columnColor = 'color';
  static const String columnBudget = 'budget';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnStatus = 'status';
  static const String columnOrder = 'display_order';
  static const String columnIsDefault = 'is_default';
  static const String columnIsSystem = 'is_system';
  static const String columnRules = 'rules';
  static const String columnMetadata = 'metadata';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnUserId TEXT NOT NULL,
        $columnParentId TEXT,
        $columnName TEXT NOT NULL,
        $columnType TEXT NOT NULL,
        $columnDescription TEXT,
        $columnIcon TEXT,
        $columnColor TEXT,
        $columnBudget REAL,
        $columnCreatedAt INTEGER NOT NULL,
        $columnUpdatedAt INTEGER NOT NULL,
        $columnStatus TEXT NOT NULL DEFAULT 'active',
        $columnOrder INTEGER NOT NULL DEFAULT 0,
        $columnIsDefault INTEGER NOT NULL DEFAULT 0,
        $columnIsSystem INTEGER NOT NULL DEFAULT 0,
        $columnRules TEXT,
        $columnMetadata TEXT,
        FOREIGN KEY ($columnUserId) REFERENCES ${TableDefinition.usersTable} (${TableDefinition.columnId}),
        FOREIGN KEY ($columnParentId) REFERENCES $tableName (${TableDefinition.columnId}),
        CONSTRAINT type_check CHECK ($columnType IN ('income', 'expense', 'transfer', 'system')),
        CONSTRAINT status_check CHECK ($columnStatus IN ('active', 'inactive', 'archived'))
      )
    ''');

    // 创建索引
    await db.execute(
      'CREATE INDEX idx_${tableName}_user ON $tableName ($columnUserId)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_parent ON $tableName ($columnParentId)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_type ON $tableName ($columnType)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_status ON $tableName ($columnStatus)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_order ON $tableName ($columnOrder)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_default ON $tableName ($columnIsDefault)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_system ON $tableName ($columnIsSystem)',
    );
  }

  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  static Future<void> upgradeTable(Database db, int oldVersion, int newVersion) async {
    // 版本升级逻辑
    if (oldVersion < 2) {
      // 添加新列示例
      await db.execute('''
        ALTER TABLE $tableName 
        ADD COLUMN new_column TEXT;
      ''');
    }
  }
} 