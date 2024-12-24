/// Database constants
class DatabaseConstants {
  // Database info
  static const String databaseName = 'money_tracker.db';
  static const int databaseVersion = 1;

  // Common column names
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnName = 'name';
  static const String columnType = 'type';
  static const String columnDescription = 'description';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Account types
  static const String accountTypeCash = 'cash';
  static const String accountTypeBank = 'bank';
  static const String accountTypeCredit = 'credit';
  static const String accountTypeInvestment = 'investment';
  static const String accountTypeSavings = 'savings';
  static const String accountTypeWallet = 'wallet';
  static const String accountTypeOther = 'other';

  // Transaction types
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeExpense = 'expense';
  static const String transactionTypeTransfer = 'transfer';

  // Category types
  static const String categoryTypeIncome = 'income';
  static const String categoryTypeExpense = 'expense';

  // Budget periods
  static const String budgetPeriodDaily = 'daily';
  static const String budgetPeriodWeekly = 'weekly';
  static const String budgetPeriodMonthly = 'monthly';
  static const String budgetPeriodQuarterly = 'quarterly';
  static const String budgetPeriodYearly = 'yearly';
  static const String budgetPeriodCustom = 'custom';

  // Recurring transaction frequencies
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyMonthly = 'monthly';
  static const String frequencyQuarterly = 'quarterly';
  static const String frequencyYearly = 'yearly';
  static const String frequencyCustom = 'custom';

  // Default values
  static const String defaultCurrency = 'CNY';
  static const String defaultLocale = 'zh_CN';
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm:ss';

  // Error messages
  static const String errorDatabaseNotInitialized = 'Database not initialized';
  static const String errorInvalidData = 'Invalid data provided';
  static const String errorRecordNotFound = 'Record not found';
  static const String errorDuplicateRecord = 'Record already exists';
  static const String errorForeignKeyViolation = 'Foreign key violation';
  static const String errorUnknown = 'Unknown error occurred';

  // Query limits
  static const int defaultLimit = 50;
  static const int maxLimit = 1000;

  // Cache settings
  static const Duration cacheTimeout = Duration(minutes: 30);
  static const int maxCacheSize = 1000;

  // Batch operation settings
  static const int batchSize = 100;
  static const Duration batchTimeout = Duration(seconds: 30);

  // Index names
  static const String indexTransactionDate = 'idx_transaction_date';
  static const String indexAccountBalance = 'idx_account_balance';
  static const String indexCategoryParent = 'idx_category_parent';
  static const String indexBudgetPeriod = 'idx_budget_period';
  static const String indexRecurringFrequency = 'idx_recurring_frequency';

  // View names
  static const String viewMonthlyBalance = 'view_monthly_balance';
  static const String viewCategoryStats = 'view_category_stats';
  static const String viewBudgetProgress = 'view_budget_progress';
  static const String viewRecurringStatus = 'view_recurring_status';
} 