import 'package:uuid/uuid.dart';
import '../domain/recurring_transaction.dart';
import '../data/recurring_transaction_repository.dart';
import '../domain/transaction.dart';
import '../data/transaction_repository.dart';

class RecurringTransactionService {
  final RecurringTransactionRepository _recurringRepository;
  final TransactionRepository _transactionRepository;
  final _uuid = const Uuid();

  RecurringTransactionService(this._recurringRepository, this._transactionRepository);

  Future<String> createRecurringTransaction({
    required String accountId,
    String? toAccountId,
    required TransactionType type,
    required double amount,
    required String currency,
    String? categoryId,
    List<String> tagIds = const [],
    required String description,
    required RecurringPeriod period,
    required DateTime startDate,
    DateTime? endDate,
    int? repeatCount,
  }) async {
    final now = DateTime.now();
    final transaction = RecurringTransaction(
      id: _uuid.v4(),
      accountId: accountId,
      toAccountId: toAccountId,
      type: type,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      tagIds: tagIds,
      description: description,
      period: period,
      startDate: startDate,
      endDate: endDate,
      repeatCount: repeatCount,
      createdAt: now,
      updatedAt: now,
    );

    return await _recurringRepository.create(transaction);
  }

  Future<RecurringTransaction?> getRecurringTransaction(String id) async {
    return await _recurringRepository.get(id);
  }

  Future<List<RecurringTransaction>> getAllRecurringTransactions() async {
    return await _recurringRepository.getAll();
  }

  Future<List<RecurringTransaction>> getAccountRecurringTransactions(String accountId) async {
    return await _recurringRepository.getAllByAccountId(accountId);
  }

  Future<void> updateRecurringTransaction(RecurringTransaction transaction) async {
    final updatedTransaction = transaction.copyWith(
      updatedAt: DateTime.now(),
    );
    await _recurringRepository.update(updatedTransaction);
  }

  Future<void> deleteRecurringTransaction(String id) async {
    await _recurringRepository.delete(id);
  }

  Future<void> deactivateRecurringTransaction(String id) async {
    await _recurringRepository.deactivate(id);
  }

  Future<void> generateDueTransactions(DateTime date) async {
    final dueTransactions = await _recurringRepository.getDueTransactions(date);
    
    for (final recurring in dueTransactions) {
      if (recurring.shouldGenerateTransaction(date)) {
        final transaction = recurring.generateTransaction(date);
        await _transactionRepository.create(transaction);
      }
    }
  }

  Future<void> generateTransactionsForDateRange(DateTime start, DateTime end) async {
    final activeTransactions = await _recurringRepository.getActive();
    
    for (final recurring in activeTransactions) {
      var currentDate = recurring.startDate;
      while (currentDate.isBefore(end)) {
        if (currentDate.isAfter(start) && recurring.shouldGenerateTransaction(currentDate)) {
          final transaction = recurring.generateTransaction(currentDate);
          await _transactionRepository.create(transaction);
        }
        currentDate = recurring.getNextOccurrence(currentDate);
      }
    }
  }

  Future<List<DateTime>> getNextOccurrences(String recurringTransactionId, int count) async {
    final recurring = await _recurringRepository.get(recurringTransactionId);
    if (recurring == null) return [];

    final occurrences = <DateTime>[];
    var currentDate = recurring.startDate;
    
    for (var i = 0; i < count; i++) {
      if (recurring.endDate != null && currentDate.isAfter(recurring.endDate!)) {
        break;
      }
      occurrences.add(currentDate);
      currentDate = recurring.getNextOccurrence(currentDate);
    }

    return occurrences;
  }
} 