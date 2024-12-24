import 'account_group.dart';

abstract class AccountGroupRepository {
  Future<List<AccountGroup>> getAccountGroups();
  Future<AccountGroup?> getAccountGroupById(String id);
  Future<AccountGroup> createAccountGroup(AccountGroup group);
  Future<AccountGroup> updateAccountGroup(AccountGroup group);
  Future<void> deleteAccountGroup(String id);
  Future<List<AccountGroup>> getAccountGroupsByAccountId(String accountId);
  Future<void> addAccountToGroup(String groupId, String accountId);
  Future<void> removeAccountFromGroup(String groupId, String accountId);
} 