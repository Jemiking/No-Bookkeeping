class BalanceAdjustmentsTable {
  static const String tableName = 'balance_adjustments';

  static const String createTable = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      account_id TEXT NOT NULL,
      amount REAL NOT NULL,
      reason TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at INTEGER NOT NULL,
      applied_at INTEGER,
      created_by TEXT NOT NULL,
      approved_by TEXT,
      notes TEXT,
      FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
      FOREIGN KEY (created_by) REFERENCES users(id),
      FOREIGN KEY (approved_by) REFERENCES users(id)
    )
  ''';

  static const String createIndexAccountId = '''
    CREATE INDEX idx_${tableName}_account_id ON $tableName(account_id)
  ''';

  static const String createIndexStatus = '''
    CREATE INDEX idx_${tableName}_status ON $tableName(status)
  ''';
} 