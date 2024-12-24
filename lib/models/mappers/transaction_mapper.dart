import '../domain/transaction.dart';
import '../database_models.dart';

/// 交易模型映射器
class TransactionMapper {
  /// 将实体模型转换为业务模型
  static Transaction fromEntity(TransactionEntity entity) {
    return Transaction(
      id: entity.id?.toString(),
      accountId: entity.accountId.toString(),
      categoryId: entity.categoryId.toString(),
      amount: entity.amount,
      type: entity.type,
      date: DateTime.parse(entity.date),
      note: entity.description,
      createdAt: entity.createdAt != null 
          ? DateTime.parse(entity.createdAt!)
          : null,
      updatedAt: entity.updatedAt != null
          ? DateTime.parse(entity.updatedAt!)
          : null,
    );
  }

  /// 将业务模型转换为实体模型
  static TransactionEntity toEntity(Transaction model) {
    return TransactionEntity(
      id: model.id != null ? int.parse(model.id!) : null,
      accountId: int.parse(model.accountId),
      categoryId: int.parse(model.categoryId),
      amount: model.amount,
      type: model.type,
      date: model.date.toIso8601String(),
      description: model.note,
      createdAt: model.createdAt?.toIso8601String(),
      updatedAt: model.updatedAt?.toIso8601String(),
    );
  }

  /// 将实体模型列表转换为业务模型列表
  static List<Transaction> fromEntityList(List<TransactionEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }

  /// 将业务模型列表转换为实体模型列表
  static List<TransactionEntity> toEntityList(List<Transaction> models) {
    return models.map((model) => toEntity(model)).toList();
  }
} 