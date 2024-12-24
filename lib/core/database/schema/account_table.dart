import 'package:sqflite/sqflite.dart';
import '../table_definition.dart';

class AccountTable {
  static const String tableName = 'accounts';

  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnName = 'name';
  static const String columnType = 'type';
  static const String columnCurrency = 'currency';
  static const String columnBalance = 'balance';
  static const String columnInitialBalance = 'initial_balance';
  static const String columnDescription = 'description';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnStatus = 'status';
  static const String columnGroup = 'group';
  static const String columnOrder = 'display_order';
  static const String columnIcon = 'icon';
  static const String columnColor = 'color';
  static const String columnExcludeFromStats = 'exclude_from_stats';
  static const String columnArchived = 'is_archived';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnUserId TEXT NOT NULL,
        $columnName TEXT NOT NULL,
        $columnType TEXT NOT NULL,
        $columnCurrency TEXT NOT NULL,
        $columnBalance REAL NOT NULL DEFAULT 0.0,
        $columnInitialBalance REAL NOT NULL DEFAULT 0.0,
        $columnDescription TEXT,
        $columnCreatedAt INTEGER NOT NULL,
        $columnUpdatedAt INTEGER NOT NULL,
        $columnStatus TEXT NOT NULL DEFAULT 'active',
        $columnGroup TEXT,
        $columnOrder INTEGER NOT NULL DEFAULT 0,
        $columnIcon TEXT,
        $columnColor TEXT,
        $columnExcludeFromStats INTEGER NOT NULL DEFAULT 0,
        $columnArchived INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($columnUserId) REFERENCES ${TableDefinition.usersTable} (${TableDefinition.columnId}),
        CONSTRAINT type_check CHECK ($columnType IN ('cash', 'bank', 'credit', 'investment', 'other')),
        CONSTRAINT status_check CHECK ($columnStatus IN ('active', 'inactive', 'frozen'))
      )
    ''');

    // 创建索引
    await db.execute(
      'CREATE INDEX idx_${tableName}_user ON $tableName ($columnUserId)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_type ON $tableName ($columnType)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_status ON $tableName ($columnStatus)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_group ON $tableName ($columnGroup)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_archived ON $tableName ($columnArchived)',
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