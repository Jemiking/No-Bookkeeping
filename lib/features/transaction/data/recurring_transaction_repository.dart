import 'package:sqflite/sqflite.dart';
import '../domain/recurring_transaction.dart';

class RecurringTransactionRepository {
  final Database database;

  RecurringTransactionRepository(this.database);

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS recurring_transactions (
        id TEXT PRIMARY KEY,
        accountId TEXT NOT NULL,
        toAccountId TEXT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        categoryId TEXT,
        tagIds TEXT NOT NULL,
        description TEXT NOT NULL,
        period TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        repeatCount INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');
  }

  Future<String> create(RecurringTransaction transaction) async {
    await database.insert('recurring_transactions', transaction.toJson());
    return transaction.id;
  }

  Future<RecurringTransaction?> get(String id) async {
    final maps = await database.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return RecurringTransaction.fromJson(maps.first);
  }

  Future<List<RecurringTransaction>> getAll() async {
    final maps = await database.query('recurring_transactions');
    return maps.map((map) => RecurringTransaction.fromJson(map)).toList();
  }

  Future<List<RecurringTransaction>> getAllByAccountId(String accountId) async {
    final maps = await database.query(
      'recurring_transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    return maps.map((map) => RecurringTransaction.fromJson(map)).toList();
  }

  Future<List<RecurringTransaction>> getActive() async {
    final maps = await database.query(
      'recurring_transactions',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return maps.map((map) => RecurringTransaction.fromJson(map)).toList();
  }

  Future<void> update(RecurringTransaction transaction) async {
    await database.update(
      'recurring_transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    await database.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deactivate(String id) async {
    await database.update(
      'recurring_transactions',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<RecurringTransaction>> getDueTransactions(DateTime date) async {
    final maps = await database.query(
      'recurring_transactions',
      where: 'isActive = ? AND startDate <= ? AND (endDate IS NULL OR endDate >= ?)',
      whereArgs: [1, date.toIso8601String(), date.toIso8601String()],
    );
    return maps.map((map) => RecurringTransaction.fromJson(map)).toList();
  }
} 