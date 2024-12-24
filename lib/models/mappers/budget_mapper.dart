import '../domain/budget.dart';
import '../entities/budget.dart';

/// 预算模型映射器
class BudgetMapper {
  /// 将实体模型转换为业务模型
  static Budget fromEntity(BudgetEntity entity) {
    return Budget(
      id: entity.id?.toString(),
      name: entity.name,
      amount: entity.amount,
      createdAt: entity.createdAt != null 
          ? DateTime.parse(entity.createdAt!)
          : null,
      updatedAt: entity.updatedAt != null
          ? DateTime.parse(entity.updatedAt!)
          : null,
    );
  }

  /// 将业务模型转换为实体模型
  static BudgetEntity toEntity(Budget model) {
    return BudgetEntity(
      id: model.id != null ? int.parse(model.id!) : null,
      name: model.name,
      amount: model.amount,
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt.toIso8601String(),
    );
  }

  /// 将实体模型列表转换为业务模型列表
  static List<Budget> fromEntityList(List<BudgetEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }

  /// 将业务模型列表转换为实体模型列表
  static List<BudgetEntity> toEntityList(List<Budget> models) {
    return models.map((model) => toEntity(model)).toList();
  }
} 