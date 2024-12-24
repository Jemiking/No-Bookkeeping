import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/core/exceptions/app_exceptions.dart';
import 'package:money_tracker/models/domain/transaction.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:money_tracker/services/transaction_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  late DatabaseService databaseService;
  late TransactionService transactionService;
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // 创建测试数据库
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'test_transactions.db');
    
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // 创建必要的表
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account_id INTEGER NOT NULL,
            category_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            note TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            balance REAL NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL
          )
        ''');

        // 插入测试数据
        await db.insert('accounts', {'id': 1, 'name': 'Test Account', 'balance': 1000.0});
        await db.insert('categories', {'id': 1, 'name': 'Test Category', 'type': 'expense'});
      },
    );

    databaseService = DatabaseService();
    transactionService = TransactionService(databaseService);
  });

  tearDown(() async {
    await db.close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'test_transactions.db');
    await deleteDatabase(path);
  });

  group('TransactionService CRUD operations', () {
    test('should create transaction successfully', () async {
      final transaction = Transaction(
        accountId: '1',
        categoryId: '1',
        amount: 100.0,
        type: 'expense',
        date: DateTime.now(),
        note: 'Test transaction',
      );

      await transactionService.createTransaction(transaction);
      final transactions = await transactionService.getAllTransactions();
      
      expect(transactions.length, 1);
      expect(transactions.first.amount, 100.0);
      expect(transactions.first.note, 'Test transaction');
    });

    test('should get transaction by id', () async {
      final transaction = Transaction(
        accountId: '1',
        categoryId: '1',
        amount: 100.0,
        type: 'expense',
        date: DateTime.now(),
        note: 'Test transaction',
      );

      await transactionService.createTransaction(transaction);
      final transactions = await transactionService.getAllTransactions();
      final id = transactions.first.id!;

      final retrieved = await transactionService.getTransaction(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.amount, 100.0);
      expect(retrieved.note, 'Test transaction');
    });

    test('should update transaction', () async {
      final transaction = Transaction(
        accountId: '1',
        categoryId: '1',
        amount: 100.0,
        type: 'expense',
        date: DateTime.now(),
        note: 'Test transaction',
      );

      await transactionService.createTransaction(transaction);
      final transactions = await transactionService.getAllTransactions();
      final id = transactions.first.id!;

      final updated = Transaction(
        id: id,
        accountId: '1',
        categoryId: '1',
        amount: 200.0,
        type: 'expense',
        date: DateTime.now(),
        note: 'Updated transaction',
      );

      await transactionService.updateTransaction(updated);
      final retrieved = await transactionService.getTransaction(id);
      
      expect(retrieved!.amount, 200.0);
      expect(retrieved.note, 'Updated transaction');
    });

    test('should delete transaction', () async {
      final transaction = Transaction(
        accountId: '1',
        categoryId: '1',
        amount: 100.0,
        type: 'expense',
        date: DateTime.now(),
        note: 'Test transaction',
      );

      await transactionService.createTransaction(transaction);
      final transactions = await transactionService.getAllTransactions();
      final id = transactions.first.id!;

      await transactionService.deleteTransaction(id);
      final afterDelete = await transactionService.getAllTransactions();
      
      expect(afterDelete.isEmpty, true);
    });
  });

  group('TransactionService calculations', () {
    setUp(() async {
      // 添加测试数据
      final transactions = [
        Transaction(
          accountId: '1',
          categoryId: '1',
          amount: 100.0,
          type: 'expense',
          date: DateTime.now(),
          note: 'Expense 1',
        ),
        Transaction(
          accountId: '1',
          categoryId: '1',
          amount: 200.0,
          type: 'expense',
          date: DateTime.now(),
          note: 'Expense 2',
        ),
        Transaction(
          accountId: '1',
          categoryId: '1',
          amount: 300.0,
          type: 'income',
          date: DateTime.now(),
          note: 'Income 1',
        ),
      ];

      for (var transaction in transactions) {
        await transactionService.createTransaction(transaction);
      }
    });

    test('should calculate total expense correctly', () async {
      final totalExpense = await transactionService.getTotalExpense();
      expect(totalExpense, 300.0);
    });

    test('should calculate total income correctly', () async {
      final totalIncome = await transactionService.getTotalIncome();
      expect(totalIncome, 300.0);
    });

    test('should calculate expense by category correctly', () async {
      final expenseByCategory = await transactionService.getExpenseByCategory();
      expect(expenseByCategory['1'], 300.0);
    });

    test('should calculate income by category correctly', () async {
      final incomeByCategory = await transactionService.getIncomeByCategory();
      expect(incomeByCategory['1'], 300.0);
    });
  });

  group('TransactionService error handling', () {
    test('should handle invalid transaction ID format', () async {
      expect(
        () => transactionService.getTransaction('invalid_id'),
        throwsA(isA<TransactionException>()),
      );
    });

    test('should handle non-existent transaction', () async {
      final result = await transactionService.getTransaction('999');
      expect(result, isNull);
    });

    test('should handle database errors gracefully', () async {
      // 关闭数据库连接以模拟错误
      await db.close();
      
      expect(
        () => transactionService.getAllTransactions(),
        throwsA(isA<TransactionException>()),
      );
    });
  });
} 