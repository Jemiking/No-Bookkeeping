import '../database/dao/transaction_dao.dart';
import '../database/dao/account_dao.dart';
import '../database/models/transaction.dart';
import '../database/models/account.dart';
import '../cache/cache_manager.dart';

/// 交易服务类
class TransactionService {
  final TransactionDao _transactionDao;
  final AccountDao _accountDao;
  final CacheManager _cacheManager;

  /// 构造函数
  TransactionService(this._transactionDao, this._accountDao, this._cacheManager);

  /// 创建交易
  Future<Transaction> createTransaction(Transaction transaction) async {
    return await _transactionDao.transaction((txn) async {
      // 验证账户是否存在
      final account = await _accountDao.get(transaction.accountId);
      if (account == null) {
        throw Exception('账户不存在');
      }

      // 如果是转账交易，验证目标账户是否存在
      if (transaction.type == TransactionType.transfer) {
        if (transaction.toAccountId == null) {
          throw Exception('转账交易必须指定目标账户');
        }
        final toAccount = await _accountDao.get(transaction.toAccountId!);
        if (toAccount == null) {
          throw Exception('目标账户不存在');
        }
      }

      // 插入交易记录
      final id = await _transactionDao.insert(transaction);
      final createdTransaction = transaction.copyWith(id: id);

      // 更新账户余额
      await _updateAccountBalance(transaction);

      // 更新缓存
      final cachedTransactions = await _getCachedTransactions();
      cachedTransactions.add(createdTransaction);
      await _cacheManager.cacheTransactions(cachedTransactions);

      return createdTransaction;
    });
  }

  /// 更新交易
  Future<Transaction> updateTransaction(Transaction transaction) async {
    return await _transactionDao.transaction((txn) async {
      // 获取原交易记录
      final oldTransaction = await _transactionDao.get(transaction.id!);
      if (oldTransaction == null) {
        throw Exception('交易记录不存在');
      }

      // 更新交易记录
      await _transactionDao.update(transaction);

      // 恢复原账户余额
      await _revertAccountBalance(oldTransaction);

      // 更新新的账户余额
      await _updateAccountBalance(transaction);

      // 更新缓存
      final cachedTransactions = await _getCachedTransactions();
      final index = cachedTransactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        cachedTransactions[index] = transaction;
        await _cacheManager.cacheTransactions(cachedTransactions);
      }

      return transaction;
    });
  }

  /// 删除交易
  Future<void> deleteTransaction(int id) async {
    return await _transactionDao.transaction((txn) async {
      // 获取交易记录
      final transaction = await _transactionDao.get(id);
      if (transaction == null) {
        throw Exception('交易记录不存在');
      }

      // 删除交易记录
      await _transactionDao.delete(id);

      // 恢复账户余额
      await _revertAccountBalance(transaction);

      // 更新缓存
      final cachedTransactions = await _getCachedTransactions();
      cachedTransactions.removeWhere((t) => t.id == id);
      await _cacheManager.cacheTransactions(cachedTransactions);
    });
  }

  /// 获取交易
  Future<Transaction?> getTransaction(int id) async {
    // 先从缓存获取
    final cachedTransactions = await _getCachedTransactions();
    final cachedTransaction = cachedTransactions.firstWhere(
      (t) => t.id == id,
      orElse: () => null as Transaction,
    );
    if (cachedTransaction != null) {
      return cachedTransaction;
    }

    // 从数据库获取
    return await _transactionDao.get(id);
  }

  /// 获取所有交易
  Future<List<Transaction>> getAllTransactions() async {
    // 先从缓存获取
    final cachedTransactions = await _getCachedTransactions();
    if (cachedTransactions.isNotEmpty) {
      return cachedTransactions;
    }

    // 从数据库获取
    final transactions = await _transactionDao.getAll();
    
    // 更新缓存
    await _cacheManager.cacheTransactions(transactions);
    
    return transactions;
  }

  /// 获取账户的交易记录
  Future<List<Transaction>> getTransactionsByAccount(int accountId) async {
    return await _transactionDao.getByAccount(accountId);
  }

  /// 获取分类的交易记录
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    return await _transactionDao.getByCategory(categoryId);
  }

  /// 获取标签的交易记录
  Future<List<Transaction>> getTransactionsByTag(int tagId) async {
    return await _transactionDao.getByTag(tagId);
  }

  /// 获取日期范围内的交易记录
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _transactionDao.getByDateRange(start, end);
  }

  /// 搜索交易记录
  Future<List<Transaction>> searchTransactions({
    String? keyword,
    List<TransactionType>? types,
    List<int>? accountIds,
    List<int>? categoryIds,
    List<int>? tagIds,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    TransactionStatus? status,
  }) async {
    return await _transactionDao.search(
      keyword: keyword,
      types: types,
      accountIds: accountIds,
      categoryIds: categoryIds,
      tagIds: tagIds,
      startDate: startDate,
      endDate: endDate,
      minAmount: minAmount,
      maxAmount: maxAmount,
      status: status,
    );
  }

  /// 获取统计数据
  Future<Map<String, dynamic>> getStatistics({
    List<int>? accountIds,
    List<int>? categoryIds,
    List<int>? tagIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _transactionDao.getStatistics(
      accountIds: accountIds,
      categoryIds: categoryIds,
      tagIds: tagIds,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 更新账户余额
  Future<void> _updateAccountBalance(Transaction transaction) async {
    switch (transaction.type) {
      case TransactionType.income:
        await _accountDao.updateBalance(
          transaction.accountId,
          (await _accountDao.get(transaction.accountId))!.currentBalance + transaction.amount,
        );
        break;
      case TransactionType.expense:
        await _accountDao.updateBalance(
          transaction.accountId,
          (await _accountDao.get(transaction.accountId))!.currentBalance - transaction.amount,
        );
        break;
      case TransactionType.transfer:
        // 转出账户减少余额
        await _accountDao.updateBalance(
          transaction.accountId,
          (await _accountDao.get(transaction.accountId))!.currentBalance - transaction.amount,
        );
        // 转入账户增加余额
        await _accountDao.updateBalance(
          transaction.toAccountId!,
          (await _accountDao.get(transaction.toAccountId!))!.currentBalance + transaction.amount,
        );
        break;
    }
  }

  /// 恢复账户余额
  Future<void> _revertAccountBalance(Transaction transaction) async {
    switch (transaction.type) {
      case TransactionType.income:
        await _accountDao.updateBalance(
          transaction.accountId,
          (await _accountDao.get(transaction.accountId))!.currentBalance - transaction.amount,
        );
        break;
      case TransactionType.expense:
        await _accountDao.updateBalance(
          transaction.accountId,
          (await _accountDao.get(transaction.accountId))!.currentBalance + transaction.amount,
        );
        break;
      case TransactionType.transfer:
        // 转出账户恢复余额
        await _accountDao.updateBalance(
          transaction.accountId,
          (await _accountDao.get(transaction.accountId))!.currentBalance + transaction.amount,
        );
        // 转入账户恢复余额
        await _accountDao.updateBalance(
          transaction.toAccountId!,
          (await _accountDao.get(transaction.toAccountId!))!.currentBalance - transaction.amount,
        );
        break;
    }
  }

  /// 从缓存获取交易列表
  Future<List<Transaction>> _getCachedTransactions() async {
    return _cacheManager.getCachedTransactions() ?? [];
  }
} 