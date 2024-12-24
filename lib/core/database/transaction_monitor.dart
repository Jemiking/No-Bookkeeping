import 'dart:async';
import 'package:sqflite/sqflite.dart';

class TransactionMonitor {
  final Map<String, _TransactionInfo> _transactions = {};
  final StreamController<TransactionEvent> _eventController = 
      StreamController<TransactionEvent>.broadcast();

  // 事件流
  Stream<TransactionEvent> get transactionEvents => _eventController.stream;

  // 开始监控事务
  void beginMonitor(String transactionId) {
    _transactions[transactionId] = _TransactionInfo(
      startTime: DateTime.now(),
      status: TransactionStatus.active,
    );
    _emitEvent(TransactionEvent(
      type: TransactionEventType.begin,
      transactionId: transactionId,
      timestamp: DateTime.now(),
    ));
  }

  // 结束监控事务
  void endMonitor(String transactionId, bool success) {
    final info = _transactions[transactionId];
    if (info == null) return;

    info.endTime = DateTime.now();
    info.status = success ? TransactionStatus.committed : TransactionStatus.rolledBack;

    _emitEvent(TransactionEvent(
      type: success ? TransactionEventType.commit : TransactionEventType.rollback,
      transactionId: transactionId,
      timestamp: DateTime.now(),
      duration: info.duration,
    ));

    _transactions.remove(transactionId);
  }

  // 记录事务操作
  void logOperation(String transactionId, String operation) {
    final info = _transactions[transactionId];
    if (info == null) return;

    info.operations.add(_TransactionOperation(
      operation: operation,
      timestamp: DateTime.now(),
    ));

    _emitEvent(TransactionEvent(
      type: TransactionEventType.operation,
      transactionId: transactionId,
      timestamp: DateTime.now(),
      operation: operation,
    ));
  }

  // 记录事务错误
  void logError(String transactionId, Object error) {
    final info = _transactions[transactionId];
    if (info == null) return;

    info.errors.add(_TransactionError(
      error: error,
      timestamp: DateTime.now(),
    ));

    _emitEvent(TransactionEvent(
      type: TransactionEventType.error,
      transactionId: transactionId,
      timestamp: DateTime.now(),
      error: error,
    ));
  }

  // 获取活跃事务信息
  List<TransactionSummary> getActiveTransactions() {
    return _transactions.entries
        .where((entry) => entry.value.status == TransactionStatus.active)
        .map((entry) => TransactionSummary(
              transactionId: entry.key,
              startTime: entry.value.startTime,
              operationCount: entry.value.operations.length,
              errorCount: entry.value.errors.length,
              duration: entry.value.duration,
            ))
        .toList();
  }

  // 获取事务统计信息
  TransactionStatistics getStatistics() {
    final completed = _transactions.values
        .where((info) => info.status != TransactionStatus.active)
        .toList();

    final successful = completed
        .where((info) => info.status == TransactionStatus.committed)
        .length;

    final failed = completed
        .where((info) => info.status == TransactionStatus.rolledBack)
        .length;

    final averageDuration = completed.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: completed
                    .map((info) => info.duration.inMilliseconds)
                    .reduce((a, b) => a + b) ~/
                completed.length,
          );

    return TransactionStatistics(
      totalTransactions: completed.length,
      successfulTransactions: successful,
      failedTransactions: failed,
      averageDuration: averageDuration,
    );
  }

  // 清理过期事务记录
  void cleanup(Duration maxAge) {
    final now = DateTime.now();
    _transactions.removeWhere((_, info) =>
        info.status != TransactionStatus.active &&
        now.difference(info.startTime) > maxAge);
  }

  // 发送事件
  void _emitEvent(TransactionEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  // 释放资源
  void dispose() {
    _eventController.close();
  }
}

// 事务状态
enum TransactionStatus {
  active,
  committed,
  rolledBack,
}

// 事件类型
enum TransactionEventType {
  begin,
  commit,
  rollback,
  operation,
  error,
}

// 事务事件
class TransactionEvent {
  final TransactionEventType type;
  final String transactionId;
  final DateTime timestamp;
  final Duration? duration;
  final String? operation;
  final Object? error;

  TransactionEvent({
    required this.type,
    required this.transactionId,
    required this.timestamp,
    this.duration,
    this.operation,
    this.error,
  });
}

// 事务信息
class _TransactionInfo {
  final DateTime startTime;
  DateTime? endTime;
  TransactionStatus status;
  final List<_TransactionOperation> operations = [];
  final List<_TransactionError> errors = [];

  _TransactionInfo({
    required this.startTime,
    required this.status,
  });

  Duration get duration => endTime?.difference(startTime) ?? 
      DateTime.now().difference(startTime);
}

// 事务操作记录
class _TransactionOperation {
  final String operation;
  final DateTime timestamp;

  _TransactionOperation({
    required this.operation,
    required this.timestamp,
  });
}

// 事务错误记录
class _TransactionError {
  final Object error;
  final DateTime timestamp;

  _TransactionError({
    required this.error,
    required this.timestamp,
  });
}

// 事务摘要
class TransactionSummary {
  final String transactionId;
  final DateTime startTime;
  final int operationCount;
  final int errorCount;
  final Duration duration;

  TransactionSummary({
    required this.transactionId,
    required this.startTime,
    required this.operationCount,
    required this.errorCount,
    required this.duration,
  });
}

// 事务统计信息
class TransactionStatistics {
  final int totalTransactions;
  final int successfulTransactions;
  final int failedTransactions;
  final Duration averageDuration;

  TransactionStatistics({
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.averageDuration,
  });
}