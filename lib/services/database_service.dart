import '../models/database_models.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/storage/storage_factory.dart';
import '../core/storage/storage_interface.dart';

class DatabaseService {
  late final StorageInterface _storage;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _storage = StorageFactory.createStorage();
      await _storage.initialize();
      _isInitialized = true;
    } catch (e) {
      throw AppDatabaseException(
        'Failed to initialize database service',
        details: e,
      );
    }
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw AppDatabaseException('Database service is not initialized');
    }
  }

  // Account 操作
  Future<List<AccountEntity>> getAllAccounts() async {
    _checkInitialized();
    final result = await _storage.query('accounts');
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to get accounts',
        details: result.error,
      );
    }
    return result.data!.map((map) => AccountEntity.fromMap(map)).toList();
  }

  Future<AccountEntity?> getAccount(int id) async {
    _checkInitialized();
    final result = await _storage.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to get account',
        details: result.error,
      );
    }
    if (result.data!.isEmpty) return null;
    return AccountEntity.fromMap(result.data!.first);
  }

  Future<void> insertAccount(AccountEntity account) async {
    _checkInitialized();
    final result = await _storage.insert('accounts', account.toMap());
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to insert account',
        details: result.error,
      );
    }
  }

  Future<void> updateAccount(AccountEntity account) async {
    _checkInitialized();
    final result = await _storage.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to update account',
        details: result.error,
      );
    }
  }

  Future<void> deleteAccount(int id) async {
    _checkInitialized();
    final result = await _storage.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to delete account',
        details: result.error,
      );
    }
  }

  // Transaction 操作
  Future<List<TransactionEntity>> getAllTransactions() async {
    _checkInitialized();
    final result = await _storage.query('transactions');
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to get transactions',
        details: result.error,
      );
    }
    return result.data!.map((map) => TransactionEntity.fromMap(map)).toList();
  }

  Future<TransactionEntity?> getTransaction(int id) async {
    _checkInitialized();
    final result = await _storage.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to get transaction',
        details: result.error,
      );
    }
    if (result.data!.isEmpty) return null;
    return TransactionEntity.fromMap(result.data!.first);
  }

  Future<void> insertTransaction(TransactionEntity transaction) async {
    _checkInitialized();
    final result = await _storage.insert('transactions', transaction.toMap());
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to insert transaction',
        details: result.error,
      );
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    _checkInitialized();
    final result = await _storage.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to update transaction',
        details: result.error,
      );
    }
  }

  Future<void> deleteTransaction(int id) async {
    _checkInitialized();
    final result = await _storage.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to delete transaction',
        details: result.error,
      );
    }
  }

  // Category 操作
  Future<List<CategoryEntity>> getAllCategories() async {
    _checkInitialized();
    final result = await _storage.query('categories');
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to get categories',
        details: result.error,
      );
    }
    return result.data!.map((map) => CategoryEntity.fromMap(map)).toList();
  }

  Future<CategoryEntity?> getCategory(int id) async {
    _checkInitialized();
    final result = await _storage.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to get category',
        details: result.error,
      );
    }
    if (result.data!.isEmpty) return null;
    return CategoryEntity.fromMap(result.data!.first);
  }

  Future<void> insertCategory(CategoryEntity category) async {
    _checkInitialized();
    final result = await _storage.insert('categories', category.toMap());
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to insert category',
        details: result.error,
      );
    }
  }

  Future<void> updateCategory(CategoryEntity category) async {
    _checkInitialized();
    final result = await _storage.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to update category',
        details: result.error,
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    _checkInitialized();
    final result = await _storage.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to delete category',
        details: result.error,
      );
    }
  }

  // Budget 操作
  Future<List<BudgetEntity>> getAllBudgets() async {
    _checkInitialized();
    final result = await _storage.query('budgets');
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to get budgets',
        details: result.error,
      );
    }
    return result.data!.map((map) => BudgetEntity.fromMap(map)).toList();
  }

  Future<BudgetEntity?> getBudget(int id) async {
    _checkInitialized();
    final result = await _storage.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to get budget',
        details: result.error,
      );
    }
    if (result.data!.isEmpty) return null;
    return BudgetEntity.fromMap(result.data!.first);
  }

  Future<void> insertBudget(BudgetEntity budget) async {
    _checkInitialized();
    final result = await _storage.insert('budgets', budget.toMap());
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to insert budget',
        details: result.error,
      );
    }
  }

  Future<void> updateBudget(BudgetEntity budget) async {
    _checkInitialized();
    final result = await _storage.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to update budget',
        details: result.error,
      );
    }
  }

  Future<void> deleteBudget(int id) async {
    _checkInitialized();
    final result = await _storage.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.hasError) {
      throw AppDatabaseException(
        'Failed to delete budget',
        details: result.error,
      );
    }
  }
} 