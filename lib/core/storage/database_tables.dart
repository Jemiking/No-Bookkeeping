/// 数据库表定义
class DatabaseTables {
  static const String accounts = 'accounts';
  static const String categories = 'categories';
  static const String transactions = 'transactions';
  static const String budgets = 'budgets';
  static const String migrations = 'migrations';
  static const String backups = 'backups';

  /// 基础列定义
  static const String _baseColumns = '''
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    deleted_at INTEGER,
    version INTEGER NOT NULL DEFAULT 1
  ''';

  /// 创建表的 SQL 语句
  static final Map<String, String> createTableSql = {
    accounts: '''
      CREATE TABLE $accounts (
        $_baseColumns,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'CNY',
        description TEXT,
        type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        last_sync_at INTEGER
      )
    ''',
    
    categories: '''
      CREATE TABLE $categories (
        $_baseColumns,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        parent_id INTEGER,
        icon TEXT,
        color TEXT,
        description TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        FOREIGN KEY (parent_id) REFERENCES $categories (id) ON DELETE SET NULL
      )
    ''',
    
    transactions: '''
      CREATE TABLE $transactions (
        $_baseColumns,
        account_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        note TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        sync_status TEXT,
        last_synced_at INTEGER,
        metadata TEXT,
        FOREIGN KEY (account_id) REFERENCES $accounts (id) ON DELETE RESTRICT,
        FOREIGN KEY (category_id) REFERENCES $categories (id) ON DELETE RESTRICT
      )
    ''',
    
    budgets: '''
      CREATE TABLE $budgets (
        $_baseColumns,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        category_id INTEGER,
        status TEXT NOT NULL DEFAULT 'active',
        notification_enabled BOOLEAN NOT NULL DEFAULT 0,
        notification_threshold REAL,
        FOREIGN KEY (category_id) REFERENCES $categories (id) ON DELETE SET NULL
      )
    ''',

    migrations: '''
      CREATE TABLE $migrations (
        $_baseColumns,
        version INTEGER NOT NULL,
        name TEXT NOT NULL,
        batch INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        error TEXT,
        executed_at INTEGER
      )
    ''',

    backups: '''
      CREATE TABLE $backups (
        $_baseColumns,
        filename TEXT NOT NULL,
        size INTEGER NOT NULL,
        hash TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        error TEXT,
        completed_at INTEGER
      )
    '''
  };

  /// 创建索引的 SQL 语句
  static final List<String> createIndexSql = [
    // 账户索引
    'CREATE INDEX idx_accounts_status ON $accounts(status) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_accounts_type ON $accounts(type) WHERE deleted_at IS NULL',
    
    // 分类索引
    'CREATE INDEX idx_categories_parent_id ON $categories(parent_id) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_categories_type ON $categories(type) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_categories_status ON $categories(status) WHERE deleted_at IS NULL',
    
    // 交易索引
    'CREATE INDEX idx_transactions_account_id ON $transactions(account_id) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_transactions_category_id ON $transactions(category_id) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_transactions_type ON $transactions(type) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_transactions_date ON $transactions(date) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_transactions_status ON $transactions(status) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_transactions_sync_status ON $transactions(sync_status) WHERE deleted_at IS NULL',
    
    // 预算索引
    'CREATE INDEX idx_budgets_category_id ON $budgets(category_id) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_budgets_period ON $budgets(period) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_budgets_status ON $budgets(status) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_budgets_dates ON $budgets(start_date, end_date) WHERE deleted_at IS NULL',
    
    // 迁移索引
    'CREATE INDEX idx_migrations_version ON $migrations(version)',
    'CREATE INDEX idx_migrations_batch ON $migrations(batch)',
    'CREATE INDEX idx_migrations_status ON $migrations(status)',
    
    // 备份索引
    'CREATE INDEX idx_backups_status ON $backups(status)',
    'CREATE INDEX idx_backups_completed_at ON $backups(completed_at)',
  ];

  /// 创建触发器的 SQL 语句
  static final List<String> createTriggerSql = [
    // 更新时间戳触发器
    '''
    CREATE TRIGGER update_timestamp_accounts
    AFTER UPDATE ON $accounts
    BEGIN
      UPDATE $accounts SET updated_at = strftime('%s', 'now')
      WHERE id = NEW.id;
    END
    ''',
    
    '''
    CREATE TRIGGER update_timestamp_categories
    AFTER UPDATE ON $categories
    BEGIN
      UPDATE $categories SET updated_at = strftime('%s', 'now')
      WHERE id = NEW.id;
    END
    ''',
    
    '''
    CREATE TRIGGER update_timestamp_transactions
    AFTER UPDATE ON $transactions
    BEGIN
      UPDATE $transactions SET updated_at = strftime('%s', 'now')
      WHERE id = NEW.id;
    END
    ''',
    
    '''
    CREATE TRIGGER update_timestamp_budgets
    AFTER UPDATE ON $budgets
    BEGIN
      UPDATE $budgets SET updated_at = strftime('%s', 'now')
      WHERE id = NEW.id;
    END
    ''',

    // 账户余额更新触发器
    '''
    CREATE TRIGGER update_account_balance_insert
    AFTER INSERT ON $transactions
    WHEN NEW.deleted_at IS NULL
    BEGIN
      UPDATE $accounts
      SET balance = balance + CASE
        WHEN NEW.type = 'income' THEN NEW.amount
        WHEN NEW.type = 'expense' THEN -NEW.amount
        ELSE 0
      END
      WHERE id = NEW.account_id;
    END
    ''',

    '''
    CREATE TRIGGER update_account_balance_update
    AFTER UPDATE ON $transactions
    WHEN NEW.deleted_at IS NULL AND OLD.deleted_at IS NULL
    BEGIN
      UPDATE $accounts
      SET balance = balance - CASE
        WHEN OLD.type = 'income' THEN OLD.amount
        WHEN OLD.type = 'expense' THEN -OLD.amount
        ELSE 0
      END + CASE
        WHEN NEW.type = 'income' THEN NEW.amount
        WHEN NEW.type = 'expense' THEN -NEW.amount
        ELSE 0
      END
      WHERE id = NEW.account_id;
    END
    ''',

    '''
    CREATE TRIGGER update_account_balance_delete
    AFTER UPDATE ON $transactions
    WHEN NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL
    BEGIN
      UPDATE $accounts
      SET balance = balance - CASE
        WHEN OLD.type = 'income' THEN OLD.amount
        WHEN OLD.type = 'expense' THEN -OLD.amount
        ELSE 0
      END
      WHERE id = OLD.account_id;
    END
    '''
  ];

  /// 数据库升级 SQL 语句
  static Map<int, List<String>> upgradeScripts = {
    2: [
      // 版本 2 的升级脚本
      'ALTER TABLE $transactions ADD COLUMN sync_status TEXT',
      'ALTER TABLE $transactions ADD COLUMN last_synced_at INTEGER',
      'CREATE INDEX idx_transactions_sync_status ON $transactions(sync_status) WHERE deleted_at IS NULL',
    ],
    // 可以添加更多版本的升级脚本
  };

  /// 获取视图创建 SQL 语句
  static List<String> getViewCreationSql() {
    return [
      // 活跃账户视图
      '''
      CREATE VIEW active_accounts AS
      SELECT * FROM $accounts
      WHERE deleted_at IS NULL AND status = 'active'
      ''',

      // 活跃分类视图
      '''
      CREATE VIEW active_categories AS
      SELECT * FROM $categories
      WHERE deleted_at IS NULL AND status = 'active'
      ''',

      // 月度交易统计视图
      '''
      CREATE VIEW monthly_transactions AS
      SELECT 
        strftime('%Y-%m', datetime(date, 'unixepoch')) as month,
        type,
        category_id,
        COUNT(*) as transaction_count,
        SUM(amount) as total_amount
      FROM $transactions
      WHERE deleted_at IS NULL
      GROUP BY month, type, category_id
      ''',

      // 预算执行情况视图
      '''
      CREATE VIEW budget_execution AS
      SELECT
        b.id as budget_id,
        b.name as budget_name,
        b.amount as budget_amount,
        COALESCE(SUM(t.amount), 0) as spent_amount,
        b.amount - COALESCE(SUM(t.amount), 0) as remaining_amount,
        CASE
          WHEN b.amount > 0 THEN ROUND(COALESCE(SUM(t.amount), 0) * 100.0 / b.amount, 2)
          ELSE 0
        END as execution_percentage
      FROM $budgets b
      LEFT JOIN $transactions t ON 
        t.category_id = b.category_id AND
        t.date >= b.start_date AND
        (b.end_date IS NULL OR t.date <= b.end_date) AND
        t.deleted_at IS NULL AND
        t.type = 'expense'
      WHERE b.deleted_at IS NULL
      GROUP BY b.id
      '''
    ];
  }
} 