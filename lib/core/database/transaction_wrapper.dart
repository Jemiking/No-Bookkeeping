import 'package:sqflite/sqflite.dart';
import 'transaction_manager.dart';

class TransactionWrapper {
  final TransactionManager _transactionManager;
  String? _currentTransactionId;

  TransactionWrapper(this._transactionManager);

  // 开始事务
  Future<void> begin() async {
    if (_currentTransactionId != null) {
      throw Exception('Transaction already started');
    }
    _currentTransactionId = await _transactionManager.beginTransaction();
  }

  // 提交事务
  Future<void> commit() async {
    if (_currentTransactionId == null) {
      throw Exception('No active transaction');
    }
    await _transactionManager.commitTransaction(_currentTransactionId!);
    _currentTransactionId = null;
  }

  // 回滚事务
  Future<void> rollback() async {
    if (_currentTransactionId == null) {
      throw Exception('No active transaction');
    }
    await _transactionManager.rollbackTransaction(_currentTransactionId!);
    _currentTransactionId = null;
  }

  // 在事务中执行操作
  Future<T> execute<T>(Future<T> Function(Transaction) action) async {
    if (_currentTransactionId == null) {
      throw Exception('No active transaction');
    }
    return await _transactionManager.executeInTransaction(
      _currentTransactionId!,
      action,
    );
  }

  // 检查是否在事务中
  bool get isInTransaction => _currentTransactionId != null;

  // 获取当前事务ID
  String? get currentTransactionId => _currentTransactionId;

  // 安全执行事务
  Future<T> transaction<T>(Future<T> Function(Transaction) action) async {
    if (isInTransaction) {
      return await execute(action);
    }

    try {
      await begin();
      final result = await execute(action);
      await commit();
      return result;
    } catch (e) {
      await rollback();
      rethrow;
    }
  }

  // 批量执行事务
  Future<List<T>> batchTransaction<T>(
    List<Future<T> Function(Transaction)> actions,
  ) async {
    return await transaction((txn) async {
      final results = <T>[];
      for (final action in actions) {
        results.add(await action(txn));
      }
      return results;
    });
  }
} 