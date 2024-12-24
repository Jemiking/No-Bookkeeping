import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import 'transaction_service.dart';

class TransactionServiceImpl implements TransactionService {
  final Database _db;
  final String _tableName = 'transactions';
  final String _templateTableName = 'transaction_templates';
  final Uuid _uuid = const Uuid();

  TransactionServiceImpl(this._db);

  @override
  Future<String> createTransaction(Transaction transaction) async {
    final String id = _uuid.v4();
    final Map<String, dynamic> data = transaction.copyWith(id: id).toJson();
    
    await _db.transaction((txn) async {
      await txn.insert(_tableName, data);
      if (transaction.type == TransactionType.transfer) {
        // 对于转账交易，需要创建对应的转入记录
        final transferInData = transaction.copyWith(
          id: _uuid.v4(),
          type: TransactionType.income,
          accountId: transaction.toAccountId!,
          toAccountId: transaction.accountId,
        ).toJson();
        await txn.insert(_tableName, transferInData);
      }
    });
    
    return id;
  }

  @override
  Future<Transaction> getTransaction(String id) async {
    final List<Map<String, dynamic>> results = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isEmpty) {
      throw Exception('Transaction not found');
    }
    
    return Transaction.fromJson(results.first);
  }

  @override
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    List<String>? tagIds,
  }) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (startDate != null) {
      whereClause += ' AND dateTime >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND dateTime <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.index);
    }
    
    if (accountId != null) {
      whereClause += ' AND (accountId = ? OR toAccountId = ?)';
      whereArgs.addAll([accountId, accountId]);
    }
    
    if (categoryId != null) {
      whereClause += ' AND categoryId = ?';
      whereArgs.add(categoryId);
    }
    
    if (tagIds != null && tagIds.isNotEmpty) {
      whereClause += ' AND tagIds LIKE ?';
      whereArgs.add('%${tagIds.join(',')}%');
    }
    
    final List<Map<String, dynamic>> results = await _db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'dateTime DESC',
    );
    
    return results.map((data) => Transaction.fromJson(data)).toList();
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _db.transaction((txn) async {
      final oldTransaction = await getTransaction(transaction.id);
      
      // 更新主交易记录
      await txn.update(
        _tableName,
        transaction.toJson(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      
      // 处理转账交易的特殊情况
      if (transaction.type == TransactionType.transfer) {
        if (oldTransaction.type != TransactionType.transfer) {
          // 如果原交易不是转账，但新交易是转账，创建转入记录
          final transferInData = transaction.copyWith(
            id: _uuid.v4(),
            type: TransactionType.income,
            accountId: transaction.toAccountId!,
            toAccountId: transaction.accountId,
          ).toJson();
          await txn.insert(_tableName, transferInData);
        } else {
          // 如果原交易是转账，更新对应的转入记录
          final transferInTransaction = await _findTransferInTransaction(transaction.id);
          if (transferInTransaction != null) {
            final updatedTransferIn = transferInTransaction.copyWith(
              amount: transaction.amount,
              accountId: transaction.toAccountId!,
              toAccountId: transaction.accountId,
              dateTime: transaction.dateTime,
              note: transaction.note,
            );
            await txn.update(
              _tableName,
              updatedTransferIn.toJson(),
              where: 'id = ?',
              whereArgs: [transferInTransaction.id],
            );
          }
        }
      } else if (oldTransaction.type == TransactionType.transfer) {
        // 如果原交易是转账，但新交易不是转账，删除对应的转入记录
        final transferInTransaction = await _findTransferInTransaction(oldTransaction.id);
        if (transferInTransaction != null) {
          await txn.delete(
            _tableName,
            where: 'id = ?',
            whereArgs: [transferInTransaction.id],
          );
        }
      }
    });
  }

  Future<Transaction?> _findTransferInTransaction(String transferOutId) async {
    final List<Map<String, dynamic>> results = await _db.query(
      _tableName,
      where: 'toAccountId = ? AND type = ?',
      whereArgs: [transferOutId, TransactionType.income.index],
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return Transaction.fromJson(results.first);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _db.transaction((txn) async {
      final transaction = await getTransaction(id);
      
      await txn.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (transaction.type == TransactionType.transfer) {
        final transferInTransaction = await _findTransferInTransaction(id);
        if (transferInTransaction != null) {
          await txn.delete(
            _tableName,
            where: 'id = ?',
            whereArgs: [transferInTransaction.id],
          );
        }
      }
    });
  }

  @override
  Future<void> batchCreateTransactions(List<Transaction> transactions) async {
    await _db.transaction((txn) async {
      for (final transaction in transactions) {
        final String id = _uuid.v4();
        final data = transaction.copyWith(id: id).toJson();
        await txn.insert(_tableName, data);
        
        if (transaction.type == TransactionType.transfer) {
          final transferInData = transaction.copyWith(
            id: _uuid.v4(),
            type: TransactionType.income,
            accountId: transaction.toAccountId!,
            toAccountId: transaction.accountId,
          ).toJson();
          await txn.insert(_tableName, transferInData);
        }
      }
    });
  }

  @override
  Future<void> batchUpdateTransactions(List<Transaction> transactions) async {
    await _db.transaction((txn) async {
      for (final transaction in transactions) {
        await updateTransaction(transaction);
      }
    });
  }

  @override
  Future<void> batchDeleteTransactions(List<String> ids) async {
    await _db.transaction((txn) async {
      for (final id in ids) {
        await deleteTransaction(id);
      }
    });
  }

  @override
  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> results = await _db.query(
      _tableName,
      where: 'isRecurring = ? AND recurringRule IS NOT NULL',
      whereArgs: [1],
    );
    
    final recurringTransactions = results.map((data) => Transaction.fromJson(data)).toList();
    
    for (final transaction in recurringTransactions) {
      if (transaction.recurringRule == null) continue;
      
      final rule = transaction.recurringRule!;
      if (rule.endDate != null && rule.endDate!.isBefore(now)) continue;
      if (rule.occurrences != null && rule.occurrences! <= 0) continue;
      
      // 创建下一次定期交易
      final nextDate = _calculateNextTransactionDate(transaction.dateTime, rule);
      if (nextDate.isBefore(now)) {
        final newTransaction = transaction.copyWith(
          id: _uuid.v4(),
          dateTime: nextDate,
          recurringRule: rule.copyWith(
            occurrences: rule.occurrences != null ? rule.occurrences! - 1 : null,
          ),
        );
        await createTransaction(newTransaction);
      }
    }
  }

  DateTime _calculateNextTransactionDate(DateTime lastDate, RecurringRule rule) {
    switch (rule.frequency) {
      case RecurringFrequency.daily:
        return lastDate.add(Duration(days: rule.interval));
      case RecurringFrequency.weekly:
        return lastDate.add(Duration(days: 7 * rule.interval));
      case RecurringFrequency.monthly:
        return DateTime(
          lastDate.year,
          lastDate.month + rule.interval,
          lastDate.day,
        );
      case RecurringFrequency.yearly:
        return DateTime(
          lastDate.year + rule.interval,
          lastDate.month,
          lastDate.day,
        );
    }
  }

  @override
  Future<List<Transaction>> getUpcomingRecurringTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now();
    final end = endDate ?? start.add(const Duration(days: 30));
    
    final List<Map<String, dynamic>> results = await _db.query(
      _tableName,
      where: 'isRecurring = ? AND recurringRule IS NOT NULL',
      whereArgs: [1],
    );
    
    final recurringTransactions = results.map((data) => Transaction.fromJson(data)).toList();
    final List<Transaction> upcomingTransactions = [];
    
    for (final transaction in recurringTransactions) {
      if (transaction.recurringRule == null) continue;
      
      final rule = transaction.recurringRule!;
      DateTime nextDate = transaction.dateTime;
      
      while (nextDate.isBefore(end)) {
        if (nextDate.isAfter(start)) {
          upcomingTransactions.add(transaction.copyWith(
            id: _uuid.v4(),
            dateTime: nextDate,
          ));
        }
        nextDate = _calculateNextTransactionDate(nextDate, rule);
      }
    }
    
    return upcomingTransactions;
  }

  @override
  Future<void> saveAsTemplate(Transaction transaction, String templateName) async {
    final templateData = transaction.copyWith(
      id: _uuid.v4(),
      templateName: templateName,
    ).toJson();
    
    await _db.insert(_templateTableName, templateData);
  }

  @override
  Future<List<Transaction>> getTemplates() async {
    final List<Map<String, dynamic>> results = await _db.query(_templateTableName);
    return results.map((data) => Transaction.fromJson(data)).toList();
  }

  @override
  Future<Transaction> createFromTemplate(String templateId) async {
    final List<Map<String, dynamic>> results = await _db.query(
      _templateTableName,
      where: 'id = ?',
      whereArgs: [templateId],
    );
    
    if (results.isEmpty) {
      throw Exception('Template not found');
    }
    
    final template = Transaction.fromJson(results.first);
    final newTransaction = template.copyWith(
      id: _uuid.v4(),
      dateTime: DateTime.now(),
      templateName: null,
    );
    
    await createTransaction(newTransaction);
    return newTransaction;
  }

  @override
  Future<String> uploadAttachment(String transactionId, File file) async {
    final String fileName = '${transactionId}_${path.basename(file.path)}';
    final String savePath = await _saveAttachmentFile(file, fileName);
    
    await _db.update(
      _tableName,
      {'attachmentPath': savePath},
      where: 'id = ?',
      whereArgs: [transactionId],
    );
    
    return savePath;
  }

  Future<String> _saveAttachmentFile(File file, String fileName) async {
    // 实现文件保存逻辑
    // 这里需要��据实际的文件存储策略来实现
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAttachment(String transactionId) async {
    final transaction = await getTransaction(transactionId);
    if (transaction.attachmentPath != null) {
      final file = File(transaction.attachmentPath!);
      if (await file.exists()) {
        await file.delete();
      }
      
      await _db.update(
        _tableName,
        {'attachmentPath': null},
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    }
  }

  @override
  Future<File?> getAttachment(String transactionId) async {
    final transaction = await getTransaction(transactionId);
    if (transaction.attachmentPath != null) {
      final file = File(transaction.attachmentPath!);
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  @override
  Future<Map<String, double>> getTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? categoryId,
  }) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (startDate != null) {
      whereClause += ' AND dateTime >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND dateTime <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.index);
    }
    
    if (categoryId != null) {
      whereClause += ' AND categoryId = ?';
      whereArgs.add(categoryId);
    }
    
    final List<Map<String, dynamic>> results = await _db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
    );
    
    final transactions = results.map((data) => Transaction.fromJson(data)).toList();
    
    double totalIncome = 0;
    double totalExpense = 0;
    double totalTransfer = 0;
    
    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.income:
          totalIncome += transaction.amount;
          break;
        case TransactionType.expense:
          totalExpense += transaction.amount;
          break;
        case TransactionType.transfer:
          totalTransfer += transaction.amount;
          break;
      }
    }
    
    return {
      'income': totalIncome,
      'expense': totalExpense,
      'transfer': totalTransfer,
      'balance': totalIncome - totalExpense,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionsByCategory({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (startDate != null) {
      whereClause += ' AND dateTime >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND dateTime <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.index);
    }
    
    final List<Map<String, dynamic>> results = await _db.rawQuery('''
      SELECT categoryId, SUM(amount) as total, COUNT(*) as count
      FROM $_tableName
      WHERE $whereClause
      GROUP BY categoryId
    ''', whereArgs);
    
    return results;
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionsByTag({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (startDate != null) {
      whereClause += ' AND dateTime >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND dateTime <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.index);
    }
    
    // 注意：这里的实现可能需要根据具体的标签存储方式来调整
    final List<Map<String, dynamic>> results = await _db.rawQuery('''
      SELECT tagIds, SUM(amount) as total, COUNT(*) as count
      FROM $_tableName
      WHERE $whereClause
      GROUP BY tagIds
    ''', whereArgs);
    
    return results;
  }
} 