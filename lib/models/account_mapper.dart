import 'account.dart';
import 'database_models.dart';

class AccountMapper {
  static Account fromEntity(AccountEntity entity) {
    return Account(
      id: entity.id?.toString(),
      name: entity.name,
      type: 'default', // 默认值，实际应该从数据库中获取
      icon: 'default_icon', // 默认值，实际应该从数据库中获取
      balance: entity.balance,
      createdAt: entity.createdAt != null ? DateTime.parse(entity.createdAt!) : null,
      updatedAt: entity.updatedAt != null ? DateTime.parse(entity.updatedAt!) : null,
    );
  }

  static AccountEntity toEntity(Account account) {
    return AccountEntity(
      id: account.id != null ? int.parse(account.id!) : null,
      name: account.name,
      balance: account.balance,
      createdAt: account.createdAt.toIso8601String(),
      updatedAt: account.updatedAt.toIso8601String(),
    );
  }

  static List<Account> fromEntityList(List<AccountEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }

  static List<AccountEntity> toEntityList(List<Account> accounts) {
    return accounts.map((account) => toEntity(account)).toList();
  }
} 