/// Database table definitions
class TableDefinitions {
  // Users table
  static const String usersTable = 'users';
  static const String createUsersTable = '''
    CREATE TABLE $usersTable (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE,
      avatar_url TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  // Accounts table
  static const String accountsTable = 'accounts';
  static const String createAccountsTable = '''
    CREATE TABLE $accountsTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      currency TEXT NOT NULL,
      initial_balance REAL NOT NULL,
      current_balance REAL NOT NULL,
      color TEXT,
      icon TEXT,
      description TEXT,
      is_archived INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE
    )
  ''';

  // Categories table
  static const String categoriesTable = 'categories';
  static const String createCategoriesTable = '''
    CREATE TABLE $categoriesTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      icon TEXT,
      color TEXT,
      parent_id TEXT,
      description TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE,
      FOREIGN KEY (parent_id) REFERENCES $categoriesTable (id) ON DELETE CASCADE
    )
  ''';

  // Tags table
  static const String tagsTable = 'tags';
  static const String createTagsTable = '''
    CREATE TABLE $tagsTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      color TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE
    )
  ''';

  // Transactions table
  static const String transactionsTable = 'transactions';
  static const String createTransactionsTable = '''
    CREATE TABLE $transactionsTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      account_id TEXT NOT NULL,
      category_id TEXT,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      date INTEGER NOT NULL,
      description TEXT,
      notes TEXT,
      location TEXT,
      is_reconciled INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE,
      FOREIGN KEY (account_id) REFERENCES $accountsTable (id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES $categoriesTable (id) ON DELETE SET NULL
    )
  ''';

  // Transaction Tags table (Many-to-Many relationship)
  static const String transactionTagsTable = 'transaction_tags';
  static const String createTransactionTagsTable = '''
    CREATE TABLE $transactionTagsTable (
      transaction_id TEXT NOT NULL,
      tag_id TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      PRIMARY KEY (transaction_id, tag_id),
      FOREIGN KEY (transaction_id) REFERENCES $transactionsTable (id) ON DELETE CASCADE,
      FOREIGN KEY (tag_id) REFERENCES $tagsTable (id) ON DELETE CASCADE
    )
  ''';

  // Budgets table
  static const String budgetsTable = 'budgets';
  static const String createBudgetsTable = '''
    CREATE TABLE $budgetsTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      category_id TEXT,
      name TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      period TEXT NOT NULL,
      start_date INTEGER NOT NULL,
      end_date INTEGER,
      color TEXT,
      notes TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES $categoriesTable (id) ON DELETE SET NULL
    )
  ''';

  // Recurring Transactions table
  static const String recurringTransactionsTable = 'recurring_transactions';
  static const String createRecurringTransactionsTable = '''
    CREATE TABLE $recurringTransactionsTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      account_id TEXT NOT NULL,
      category_id TEXT,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      frequency TEXT NOT NULL,
      start_date INTEGER NOT NULL,
      end_date INTEGER,
      description TEXT,
      notes TEXT,
      last_generated INTEGER,
      is_active INTEGER DEFAULT 1,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE,
      FOREIGN KEY (account_id) REFERENCES $accountsTable (id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES $categoriesTable (id) ON DELETE SET NULL
    )
  ''';

  // Settings table
  static const String settingsTable = 'settings';
  static const String createSettingsTable = '''
    CREATE TABLE $settingsTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      key TEXT NOT NULL,
      value TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE,
      UNIQUE(user_id, key)
    )
  ''';

  // List of all create table statements
  static final List<String> createTables = [
    createUsersTable,
    createAccountsTable,
    createCategoriesTable,
    createTagsTable,
    createTransactionsTable,
    createTransactionTagsTable,
    createBudgetsTable,
    createRecurringTransactionsTable,
    createSettingsTable,
  ];

  // List of all table names
  static final List<String> tableNames = [
    usersTable,
    accountsTable,
    categoriesTable,
    tagsTable,
    transactionsTable,
    transactionTagsTable,
    budgetsTable,
    recurringTransactionsTable,
    settingsTable,
  ];
} 