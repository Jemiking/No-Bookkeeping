import 'package:sqflite/sqflite.dart';

class UpdateTransactionsTableMigration {
  static Future<void> up(Database db) async {
    // 创建临时表
    await db.execute('''
      CREATE TABLE transactions_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // 复制数据
    await db.execute('''
      INSERT INTO transactions_new (
        id, account_id, category_id, amount, type, date, note, created_at, updated_at
      )
      SELECT 
        id, 
        account_id, 
        category_id, 
        amount, 
        type, 
        date, 
        description as note, 
        created_at, 
        updated_at
      FROM transactions
    ''');

    // 删除旧表
    await db.execute('DROP TABLE transactions');

    // 重命名新���
    await db.execute('ALTER TABLE transactions_new RENAME TO transactions');

    // 创建索引
    await db.execute('CREATE INDEX idx_transactions_account_id ON transactions(account_id)');
    await db.execute('CREATE INDEX idx_transactions_category_id ON transactions(category_id)');
    await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
  }

  static Future<void> down(Database db) async {
    // 如果需要回滚，我们需要反向操作
    await db.execute('''
      CREATE TABLE transactions_old (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // 复制数据回去
    await db.execute('''
      INSERT INTO transactions_old (
        id, account_id, category_id, amount, type, date, description, created_at, updated_at
      )
      SELECT 
        id, 
        account_id, 
        category_id, 
        amount, 
        type, 
        date, 
        note as description, 
        created_at, 
        updated_at
      FROM transactions
    ''');

    // 删除新表
    await db.execute('DROP TABLE transactions');

    // 重命名回旧表
    await db.execute('ALTER TABLE transactions_old RENAME TO transactions');

    // 重新创建原来的索引
    await db.execute('CREATE INDEX idx_transactions_account_id ON transactions(account_id)');
    await db.execute('CREATE INDEX idx_transactions_category_id ON transactions(category_id)');
    await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
  }
} 