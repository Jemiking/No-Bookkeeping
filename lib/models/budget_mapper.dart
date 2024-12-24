import 'budget.dart';
import 'database_models.dart';

class BudgetMapper {
  static Budget fromEntity(BudgetEntity entity) {
    return Budget(
      id: entity.id?.toString(),
      name: entity.name,
      amount: entity.amount,
      createdAt: entity.createdAt != null ? DateTime.parse(entity.createdAt!) : null,
      updatedAt: entity.updatedAt != null ? DateTime.parse(entity.updatedAt!) : null,
    );
  }

  static BudgetEntity toEntity(Budget budget) {
    return BudgetEntity(
      id: budget.id != null ? int.parse(budget.id!) : null,
      name: budget.name,
      amount: budget.amount,
      createdAt: budget.createdAt.toIso8601String(),
      updatedAt: budget.updatedAt.toIso8601String(),
    );
  }

  static List<Budget> fromEntityList(List<BudgetEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }

  static List<BudgetEntity> toEntityList(List<Budget> budgets) {
    return budgets.map((budget) => toEntity(budget)).toList();
  }
} 