import 'account.dart';

abstract class AccountRepository {
  Future<List<Account>> getAccounts();
  Future<Account?> getAccountById(String id);
  Future<Account> createAccount(Account account);
  Future<Account> updateAccount(Account account);
  Future<void> deleteAccount(String id);
  Future<void> archiveAccount(String id);
  Future<double> getAccountBalance(String id);
  Future<List<Account>> getAccountsByType(AccountType type);
  Future<List<Account>> getAccountsByStatus(AccountStatus status);
} 