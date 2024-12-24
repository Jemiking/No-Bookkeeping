import 'package:sqflite/sqflite.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final Database database;

  AccountRepositoryImpl(this.database);

  static const String tableName = 'accounts';

  @override
  Future<List<Account>> getAccounts() async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    return List.generate(maps.length, (i) => Account.fromJson(maps[i]));
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Account.fromJson(maps.first);
  }

  @override
  Future<Account> createAccount(Account account) async {
    final id = await database.insert(
      tableName,
      account.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return account;
  }

  @override
  Future<Account> updateAccount(Account account) async {
    await database.update(
      tableName,
      account.toJson(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
    return account;
  }

  @override
  Future<void> deleteAccount(String id) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> archiveAccount(String id) async {
    await database.update(
      tableName,
      {'status': AccountStatus.archived.toString()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<double> getAccountBalance(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      columns: ['balance'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) throw Exception('Account not found');
    return maps.first['balance'] as double;
  }

  @override
  Future<List<Account>> getAccountsByType(AccountType type) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'type = ?',
      whereArgs: [type.toString()],
    );
    return List.generate(maps.length, (i) => Account.fromJson(maps[i]));
  }

  @override
  Future<List<Account>> getAccountsByStatus(AccountStatus status) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'status = ?',
      whereArgs: [status.toString()],
    );
    return List.generate(maps.length, (i) => Account.fromJson(maps[i]));
  }
} 