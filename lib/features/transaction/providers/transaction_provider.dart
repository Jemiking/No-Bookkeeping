import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service;
  
  List<Transaction> _transactions = [];
  List<Transaction> _templates = [];
  Map<String, double> _summary = {
    'income': 0,
    'expense': 0,
    'transfer': 0,
    'balance': 0,
  };
  bool _isLoading = false;
  String? _error;
  
  TransactionProvider(this._service);
  
  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get templates => _templates;
  Map<String, double> get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 加载交易记录
  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    List<String>? tagIds,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _transactions = await _service.getTransactions(
        startDate: startDate,
        endDate: endDate,
        type: type,
        accountId: accountId,
        categoryId: categoryId,
        tagIds: tagIds,
      );
      
      await _updateSummary(
        startDate: startDate,
        endDate: endDate,
        type: type,
        categoryId: categoryId,
      );
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 创建交易记录
  Future<void> createTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.createTransaction(transaction);
      await loadTransactions(); // 重新加载交易记录
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 更新交易记录
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.updateTransaction(transaction);
      await loadTransactions(); // 重新加载交易记录
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 删除交易记录
  Future<void> deleteTransaction(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.deleteTransaction(id);
      await loadTransactions(); // 重新加载交易记录
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 批量操作
  Future<void> batchCreateTransactions(List<Transaction> transactions) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.batchCreateTransactions(transactions);
      await loadTransactions(); // 重新加载交易记录
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> batchUpdateTransactions(List<Transaction> transactions) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.batchUpdateTransactions(transactions);
      await loadTransactions(); // 重新加载交易记录
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> batchDeleteTransactions(List<String> ids) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.batchDeleteTransactions(ids);
      await loadTransactions(); // 重新加载交易记录
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 定期交易处理
  Future<void> processRecurringTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.processRecurringTransactions();
      await loadTransactions(); // 重新加载交易记录
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Transaction>> getUpcomingRecurringTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      return await _service.getUpcomingRecurringTransactions(
        startDate: startDate,
        endDate: endDate,
      );
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 模板管理
  Future<void> loadTemplates() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _templates = await _service.getTemplates();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> saveAsTemplate(Transaction transaction, String templateName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.saveAsTemplate(transaction, templateName);
      await loadTemplates(); // 重新加载模板
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Transaction> createFromTemplate(String templateId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final transaction = await _service.createFromTemplate(templateId);
      await loadTransactions(); // 重新加载交易记录
      return transaction;
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 附件管理
  Future<String> uploadAttachment(String transactionId, File file) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final path = await _service.uploadAttachment(transactionId, file);
      await loadTransactions(); // 重新加载交易记录
      return path;
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteAttachment(String transactionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.deleteAttachment(transactionId);
      await loadTransactions(); // 重新加载交易记录
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<File?> getAttachment(String transactionId) async {
    try {
      return await _service.getAttachment(transactionId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // 统计功能
  Future<void> _updateSummary({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? categoryId,
  }) async {
    try {
      _summary = await _service.getTransactionSummary(
        startDate: startDate,
        endDate: endDate,
        type: type,
        categoryId: categoryId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<List<Map<String, dynamic>>> getTransactionsByCategory({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      return await _service.getTransactionsByCategory(
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Map<String, dynamic>>> getTransactionsByTag({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      return await _service.getTransactionsByTag(
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 错误处理
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 