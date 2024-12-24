import 'package:sqflite/sqflite.dart';
import '../table_definition.dart';

class UserTable {
  static const String tableName = 'users';

  static const String columnId = 'id';
  static const String columnUsername = 'username';
  static const String columnEmail = 'email';
  static const String columnPasswordHash = 'password_hash';
  static const String columnSalt = 'salt';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnLastLoginAt = 'last_login_at';
  static const String columnStatus = 'status';
  static const String columnSettings = 'settings';
  static const String columnPreferences = 'preferences';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnUsername TEXT NOT NULL UNIQUE,
        $columnEmail TEXT NOT NULL UNIQUE,
        $columnPasswordHash TEXT NOT NULL,
        $columnSalt TEXT NOT NULL,
        $columnCreatedAt INTEGER NOT NULL,
        $columnUpdatedAt INTEGER NOT NULL,
        $columnLastLoginAt INTEGER,
        $columnStatus TEXT NOT NULL DEFAULT 'active',
        $columnSettings TEXT,
        $columnPreferences TEXT,
        CONSTRAINT status_check CHECK ($columnStatus IN ('active', 'inactive', 'suspended'))
      )
    ''');

    // 创建索引
    await db.execute(
      'CREATE INDEX idx_${tableName}_email ON $tableName ($columnEmail)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_username ON $tableName ($columnUsername)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_status ON $tableName ($columnStatus)',
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