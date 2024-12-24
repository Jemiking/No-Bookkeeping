import 'package:sqflite/sqflite.dart';
import '../models/periodic_budget.dart';
import '../utils/database_helper.dart';

class PeriodicBudgetService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS periodic_budgets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        startDate TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        categoryId TEXT,
        spent REAL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');
  }

  Future<String> create(PeriodicBudget budget) async {
    final db = await _dbHelper.database;
    await db.insert('periodic_budgets', budget.toJson());
    return budget.id;
  }

  Future<PeriodicBudget?> get(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'periodic_budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PeriodicBudget.fromJson(maps.first);
  }

  Future<List<PeriodicBudget>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('periodic_budgets');
    return List.generate(maps.length, (i) => PeriodicBudget.fromJson(maps[i]));
  }

  Future<List<PeriodicBudget>> getActive() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'periodic_budgets',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => PeriodicBudget.fromJson(maps[i]));
  }

  Future<List<PeriodicBudget>> getByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'periodic_budgets',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => PeriodicBudget.fromJson(maps[i]));
  }

  Future<void> update(PeriodicBudget budget) async {
    final db = await _dbHelper.database;
    await db.update(
      'periodic_budgets',
      budget.toJson(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'periodic_budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSpentAmount(String id, double amount) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE periodic_budgets 
      SET spent = spent + ? 
      WHERE id = ?
    ''', [amount, id]);
  }

  Future<void> resetSpentAmount(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'periodic_budgets',
      {'spent': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deactivate(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'periodic_budgets',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> activate(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'periodic_budgets',
      {'isActive': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 