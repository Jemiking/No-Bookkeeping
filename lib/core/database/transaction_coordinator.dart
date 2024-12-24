import 'package:sqflite/sqflite.dart';
import 'transaction_manager.dart';
import 'transaction_monitor.dart';
import 'transaction_wrapper.dart';

class TransactionCoordinator {
  final TransactionManager _manager;
  final TransactionMonitor _monitor;
  final Map<String, TransactionWrapper> _activeWrappers = {};

  TransactionCoordinator(Database db)
      : _manager = TransactionManager(db),
        _monitor = TransactionMonitor();

  // 创建新的事务包装器
  Future<TransactionWrapper> createTransaction() async {
    final wrapper = TransactionWrapper(_manager);
    await wrapper.begin();
    
    final transactionId = wrapper.currentTransactionId!;
    _activeWrappers[transactionId] = wrapper;
    _monitor.beginMonitor(transactionId);
    
    return wrapper;
  }

  // 提交事务
  Future<void> commitTransaction(String transactionId) async {
    final wrapper = _activeWrappers[transactionId];
    if (wrapper == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    try {
      await wrapper.commit();
      _monitor.endMonitor(transactionId, true);
    } finally {
      _activeWrappers.remove(transactionId);
    }
  }

  // 回滚事务
  Future<void> rollbackTransaction(String transactionId) async {
    final wrapper = _activeWrappers[transactionId];
    if (wrapper == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    try {
      await wrapper.rollback();
      _monitor.endMonitor(transactionId, false);
    } finally {
      _activeWrappers.remove(transactionId);
    }
  }

  // 执行事务操作
  Future<T> executeTransaction<T>(
    Future<T> Function(Transaction) action, {
    bool useExisting = true,
  }) async {
    TransactionWrapper? wrapper;
    String? transactionId;
    bool isNewTransaction = false;

    try {
      // 尝试使用现有事务
      if (useExisting && _activeWrappers.isNotEmpty) {
        wrapper = _activeWrappers.values.first;
        transactionId = wrapper.currentTransactionId;
      }

      // 如果没有现有事务，创建新事务
      if (wrapper == null) {
        wrapper = await createTransaction();
        transactionId = wrapper.currentTransactionId;
        isNewTransaction = true;
      }

      // 执行操作
      final result = await wrapper.execute(action);

      // 记录操作
      _monitor.logOperation(
        transactionId!,
        'Execute operation: ${action.runtimeType}',
      );

      // 如果是新事务，自动提交
      if (isNewTransaction) {
        await commitTransaction(transactionId);
      }

      return result;
    } catch (e) {
      // 记录错误
      if (transactionId != null) {
        _monitor.logError(transactionId, e);
      }

      // 如果是新事务，自动回滚
      if (isNewTransaction && transactionId != null) {
        await rollbackTransaction(transactionId);
      }

      rethrow;
    }
  }

  // 批量执行事务操作
  Future<List<T>> executeBatch<T>(
    List<Future<T> Function(Transaction)> actions,
  ) async {
    final wrapper = await createTransaction();
    final transactionId = wrapper.currentTransactionId!;

    try {
      final results = <T>[];
      for (final action in actions) {
        final result = await wrapper.execute(action);
        results.add(result);
        _monitor.logOperation(
          transactionId,
          'Execute batch operation: ${action.runtimeType}',
        );
      }

      await commitTransaction(transactionId);
      return results;
    } catch (e) {
      _monitor.logError(transactionId, e);
      await rollbackTransaction(transactionId);
      rethrow;
    }
  }

  // 获取活跃事务信息
  List<TransactionSummary> getActiveTransactions() {
    return _monitor.getActiveTransactions();
  }

  // 获取事务统计信息
  TransactionStatistics getStatistics() {
    return _monitor.getStatistics();
  }

  // 清理过期事务
  void cleanup(Duration maxAge) {
    _monitor.cleanup(maxAge);
  }

  // 监听事务事件
  Stream<TransactionEvent> get transactionEvents => _monitor.transactionEvents;

  // 释放资源
  void dispose() {
    _monitor.dispose();
  }
} 