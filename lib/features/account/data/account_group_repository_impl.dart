import 'package:sqflite/sqflite.dart';
import '../domain/account_group.dart';
import '../domain/account_group_repository.dart';

class AccountGroupRepositoryImpl implements AccountGroupRepository {
  final Database database;

  AccountGroupRepositoryImpl(this.database);

  static const String tableName = 'account_groups';
  static const String accountGroupMappingTable = 'account_group_mappings';

  @override
  Future<List<AccountGroup>> getAccountGroups() async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    final List<AccountGroup> groups = [];
    
    for (final map in maps) {
      final accountIds = await _getAccountIdsForGroup(map['id']);
      groups.add(
        AccountGroup.fromJson({
          ...map,
          'accountIds': accountIds,
        }),
      );
    }
    
    return groups;
  }

  @override
  Future<AccountGroup?> getAccountGroupById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    final accountIds = await _getAccountIdsForGroup(id);
    return AccountGroup.fromJson({
      ...maps.first,
      'accountIds': accountIds,
    });
  }

  @override
  Future<AccountGroup> createAccountGroup(AccountGroup group) async {
    await database.transaction((txn) async {
      // Insert group
      await txn.insert(
        tableName,
        {
          'id': group.id,
          'name': group.name,
          'description': group.description,
          'createdAt': group.createdAt.toIso8601String(),
          'updatedAt': group.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert account mappings
      for (final accountId in group.accountIds) {
        await txn.insert(
          accountGroupMappingTable,
          {
            'groupId': group.id,
            'accountId': accountId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    return group;
  }

  @override
  Future<AccountGroup> updateAccountGroup(AccountGroup group) async {
    await database.transaction((txn) async {
      // Update group
      await txn.update(
        tableName,
        {
          'name': group.name,
          'description': group.description,
          'updatedAt': group.updatedAt.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [group.id],
      );

      // Delete old mappings
      await txn.delete(
        accountGroupMappingTable,
        where: 'groupId = ?',
        whereArgs: [group.id],
      );

      // Insert new mappings
      for (final accountId in group.accountIds) {
        await txn.insert(
          accountGroupMappingTable,
          {
            'groupId': group.id,
            'accountId': accountId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    return group;
  }

  @override
  Future<void> deleteAccountGroup(String id) async {
    await database.transaction((txn) async {
      await txn.delete(
        accountGroupMappingTable,
        where: 'groupId = ?',
        whereArgs: [id],
      );
      
      await txn.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<List<AccountGroup>> getAccountGroupsByAccountId(String accountId) async {
    final List<Map<String, dynamic>> maps = await database.rawQuery('''
      SELECT g.* 
      FROM $tableName g
      INNER JOIN $accountGroupMappingTable m ON m.groupId = g.id
      WHERE m.accountId = ?
    ''', [accountId]);

    final List<AccountGroup> groups = [];
    for (final map in maps) {
      final accountIds = await _getAccountIdsForGroup(map['id']);
      groups.add(
        AccountGroup.fromJson({
          ...map,
          'accountIds': accountIds,
        }),
      );
    }
    
    return groups;
  }

  @override
  Future<void> addAccountToGroup(String groupId, String accountId) async {
    await database.insert(
      accountGroupMappingTable,
      {
        'groupId': groupId,
        'accountId': accountId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeAccountFromGroup(String groupId, String accountId) async {
    await database.delete(
      accountGroupMappingTable,
      where: 'groupId = ? AND accountId = ?',
      whereArgs: [groupId, accountId],
    );
  }

  Future<List<String>> _getAccountIdsForGroup(String groupId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      accountGroupMappingTable,
      columns: ['accountId'],
      where: 'groupId = ?',
      whereArgs: [groupId],
    );
    
    return maps.map((map) => map['accountId'] as String).toList();
  }
} 