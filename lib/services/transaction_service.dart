import '../models/domain/transaction.dart';
import '../models/mappers/transaction_mapper.dart';
import 'database_service.dart';

class TransactionService {
  final DatabaseService _db;

  TransactionService(this._db);

  Future<List<Transaction>> getAllTransactions() async {
    final entities = await _db.getAllTransactions();
    return TransactionMapper.fromEntityList(entities);
  }

  Future<Transaction?> getTransaction(String id) async {
    try {
      final entity = await _db.getTransaction(int.parse(id));
      return entity != null ? TransactionMapper.fromEntity(entity) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> createTransaction(Transaction transaction) async {
    await _db.insertTransaction(TransactionMapper.toEntity(transaction));
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _db.updateTransaction(TransactionMapper.toEntity(transaction));
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(int.parse(id));
  }

  Future<double> getTotalIncome() async {
    final transactions = await getAllTransactions();
    double total = 0.0;
    for (var t in transactions.where((t) => t.amount > 0)) {
      total += t.amount;
    }
    return total;
  }

  Future<double> getTotalExpense() async {
    final transactions = await getAllTransactions();
    double total = 0.0;
    for (var t in transactions.where((t) => t.amount < 0)) {
      total += t.amount.abs();
    }
    return total;
  }
} 