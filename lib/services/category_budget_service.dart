import 'package:sqflite/sqflite.dart';
import '../models/category_budget.dart';
import '../utils/database_helper.dart';

class CategoryBudgetService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS category_budgets (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        amount REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        notes TEXT,
        spent REAL DEFAULT 0,
        remaining REAL DEFAULT 0,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');
  }

  Future<String> create(CategoryBudget budget) async {
    final db = await _dbHelper.database;
    await db.insert('category_budgets', budget.toJson());
    return budget.id;
  }

  Future<CategoryBudget?> get(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'category_budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CategoryBudget.fromJson(maps.first);
  }

  Future<List<CategoryBudget>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('category_budgets');
    return List.generate(maps.length, (i) => CategoryBudget.fromJson(maps[i]));
  }

  Future<List<CategoryBudget>> getByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'category_budgets',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => CategoryBudget.fromJson(maps[i]));
  }

  Future<void> update(CategoryBudget budget) async {
    final db = await _dbHelper.database;
    await db.update(
      'category_budgets',
      budget.toJson(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'category_budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSpentAmount(String id, double spent) async {
    final db = await _dbHelper.database;
    final budget = await get(id);
    if (budget != null) {
      final remaining = budget.amount - spent;
      await db.update(
        'category_budgets',
        {
          'spent': spent,
          'remaining': remaining,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
} 