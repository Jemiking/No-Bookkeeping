import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_constants.dart';
import 'table_definitions.dart';

/// Database helper class for managing SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;
  bool _isInitializing = false;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_isInitializing) {
      // Wait for initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_database != null) return _database!;
    }
    return await _initDatabase();
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    _isInitializing = true;
    try {
      final String path = await _getDatabasePath();
      _database = await openDatabase(
        path,
        version: DatabaseConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
      );
      return _database!;
    } finally {
      _isInitializing = false;
    }
  }

  /// Get database file path
  Future<String> _getDatabasePath() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, DatabaseConstants.databaseName);
    return path;
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      for (String createTable in TableDefinitions.createTables) {
        await txn.execute(createTable);
      }
      await _createIndices(txn);
      await _createViews(txn);
      await _insertDefaultData(txn);
    });
  }

  /// Create database indices
  Future<void> _createIndices(Transaction txn) async {
    // Transaction date index
    await txn.execute('''
      CREATE INDEX ${DatabaseConstants.indexTransactionDate}
      ON ${TableDefinitions.transactionsTable} (date)
    ''');

    // Account balance index
    await txn.execute('''
      CREATE INDEX ${DatabaseConstants.indexAccountBalance}
      ON ${TableDefinitions.accountsTable} (current_balance)
    ''');

    // Category parent index
    await txn.execute('''
      CREATE INDEX ${DatabaseConstants.indexCategoryParent}
      ON ${TableDefinitions.categoriesTable} (parent_id)
    ''');

    // Budget period index
    await txn.execute('''
      CREATE INDEX ${DatabaseConstants.indexBudgetPeriod}
      ON ${TableDefinitions.budgetsTable} (period, start_date, end_date)
    ''');

    // Recurring transaction frequency index
    await txn.execute('''
      CREATE INDEX ${DatabaseConstants.indexRecurringFrequency}
      ON ${TableDefinitions.recurringTransactionsTable} (frequency, start_date, end_date)
    ''');
  }

  /// Create database views
  Future<void> _createViews(Transaction txn) async {
    // Monthly balance view
    await txn.execute('''
      CREATE VIEW IF NOT EXISTS ${DatabaseConstants.viewMonthlyBalance} AS
      SELECT 
        strftime('%Y-%m', datetime(date/1000, 'unixepoch')) as month,
        account_id,
        SUM(CASE WHEN type = '${DatabaseConstants.transactionTypeIncome}' THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN type = '${DatabaseConstants.transactionTypeExpense}' THEN amount ELSE 0 END) as total_expense
      FROM ${TableDefinitions.transactionsTable}
      GROUP BY month, account_id
    ''');

    // Category statistics view
    await txn.execute('''
      CREATE VIEW IF NOT EXISTS ${DatabaseConstants.viewCategoryStats} AS
      SELECT 
        category_id,
        type,
        COUNT(*) as transaction_count,
        SUM(amount) as total_amount,
        AVG(amount) as average_amount
      FROM ${TableDefinitions.transactionsTable}
      WHERE category_id IS NOT NULL
      GROUP BY category_id, type
    ''');

    // Budget progress view
    await txn.execute('''
      CREATE VIEW IF NOT EXISTS ${DatabaseConstants.viewBudgetProgress} AS
      SELECT 
        b.id as budget_id,
        b.amount as budget_amount,
        COALESCE(SUM(t.amount), 0) as spent_amount,
        (b.amount - COALESCE(SUM(t.amount), 0)) as remaining_amount,
        CASE 
          WHEN b.amount > 0 THEN ROUND(COALESCE(SUM(t.amount), 0) * 100.0 / b.amount, 2)
          ELSE 0 
        END as progress_percentage
      FROM ${TableDefinitions.budgetsTable} b
      LEFT JOIN ${TableDefinitions.transactionsTable} t 
        ON b.category_id = t.category_id 
        AND t.date >= b.start_date 
        AND (b.end_date IS NULL OR t.date <= b.end_date)
      GROUP BY b.id
    ''');
  }

  /// Insert default data
  Future<void> _insertDefaultData(Transaction txn) async {
    // TODO: Insert default categories, tags, etc.
  }

  /// Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // TODO: Implement database upgrade logic
  }

  /// Downgrade database
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // TODO: Implement database downgrade logic
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete database
  Future<void> deleteDatabase() async {
    final String path = await _getDatabasePath();
    await close();
    await databaseFactory.deleteDatabase(path);
  }

  /// Check if database exists
  Future<bool> databaseExists() async {
    final String path = await _getDatabasePath();
    return await databaseFactory.databaseExists(path);
  }

  /// Get database version
  Future<int> getDatabaseVersion() async {
    final Database db = await database;
    return await db.getVersion();
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    return await _getDatabasePath();
  }
} 