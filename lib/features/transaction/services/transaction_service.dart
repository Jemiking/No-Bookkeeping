import 'dart:io';
import '../models/transaction.dart';

abstract class TransactionService {
  // 基础CRUD操作
  Future<String> createTransaction(Transaction transaction);
  Future<Transaction> getTransaction(String id);
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    List<String>? tagIds,
  });
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  
  // 批量操作
  Future<void> batchCreateTransactions(List<Transaction> transactions);
  Future<void> batchUpdateTransactions(List<Transaction> transactions);
  Future<void> batchDeleteTransactions(List<String> ids);
  
  // 定期交易处理
  Future<void> processRecurringTransactions();
  Future<List<Transaction>> getUpcomingRecurringTransactions({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  // 交易模板
  Future<void> saveAsTemplate(Transaction transaction, String templateName);
  Future<List<Transaction>> getTemplates();
  Future<Transaction> createFromTemplate(String templateId);
  
  // 附件管理
  Future<String> uploadAttachment(String transactionId, File file);
  Future<void> deleteAttachment(String transactionId);
  Future<File?> getAttachment(String transactionId);
  
  // 统计功能
  Future<Map<String, double>> getTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? categoryId,
  });
  
  Future<List<Map<String, dynamic>>> getTransactionsByCategory({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  });
  
  Future<List<Map<String, dynamic>>> getTransactionsByTag({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  });
} 