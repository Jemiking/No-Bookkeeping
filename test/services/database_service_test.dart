import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../lib/services/database_service.dart';
import '../../lib/models/database_models.dart';

void main() {
  late DatabaseService db;

  setUpAll(() {
    // 初始化 FFI
    sqfliteFfiInit();
    // 设置数据库工厂
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = DatabaseService();
    // 确保数据库已初始化
    await db.database;
  });

  tearDown(() async {
    await db.close();
  });

  group('DatabaseService Tests', () {
    test('插入和查询账户', () async {
      final account = Account(
        name: 'Test Account',
        type: 'savings',
        balance: 1000.0,
        currency: 'CNY',
      );

      final id = await db.insert(account);
      expect(id, isPositive);

      final result = await db.queryById('accounts', id);
      expect(result, isNotNull);
      expect(result!['name'], equals('Test Account'));
    });

    test('更新账户', () async {
      final account = Account(
        name: 'Test Account',
        type: 'savings',
        balance: 1000.0,
        currency: 'CNY',
      );

      final id = await db.insert(account);
      final updatedAccount = Account(
        id: id,
        name: 'Updated Account',
        type: 'savings',
        balance: 2000.0,
        currency: 'CNY',
      );

      final updateCount = await db.update(updatedAccount, id);
      expect(updateCount, equals(1));

      final result = await db.queryById('accounts', id);
      expect(result!['name'], equals('Updated Account'));
      expect(result['balance'], equals(2000.0));
    });

    test('删除账户', () async {
      final account = Account(
        name: 'Test Account',
        type: 'savings',
        balance: 1000.0,
        currency: 'CNY',
      );

      final id = await db.insert(account);
      final deleteCount = await db.delete('accounts', id);
      expect(deleteCount, equals(1));

      final result = await db.queryById('accounts', id);
      expect(result, isNull);
    });

    test('查询所有账户', () async {
      final accounts = [
        Account(
          name: 'Account 1',
          type: 'savings',
          balance: 1000.0,
          currency: 'CNY',
        ),
        Account(
          name: 'Account 2',
          type: 'checking',
          balance: 2000.0,
          currency: 'CNY',
        ),
      ];

      for (final account in accounts) {
        await db.insert(account);
      }

      final results = await db.queryAll('accounts');
      expect(results.length, equals(2));
    });

    test('条件查询账户', () async {
      final accounts = [
        Account(
          name: 'Savings 1',
          type: 'savings',
          balance: 1000.0,
          currency: 'CNY',
        ),
        Account(
          name: 'Checking 1',
          type: 'checking',
          balance: 2000.0,
          currency: 'CNY',
        ),
      ];

      for (final account in accounts) {
        await db.insert(account);
      }

      final results = await db.queryWhere(
        'accounts',
        where: 'type = ?',
        whereArgs: ['savings'],
      );
      expect(results.length, equals(1));
      expect(results.first['name'], equals('Savings 1'));
    });

    test('批量插入账户', () async {
      final accounts = [
        Account(
          name: 'Account 1',
          type: 'savings',
          balance: 1000.0,
          currency: 'CNY',
        ),
        Account(
          name: 'Account 2',
          type: 'checking',
          balance: 2000.0,
          currency: 'CNY',
        ),
      ].map((a) => a.toMap()).toList();

      final results = await db.batchInsert('accounts', accounts);
      expect(results.length, equals(2));
      expect(results.every((id) => id > 0), isTrue);
    });

    test('批量更新账户', () async {
      final accounts = [
        Account(
          name: 'Account 1',
          type: 'savings',
          balance: 1000.0,
          currency: 'CNY',
        ),
        Account(
          name: 'Account 2',
          type: 'checking',
          balance: 2000.0,
          currency: 'CNY',
        ),
      ];

      final ids = await Future.wait(
        accounts.map((a) => db.insert(a)),
      );

      final updates = accounts.map((a) => a.copyWith(
        balance: a.balance + 1000.0,
      ).toMap()).toList();

      final results = await db.batchUpdate(
        'accounts',
        updates,
        'id = ?',
        (map) => map['id'].toString(),
      );

      expect(results.length, equals(2));
      
      for (final id in ids) {
        final account = await db.queryById('accounts', id);
        expect(account!['balance'], greaterThan(1000.0));
      }
    });

    test('批量删除账户', () async {
      final accounts = [
        Account(
          name: 'Account 1',
          type: 'savings',
          balance: 1000.0,
          currency: 'CNY',
        ),
        Account(
          name: 'Account 2',
          type: 'checking',
          balance: 2000.0,
          currency: 'CNY',
        ),
      ];

      final ids = await Future.wait(
        accounts.map((a) => db.insert(a)),
      );

      final results = await db.batchDelete('accounts', ids);
      expect(results.length, equals(2));

      final remainingAccounts = await db.queryAll('accounts');
      expect(remainingAccounts.length, equals(0));
    });

    test('事务操作', () async {
      await db.transaction((txn) async {
        final account = Account(
          name: 'Transaction Test',
          type: 'savings',
          balance: 1000.0,
          currency: 'CNY',
        );

        final id = await txn.insert('accounts', account.toMap());
        expect(id, isPositive);

        final result = await txn.query(
          'accounts',
          where: 'id = ?',
          whereArgs: [id],
        );
        expect(result.length, equals(1));
        expect(result.first['name'], equals('Transaction Test'));
      });
    });
  });
} 