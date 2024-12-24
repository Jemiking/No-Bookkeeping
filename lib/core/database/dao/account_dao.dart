import 'package:sqflite/sqflite.dart';
import '../database_provider.dart';
import '../models/account.dart';

/// 账户数据访问对象类
class AccountDao {
  /// 数据库提供者
  final DatabaseProvider _provider;

  /// 表名
  static const String table = 'accounts';

  /// 构造函数
  AccountDao(this._provider);

  /// 插入账户
  Future<int> insert(Account account) async {
    final db = await _provider.database;
    return await db.insert(
      table,
      account.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新账户
  Future<int> update(Account account) async {
    final db = await _provider.database;
    return await db.update(
      table,
      account.toJson(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  /// 删除账户
  Future<int> delete(int id) async {
    final db = await _provider.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取账户
  Future<Account?> get(int id) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Account.fromJson(maps.first);
  }

  /// 获取所有账户
  Future<List<Account>> getAll() async {
    final db = await _provider.database;
    final maps = await db.query(table);
    return maps.map((map) => Account.fromJson(map)).toList();
  }

  /// 获取活跃账户
  Future<List<Account>> getActive() async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'status = ?',
      whereArgs: [AccountStatus.active.index],
    );
    return maps.map((map) => Account.fromJson(map)).toList();
  }

  /// 获取已归档账户
  Future<List<Account>> getArchived() async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'status = ?',
      whereArgs: [AccountStatus.archived.index],
    );
    return maps.map((map) => Account.fromJson(map)).toList();
  }

  /// 获取已删除账户
  Future<List<Account>> getDeleted() async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'status = ?',
      whereArgs: [AccountStatus.deleted.index],
    );
    return maps.map((map) => Account.fromJson(map)).toList();
  }

  /// 按类型获取账户
  Future<List<Account>> getByType(AccountType type) async {
    final db = await _provider.database;
    final maps = await db.query(
      table,
      where: 'type = ? AND status = ?',
      whereArgs: [type.index, AccountStatus.active.index],
    );
    return maps.map((map) => Account.fromJson(map)).toList();
  }

  /// 更新账户余额
  Future<void> updateBalance(int id, double newBalance) async {
    await _provider.transaction((txn) async {
      await txn.update(
        table,
        {'current_balance': newBalance, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  /// 批量更新账户状态
  Future<void> updateStatus(List<int> ids, AccountStatus status) async {
    final db = await _provider.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final id in ids) {
        batch.update(
          table,
          {
            'status': status.index,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      await batch.commit();
    });
  }

  /// 获取账户总数
  Future<int> count() async {
    final db = await _provider.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取活跃账户总数
  Future<int> countActive() async {
    final db = await _provider.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table WHERE status = ?',
      [AccountStatus.active.index],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取账户总余额
  Future<double> getTotalBalance() async {
    final db = await _provider.database;
    final result = await db.rawQuery(
      'SELECT SUM(current_balance) as total FROM $table WHERE status = ?',
      [AccountStatus.active.index],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// 按货币获取账户总余额
  Future<Map<String, double>> getTotalBalanceByCurrency() async {
    final db = await _provider.database;
    final result = await db.rawQuery('''
      SELECT currency_code, SUM(current_balance) as total 
      FROM $table 
      WHERE status = ? 
      GROUP BY currency_code
    ''', [AccountStatus.active.index]);

    final balances = <String, double>{};
    for (final row in result) {
      final currencyCode = row['currency_code'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      balances[currencyCode] = total;
    }
    return balances;
  }

  /// 检查账户名是否存在
  Future<bool> isNameExists(String name, {int? excludeId}) async {
    final db = await _provider.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table WHERE name = ? AND id != ?',
      [name, excludeId ?? -1],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
} 