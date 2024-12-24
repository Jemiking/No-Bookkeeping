import 'package:sqflite/sqflite.dart';
import '../domain/installment_transaction.dart';

class InstallmentTransactionRepository {
  final Database database;

  InstallmentTransactionRepository(this.database);

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS installment_transactions (
        id TEXT PRIMARY KEY,
        accountId TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        currency TEXT NOT NULL,
        totalInstallments INTEGER NOT NULL,
        remainingInstallments INTEGER NOT NULL,
        installmentAmount REAL NOT NULL,
        startDate TEXT NOT NULL,
        description TEXT NOT NULL,
        categoryId TEXT,
        tagIds TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');
  }

  Future<String> create(InstallmentTransaction transaction) async {
    await database.insert('installment_transactions', transaction.toJson());
    return transaction.id;
  }

  Future<InstallmentTransaction?> get(String id) async {
    final maps = await database.query(
      'installment_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return InstallmentTransaction.fromJson(maps.first);
  }

  Future<List<InstallmentTransaction>> getAll() async {
    final maps = await database.query('installment_transactions');
    return maps.map((map) => InstallmentTransaction.fromJson(map)).toList();
  }

  Future<List<InstallmentTransaction>> getAllByAccountId(String accountId) async {
    final maps = await database.query(
      'installment_transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    return maps.map((map) => InstallmentTransaction.fromJson(map)).toList();
  }

  Future<List<InstallmentTransaction>> getActive() async {
    final maps = await database.query(
      'installment_transactions',
      where: 'isActive = ? AND remainingInstallments > 0',
      whereArgs: [1],
    );
    return maps.map((map) => InstallmentTransaction.fromJson(map)).toList();
  }

  Future<void> update(InstallmentTransaction transaction) async {
    await database.update(
      'installment_transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    await database.delete(
      'installment_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deactivate(String id) async {
    await database.update(
      'installment_transactions',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> decrementRemainingInstallments(String id) async {
    final transaction = await get(id);
    if (transaction != null && transaction.remainingInstallments > 0) {
      final updatedTransaction = transaction.copyWith(
        remainingInstallments: transaction.remainingInstallments - 1,
        updatedAt: DateTime.now(),
      );
      await update(updatedTransaction);
    }
  }

  Future<List<InstallmentTransaction>> getDueInstallments(DateTime date) async {
    final maps = await database.query(
      'installment_transactions',
      where: 'isActive = ? AND remainingInstallments > 0 AND startDate <= ?',
      whereArgs: [1, date.toIso8601String()],
    );
    return maps.map((map) => InstallmentTransaction.fromJson(map)).toList();
  }
} 