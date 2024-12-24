import 'package:sqflite/sqflite.dart';
import 'dart:async';

class TransactionManager {
  final Database _db;
  final Map<String, Transaction> _activeTransactions = {};
  final Map<String, Completer<void>> _transactionLocks = {};

  TransactionManager(this._db);

  // 开始新事务
  Future<String> beginTransaction() async {
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
    final completer = Completer<void>();
    _transactionLocks[transactionId] = completer;

    try {
      await _db.transaction((txn) async {
        _activeTransactions[transactionId] = txn;
        await completer.future;
        _activeTransactions.remove(transactionId);
      });
      return transactionId;
    } catch (e) {
      _activeTransactions.remove(transactionId);
      _transactionLocks.remove(transactionId);
      rethrow;
    }
  }

  // 提交事务
  Future<void> commitTransaction(String transactionId) async {
    final completer = _transactionLocks[transactionId];
    if (completer == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    completer.complete();
    _transactionLocks.remove(transactionId);
  }

  // 回滚事务
  Future<void> rollbackTransaction(String transactionId) async {
    final completer = _transactionLocks[transactionId];
    if (completer == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    completer.completeError(Exception('Transaction rolled back'));
    _transactionLocks.remove(transactionId);
  }

  // 在事务中执行操作
  Future<T> executeInTransaction<T>(
    String transactionId,
    Future<T> Function(Transaction) action,
  ) async {
    final transaction = _activeTransactions[transactionId];
    if (transaction == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    return await action(transaction);
  }

  // 检查事务是否活跃
  bool isTransactionActive(String transactionId) {
    return _activeTransactions.containsKey(transactionId);
  }

  // 获取活跃事务数量
  int get activeTransactionCount => _activeTransactions.length;

  // 清理所有事务
  Future<void> clearAllTransactions() async {
    for (final transactionId in List.from(_transactionLocks.keys)) {
      await rollbackTransaction(transactionId);
    }
    _activeTransactions.clear();
    _transactionLocks.clear();
  }
} 