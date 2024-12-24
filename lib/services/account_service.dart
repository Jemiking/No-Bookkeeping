import '../models/domain/account.dart';
import '../models/mappers/account_mapper.dart';
import 'database_service.dart';

class AccountService {
  final DatabaseService _db;

  AccountService(this._db);

  Future<List<Account>> getAllAccounts() async {
    final entities = await _db.getAllAccounts();
    return AccountMapper.fromEntityList(entities);
  }

  Future<Account?> getAccount(String id) async {
    try {
      final entity = await _db.getAccount(int.parse(id));
      return entity != null ? AccountMapper.fromEntity(entity) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> createAccount(Account account) async {
    await _db.insertAccount(AccountMapper.toEntity(account));
  }

  Future<void> updateAccount(Account account) async {
    await _db.updateAccount(AccountMapper.toEntity(account));
  }

  Future<void> deleteAccount(String id) async {
    await _db.deleteAccount(int.parse(id));
  }
} 