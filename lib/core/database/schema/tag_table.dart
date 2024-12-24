import 'package:sqflite/sqflite.dart';
import '../table_definition.dart';

class TagTable {
  static const String tableName = 'tags';

  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnColor = 'color';
  static const String columnIcon = 'icon';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnStatus = 'status';
  static const String columnOrder = 'display_order';
  static const String columnCategory = 'category';
  static const String columnIsSystem = 'is_system';
  static const String columnMetadata = 'metadata';
  static const String columnUsageCount = 'usage_count';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnUserId TEXT NOT NULL,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT,
        $columnColor TEXT,
        $columnIcon TEXT,
        $columnCreatedAt INTEGER NOT NULL,
        $columnUpdatedAt INTEGER NOT NULL,
        $columnStatus TEXT NOT NULL DEFAULT 'active',
        $columnOrder INTEGER NOT NULL DEFAULT 0,
        $columnCategory TEXT,
        $columnIsSystem INTEGER NOT NULL DEFAULT 0,
        $columnMetadata TEXT,
        $columnUsageCount INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($columnUserId) REFERENCES ${TableDefinition.usersTable} (${TableDefinition.columnId}),
        CONSTRAINT status_check CHECK ($columnStatus IN ('active', 'inactive', 'archived')),
        UNIQUE ($columnUserId, $columnName)
      )
    ''');

    // 创建标签关联表
    await db.execute('''
      CREATE TABLE tag_relations (
        id TEXT PRIMARY KEY,
        tag_id TEXT NOT NULL,
        transaction_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (tag_id) REFERENCES $tableName (${TableDefinition.columnId}),
        FOREIGN KEY (transaction_id) REFERENCES ${TableDefinition.transactionsTable} (${TableDefinition.columnId}),
        UNIQUE (tag_id, transaction_id)
      )
    ''');

    // 创建索引
    await db.execute(
      'CREATE INDEX idx_${tableName}_user ON $tableName ($columnUserId)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_status ON $tableName ($columnStatus)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_order ON $tableName ($columnOrder)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_category ON $tableName ($columnCategory)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_usage ON $tableName ($columnUsageCount)',
    );

    // 创建标签关联表索引
    await db.execute(
      'CREATE INDEX idx_tag_relations_tag ON tag_relations (tag_id)',
    );
    await db.execute(
      'CREATE INDEX idx_tag_relations_transaction ON tag_relations (transaction_id)',
    );
  }

  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS tag_relations');
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