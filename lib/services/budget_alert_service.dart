import 'package:sqflite/sqflite.dart';
import '../utils/database_helper.dart';
import '../models/budget.dart';
import '../models/category_budget.dart';
import '../models/periodic_budget.dart';

class BudgetAlert {
  final String id;
  final String budgetId;
  final String budgetType; // 'general', 'category', 'periodic'
  final double threshold; // 百分比，例如80表示达到预算的80%时提醒
  final bool isEnabled;
  final String? message;

  BudgetAlert({
    required this.id,
    required this.budgetId,
    required this.budgetType,
    required this.threshold,
    this.isEnabled = true,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetId': budgetId,
      'budgetType': budgetType,
      'threshold': threshold,
      'isEnabled': isEnabled ? 1 : 0,
      'message': message,
    };
  }

  factory BudgetAlert.fromJson(Map<String, dynamic> json) {
    return BudgetAlert(
      id: json['id'],
      budgetId: json['budgetId'],
      budgetType: json['budgetType'],
      threshold: json['threshold'],
      isEnabled: json['isEnabled'] == 1,
      message: json['message'],
    );
  }
}

class BudgetAlertService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budget_alerts (
        id TEXT PRIMARY KEY,
        budgetId TEXT NOT NULL,
        budgetType TEXT NOT NULL,
        threshold REAL NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        message TEXT,
        FOREIGN KEY (budgetId) REFERENCES budgets (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<String> create(BudgetAlert alert) async {
    final db = await _dbHelper.database;
    await db.insert('budget_alerts', alert.toJson());
    return alert.id;
  }

  Future<BudgetAlert?> get(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budget_alerts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return BudgetAlert.fromJson(maps.first);
  }

  Future<List<BudgetAlert>> getByBudget(String budgetId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budget_alerts',
      where: 'budgetId = ?',
      whereArgs: [budgetId],
    );
    return List.generate(maps.length, (i) => BudgetAlert.fromJson(maps[i]));
  }

  Future<List<BudgetAlert>> getActive() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budget_alerts',
      where: 'isEnabled = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => BudgetAlert.fromJson(maps[i]));
  }

  Future<void> update(BudgetAlert alert) async {
    final db = await _dbHelper.database;
    await db.update(
      'budget_alerts',
      alert.toJson(),
      where: 'id = ?',
      whereArgs: [alert.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'budget_alerts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleAlert(String id, bool isEnabled) async {
    final db = await _dbHelper.database;
    await db.update(
      'budget_alerts',
      {'isEnabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BudgetAlert>> checkBudgetAlerts(String budgetId, String budgetType, double progress) async {
    final alerts = await getByBudget(budgetId);
    return alerts.where((alert) => 
      alert.isEnabled && 
      alert.budgetType == budgetType && 
      progress >= alert.threshold
    ).toList();
  }

  Future<void> deleteForBudget(String budgetId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'budget_alerts',
      where: 'budgetId = ?',
      whereArgs: [budgetId],
    );
  }
} 