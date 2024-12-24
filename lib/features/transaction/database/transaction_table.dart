import 'package:sqflite/sqflite.dart';

class TransactionTable {
  static const String tableName = 'transactions';
  static const String templateTableName = 'transaction_templates';

  static Future<void> createTables(Database db) async {
    // 创建交易记录表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        type INTEGER NOT NULL,
        amount REAL NOT NULL,
        accountId TEXT NOT NULL,
        toAccountId TEXT,
        categoryId TEXT NOT NULL,
        tagIds TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        note TEXT NOT NULL,
        attachmentPath TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringRule TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts(id) ON DELETE CASCADE,
        FOREIGN KEY (toAccountId) REFERENCES accounts(id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // 创建交易记录模板表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $templateTableName (
        id TEXT PRIMARY KEY,
        type INTEGER NOT NULL,
        amount REAL NOT NULL,
        accountId TEXT NOT NULL,
        toAccountId TEXT,
        categoryId TEXT NOT NULL,
        tagIds TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        note TEXT NOT NULL,
        attachmentPath TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringRule TEXT,
        templateName TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts(id) ON DELETE CASCADE,
        FOREIGN KEY (toAccountId) REFERENCES accounts(id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_accountId ON $tableName(accountId)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_toAccountId ON $tableName(toAccountId)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_categoryId ON $tableName(categoryId)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_dateTime ON $tableName(dateTime)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_type ON $tableName(type)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_isRecurring ON $tableName(isRecurring)
    ''');
  }

  static Future<void> upgradeTables(Database db, int oldVersion, int newVersion) async {
    // 在这里处理数据库升级逻辑
    if (oldVersion < 2) {
      // 版本1升级到版本2的逻辑
    }
  }
} 