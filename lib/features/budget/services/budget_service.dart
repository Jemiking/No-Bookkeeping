import 'package:sqflite/sqflite.dart';
import '../models/budget.dart';

class BudgetService {
  final Database _db;

  BudgetService(this._db);

  Future<void> createTable() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        spent REAL NOT NULL DEFAULT 0.0,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        currency TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<String> create(Budget budget) async {
    await _db.insert('budgets', budget.toJson());
    return budget.id;
  }

  Future<Budget?> get(String id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Budget.fromJson(maps.first);
  }

  Future<List<Budget>> getAll() async {
    final List<Map<String, dynamic>> maps = await _db.query('budgets');
    return maps.map((map) => Budget.fromJson(map)).toList();
  }

  Future<void> update(Budget budget) async {
    await _db.update(
      'budgets',
      budget.toJson(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSpent(String id, double amount) async {
    await _db.rawUpdate('''
      UPDATE budgets 
      SET spent = spent + ? 
      WHERE id = ?
    ''', [amount, id]);
  }

  Future<List<Budget>> getActiveBudgets() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'budgets',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Budget.fromJson(map)).toList();
  }
} 