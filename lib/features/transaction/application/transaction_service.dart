import 'package:uuid/uuid.dart';
import '../domain/transaction.dart';
import '../data/transaction_repository.dart';

class TransactionService {
  final TransactionRepository _repository;
  final _uuid = const Uuid();

  TransactionService(this._repository);

  Future<String> createTransaction({
    required String accountId,
    String? toAccountId,
    required TransactionType type,
    required double amount,
    required String currency,
    String? categoryId,
    List<String> tagIds = const [],
    DateTime? date,
    String? description,
    TransactionStatus status = TransactionStatus.completed,
  }) async {
    final now = DateTime.now();
    final transaction = Transaction(
      id: _uuid.v4(),
      accountId: accountId,
      toAccountId: toAccountId,
      type: type,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      tagIds: tagIds,
      date: date ?? now,
      description: description,
      status: status,
      createdAt: now,
      updatedAt: now,
    );

    return await _repository.create(transaction);
  }

  Future<Transaction?> getTransaction(String id) async {
    return await _repository.get(id);
  }

  Future<List<Transaction>> getAllTransactions() async {
    return await _repository.getAll();
  }

  Future<List<Transaction>> getAccountTransactions(String accountId) async {
    return await _repository.getAllByAccountId(accountId);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final updatedTransaction = transaction.copyWith(
      updatedAt: DateTime.now(),
    );
    await _repository.update(updatedTransaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.delete(id);
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _repository.getByDateRange(start, end);
  }

  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    return await _repository.getByType(type);
  }

  Future<double> calculateAccountBalance(String accountId) async {
    final transactions = await getAccountTransactions(accountId);
    return transactions.fold(0.0, (balance, transaction) {
      if (transaction.type == TransactionType.income) {
        return balance + transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        return balance - transaction.amount;
      } else if (transaction.type == TransactionType.transfer) {
        if (transaction.accountId == accountId) {
          return balance - transaction.amount;
        } else if (transaction.toAccountId == accountId) {
          return balance + transaction.amount;
        }
      }
      return balance;
    });
  }
} 