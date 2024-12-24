import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:money_tracker/database/migrations/001_update_transactions_table.dart';

void main() {
  late Database db;

  setUpAll(() {
    // 初始化 FFI
    sqfliteFfiInit();
    // 设置数据库工厂
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // 创建测试数据库
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'test_migration.db');
    
    // 创建旧版本的数据库结构
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account_id INTEGER NOT NULL,
            category_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            description TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );

    // 插入测试数据
    await db.insert('transactions', {
      'account_id': 1,
      'category_id': 1,
      'amount': 100.0,
      'type': 'expense',
      'date': '2023-01-01',
      'description': 'Test description',
      'created_at': '2023-01-01T00:00:00.000Z',
      'updated_at': '2023-01-01T00:00:00.000Z',
    });
  });

  tearDown(() async {
    await db.close();
    // 删除测试数据库
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'test_migration.db');
    await deleteDatabase(path);
  });

  test('Migration should rename description to note', () async {
    // 执行迁移
    await UpdateTransactionsTableMigration.up(db);

    // 验证数据迁移是否成功
    final result = await db.query('transactions');
    expect(result.length, 1);
    expect(result.first['note'], 'Test description');
    expect(result.first['description'], null);
  });

  test('Migration should create all required indexes', () async {
    // 执行迁移
    await UpdateTransactionsTableMigration.up(db);

    // 获取所有索引
    final indexes = await db.query('sqlite_master', 
      where: "type = 'index' AND tbl_name = 'transactions'");
    
    // 验证所有必需的索引是否存在
    expect(indexes.any((index) => index['name'] == 'idx_transactions_account_id'), true);
    expect(indexes.any((index) => index['name'] == 'idx_transactions_category_id'), true);
    expect(indexes.any((index) => index['name'] == 'idx_transactions_type'), true);
    expect(indexes.any((index) => index['name'] == 'idx_transactions_date'), true);
  });

  test('Migration rollback should work correctly', () async {
    // 执行迁移
    await UpdateTransactionsTableMigration.up(db);
    
    // 执行回滚
    await UpdateTransactionsTableMigration.down(db);

    // 验证数据是否正确回滚
    final result = await db.query('transactions');
    expect(result.length, 1);
    expect(result.first['description'], 'Test description');
    expect(result.first['note'], null);
  });

  test('Migration should preserve all data', () async {
    // 在迁移前获取所有数据
    final beforeMigration = await db.query('transactions');

    // 执行迁移
    await UpdateTransactionsTableMigration.up(db);

    // 获取迁移后的数据
    final afterMigration = await db.query('transactions');

    // 验证数据数量是否相同
    expect(afterMigration.length, beforeMigration.length);

    // 验证重要字段的值是否保持不变
    expect(afterMigration.first['id'], beforeMigration.first['id']);
    expect(afterMigration.first['account_id'], beforeMigration.first['account_id']);
    expect(afterMigration.first['category_id'], beforeMigration.first['category_id']);
    expect(afterMigration.first['amount'], beforeMigration.first['amount']);
    expect(afterMigration.first['type'], beforeMigration.first['type']);
    expect(afterMigration.first['date'], beforeMigration.first['date']);
    expect(afterMigration.first['note'], beforeMigration.first['description']);
  });
} 