import '../database/dao/account_dao.dart';
import '../database/models/account.dart';
import '../cache/cache_manager.dart';

/// 账户服务类
class AccountService {
  final AccountDao _accountDao;
  final CacheManager _cacheManager;

  /// 构造函数
  AccountService(this._accountDao, this._cacheManager);

  /// 创建账户
  Future<Account> createAccount(Account account) async {
    // 验证账户名是否已存在
    final exists = await _accountDao.isNameExists(account.name);
    if (exists) {
      throw Exception('账户名已存在');
    }

    // 插入账户
    final id = await _accountDao.insert(account);
    final createdAccount = account.copyWith(id: id);

    // 更新缓存
    final cachedAccounts = await _getCachedAccounts();
    cachedAccounts.add(createdAccount);
    await _cacheManager.cacheAccounts(cachedAccounts);

    return createdAccount;
  }

  /// 更新账户
  Future<Account> updateAccount(Account account) async {
    // 验证账户名是否已存在（排除当前账户）
    final exists = await _accountDao.isNameExists(
      account.name,
      excludeId: account.id,
    );
    if (exists) {
      throw Exception('账户名已存在');
    }

    // 更新账户
    await _accountDao.update(account);

    // 更新缓存
    final cachedAccounts = await _getCachedAccounts();
    final index = cachedAccounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      cachedAccounts[index] = account;
      await _cacheManager.cacheAccounts(cachedAccounts);
    }

    return account;
  }

  /// 删除账户
  Future<void> deleteAccount(int id) async {
    // 删除账户
    await _accountDao.delete(id);

    // 更新缓存
    final cachedAccounts = await _getCachedAccounts();
    cachedAccounts.removeWhere((a) => a.id == id);
    await _cacheManager.cacheAccounts(cachedAccounts);
  }

  /// 获取账户
  Future<Account?> getAccount(int id) async {
    // 先从缓存获取
    final cachedAccounts = await _getCachedAccounts();
    final cachedAccount = cachedAccounts.firstWhere(
      (a) => a.id == id,
      orElse: () => null as Account,
    );
    if (cachedAccount != null) {
      return cachedAccount;
    }

    // 从数据库获取
    return await _accountDao.get(id);
  }

  /// 获取所有账户
  Future<List<Account>> getAllAccounts() async {
    // 先从缓存获取
    final cachedAccounts = await _getCachedAccounts();
    if (cachedAccounts.isNotEmpty) {
      return cachedAccounts;
    }

    // 从数据库获取
    final accounts = await _accountDao.getAll();
    
    // 更新缓存
    await _cacheManager.cacheAccounts(accounts);
    
    return accounts;
  }

  /// 获取活跃账户
  Future<List<Account>> getActiveAccounts() async {
    final accounts = await getAllAccounts();
    return accounts.where((a) => a.status == AccountStatus.active).toList();
  }

  /// 获取已归档账户
  Future<List<Account>> getArchivedAccounts() async {
    final accounts = await getAllAccounts();
    return accounts.where((a) => a.status == AccountStatus.archived).toList();
  }

  /// 获取账户总余额
  Future<double> getTotalBalance() async {
    final accounts = await getActiveAccounts();
    return accounts.fold(0, (sum, account) => sum + account.currentBalance);
  }

  /// 按货币获取账户总余额
  Future<Map<String, double>> getTotalBalanceByCurrency() async {
    final accounts = await getActiveAccounts();
    final balances = <String, double>{};
    
    for (final account in accounts) {
      final currency = account.currencyCode;
      balances[currency] = (balances[currency] ?? 0) + account.currentBalance;
    }
    
    return balances;
  }

  /// 更新账户余额
  Future<void> updateBalance(int id, double newBalance) async {
    await _accountDao.updateBalance(id, newBalance);
    
    // 更新缓存
    final cachedAccounts = await _getCachedAccounts();
    final index = cachedAccounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      cachedAccounts[index] = cachedAccounts[index].copyWith(
        currentBalance: newBalance,
        updatedAt: DateTime.now(),
      );
      await _cacheManager.cacheAccounts(cachedAccounts);
    }
  }

  /// 批量更新账户状态
  Future<void> updateStatus(List<int> ids, AccountStatus status) async {
    await _accountDao.updateStatus(ids, status);
    
    // 更新缓存
    final cachedAccounts = await _getCachedAccounts();
    for (final id in ids) {
      final index = cachedAccounts.indexWhere((a) => a.id == id);
      if (index != -1) {
        cachedAccounts[index] = cachedAccounts[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      }
    }
    await _cacheManager.cacheAccounts(cachedAccounts);
  }

  /// 从缓存获取账户列表
  Future<List<Account>> _getCachedAccounts() async {
    return _cacheManager.getCachedAccounts() ?? [];
  }
} 