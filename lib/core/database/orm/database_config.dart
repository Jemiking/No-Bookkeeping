import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../schema/user_table.dart';
import '../schema/account_table.dart';
import '../schema/transaction_table.dart';
import '../schema/category_table.dart';
import '../schema/tag_table.dart';

class DatabaseConfig {
  static const String databaseName = 'money_tracker.db';
  static const int databaseVersion = 1;

  static Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 创建表
    await UserTable.createTable(db);
    await AccountTable.createTable(db);
    await TransactionTable.createTable(db);
    await CategoryTable.createTable(db);
    await TagTable.createTable(db);

    // 初始化基础数据
    await _initializeBaseData(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
    if (oldVersion < 2) {
      // 版本1升级到版本2的操作
      await UserTable.upgradeTable(db, oldVersion, newVersion);
      await AccountTable.upgradeTable(db, oldVersion, newVersion);
      await TransactionTable.upgradeTable(db, oldVersion, newVersion);
      await CategoryTable.upgradeTable(db, oldVersion, newVersion);
      await TagTable.upgradeTable(db, oldVersion, newVersion);
    }
  }

  static Future<void> _onConfigure(Database db) async {
    // 配置数据库
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _initializeBaseData(Database db) async {
    // 初始化系统默认分类
    await db.insert('categories', {
      'id': 'income_salary',
      'name': '工资收入',
      'type': 'income',
      'is_system': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    await db.insert('categories', {
      'id': 'expense_food',
      'name': '餐饮支出',
      'type': 'expense',
      'is_system': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    // 初始化系统默认标签
    await db.insert('tags', {
      'id': 'important',
      'name': '重要',
      'is_system': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    await databaseFactory.deleteDatabase(path);
  }

  static Future<void> clearAllTables(Database db) async {
    await db.transaction((txn) async {
      // 禁用外键约束
      await txn.execute('PRAGMA foreign_keys = OFF');

      // 清空所有表
      await txn.execute('DELETE FROM tag_relations');
      await txn.execute('DELETE FROM tags');
      await txn.execute('DELETE FROM transactions');
      await txn.execute('DELETE FROM categories');
      await txn.execute('DELETE FROM accounts');
      await txn.execute('DELETE FROM users');

      // 重置自增ID
      await txn.execute('DELETE FROM sqlite_sequence');

      // 启用外键约束
      await txn.execute('PRAGMA foreign_keys = ON');
    });
  }
} 