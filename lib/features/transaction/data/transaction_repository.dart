import 'package:sqflite/sqflite.dart';
import '../domain/transaction.dart';

class TransactionRepository {
  final Database database;

  TransactionRepository(this.database);

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id TEXT PRIMARY KEY,
        accountId TEXT NOT NULL,
        toAccountId TEXT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        categoryId TEXT,
        tagIds TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<String> create(Transaction transaction) async {
    await database.insert('transactions', transaction.toJson());
    return transaction.id;
  }

  Future<Transaction?> get(String id) async {
    final maps = await database.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Transaction.fromJson(maps.first);
  }

  Future<List<Transaction>> getAll() async {
    final maps = await database.query('transactions');
    return maps.map((map) => Transaction.fromJson(map)).toList();
  }

  Future<List<Transaction>> getAllByAccountId(String accountId) async {
    final maps = await database.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    return maps.map((map) => Transaction.fromJson(map)).toList();
  }

  Future<void> update(Transaction transaction) async {
    await database.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    await database.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    final maps = await database.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return maps.map((map) => Transaction.fromJson(map)).toList();
  }

  Future<List<Transaction>> getByType(TransactionType type) async {
    final maps = await database.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.toString()],
    );
    return maps.map((map) => Transaction.fromJson(map)).toList();
  }
} 