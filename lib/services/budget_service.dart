import 'package:money_tracker/models/domain/budget.dart';
import 'package:money_tracker/models/mappers/budget_mapper.dart';
import 'package:money_tracker/services/database_service.dart';

class BudgetService {
  final DatabaseService _db;

  BudgetService(this._db);

  Future<List<Budget>> getAllBudgets() async {
    final entities = await _db.getAllBudgets();
    return BudgetMapper.fromEntityList(entities);
  }

  Future<Budget?> getBudget(String id) async {
    try {
      final entity = await _db.getBudget(int.parse(id));
      return entity != null ? BudgetMapper.fromEntity(entity) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> createBudget(Budget budget) async {
    await _db.insertBudget(BudgetMapper.toEntity(budget));
  }

  Future<void> updateBudget(Budget budget) async {
    await _db.updateBudget(BudgetMapper.toEntity(budget));
  }

  Future<void> deleteBudget(String id) async {
    await _db.deleteBudget(int.parse(id));
  }

  Future<double> getTotalBudget() async {
    final budgets = await getAllBudgets();
    double total = 0.0;
    for (var budget in budgets) {
      total += budget.amount;
    }
    return total;
  }

  Future<Map<String, double>> getBudgetUtilization() async {
    final budgets = await getAllBudgets();
    final Map<String, double> utilization = {};
    
    for (final budget in budgets) {
      // TODO: 计算每个预算的使用率
      utilization[budget.name] = 0.0;
    }
    
    return utilization;
  }
} 