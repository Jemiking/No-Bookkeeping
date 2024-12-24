import 'package:sqflite/sqflite.dart';
import '../table_definition.dart';

class TransactionTable {
  static const String tableName = 'transactions';

  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnAccountId = 'account_id';
  static const String columnTargetAccountId = 'target_account_id';
  static const String columnCategoryId = 'category_id';
  static const String columnType = 'type';
  static const String columnAmount = 'amount';
  static const String columnCurrency = 'currency';
  static const String columnExchangeRate = 'exchange_rate';
  static const String columnDate = 'date';
  static const String columnDescription = 'description';
  static const String columnNotes = 'notes';
  static const String columnStatus = 'status';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnRecurringId = 'recurring_id';
  static const String columnInstallmentId = 'installment_id';
  static const String columnLocation = 'location';
  static const String columnAttachments = 'attachments';
  static const String columnMetadata = 'metadata';
  static const String columnIsReconciled = 'is_reconciled';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnUserId TEXT NOT NULL,
        $columnAccountId TEXT NOT NULL,
        $columnTargetAccountId TEXT,
        $columnCategoryId TEXT,
        $columnType TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnCurrency TEXT NOT NULL,
        $columnExchangeRate REAL,
        $columnDate INTEGER NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnNotes TEXT,
        $columnStatus TEXT NOT NULL DEFAULT 'completed',
        $columnCreatedAt INTEGER NOT NULL,
        $columnUpdatedAt INTEGER NOT NULL,
        $columnRecurringId TEXT,
        $columnInstallmentId TEXT,
        $columnLocation TEXT,
        $columnAttachments TEXT,
        $columnMetadata TEXT,
        $columnIsReconciled INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($columnUserId) REFERENCES ${TableDefinition.usersTable} (${TableDefinition.columnId}),
        FOREIGN KEY ($columnAccountId) REFERENCES ${TableDefinition.accountsTable} (${TableDefinition.columnId}),
        FOREIGN KEY ($columnTargetAccountId) REFERENCES ${TableDefinition.accountsTable} (${TableDefinition.columnId}),
        FOREIGN KEY ($columnCategoryId) REFERENCES ${TableDefinition.categoriesTable} (${TableDefinition.columnId}),
        CONSTRAINT type_check CHECK ($columnType IN ('income', 'expense', 'transfer')),
        CONSTRAINT status_check CHECK ($columnStatus IN ('pending', 'completed', 'cancelled', 'failed'))
      )
    ''');

    // 创建索引
    await db.execute(
      'CREATE INDEX idx_${tableName}_user ON $tableName ($columnUserId)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_account ON $tableName ($columnAccountId)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_category ON $tableName ($columnCategoryId)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_date ON $tableName ($columnDate)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_type ON $tableName ($columnType)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_status ON $tableName ($columnStatus)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_recurring ON $tableName ($columnRecurringId)',
    );
    await db.execute(
      'CREATE INDEX idx_${tableName}_installment ON $tableName ($columnInstallmentId)',
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