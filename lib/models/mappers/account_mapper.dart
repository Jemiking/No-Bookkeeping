import '../domain/account.dart';
import '../database_models.dart';

/// 账户模型映射器
class AccountMapper {
  /// 将实体模型转换为业务模型
  static Account fromEntity(AccountEntity entity) {
    return Account(
      id: entity.id?.toString(),
      name: entity.name,
      type: 'default', // 从实体扩展的字段
      icon: 'default_icon', // 从实体扩展的字段
      balance: entity.balance,
      note: null, // 从实体扩展的字段
      createdAt: entity.createdAt != null 
          ? DateTime.parse(entity.createdAt!)
          : null,
      updatedAt: entity.updatedAt != null
          ? DateTime.parse(entity.updatedAt!)
          : null,
    );
  }

  /// 将业务模型转换为实体模型
  static AccountEntity toEntity(Account model) {
    return AccountEntity(
      id: model.id != null ? int.parse(model.id!) : null,
      name: model.name,
      balance: model.balance,
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt.toIso8601String(),
    );
  }

  /// 将实体模型列表转换为业务模型列表
  static List<Account> fromEntityList(List<AccountEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }

  /// 将业务模型列表转换为实体模型列表
  static List<AccountEntity> toEntityList(List<Account> models) {
    return models.map((model) => toEntity(model)).toList();
  }
} 