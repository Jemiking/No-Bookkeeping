import 'package:sqflite/sqflite.dart';

class TagTable {
  static const String tableName = 'tags';
  static const String transactionTagsTable = 'transaction_tags';

  static Future<void> createTables(Database db) async {
    // 创建标签表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color TEXT,
        icon TEXT,
        isSystem INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 创建交易-标签关联表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $transactionTagsTable (
        transactionId TEXT NOT NULL,
        tagId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        PRIMARY KEY (transactionId, tagId),
        FOREIGN KEY (transactionId) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (tagId) REFERENCES $tableName(id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_tags_name ON $tableName(name)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_tags_isSystem ON $tableName(isSystem)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transaction_tags_transactionId 
      ON $transactionTagsTable(transactionId)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transaction_tags_tagId 
      ON $transactionTagsTable(tagId)
    ''');
  }

  static Future<void> upgradeTables(Database db, int oldVersion, int newVersion) async {
    // 在这里处理数据库升级逻辑
    if (oldVersion < 2) {
      // 版本1升级到版本2的逻辑
    }
  }

  // 预设的系统标签
  static const List<Map<String, dynamic>> systemTags = [
    {
      'name': '餐饮',
      'description': '用于记录餐饮相关支出',
      'color': '#FF5722',
      'icon': 'restaurant',
      'isSystem': true,
    },
    {
      'name': '交通',
      'description': '用于记录交通相关支出',
      'color': '#2196F3',
      'icon': 'directions_car',
      'isSystem': true,
    },
    {
      'name': '购物',
      'description': '用于记录购物相关支出',
      'color': '#E91E63',
      'icon': 'shopping_cart',
      'isSystem': true,
    },
    {
      'name': '娱乐',
      'description': '用于记录娱乐相关支出',
      'color': '#9C27B0',
      'icon': 'movie',
      'isSystem': true,
    },
    {
      'name': '居住',
      'description': '用于记录居住相关支出',
      'color': '#795548',
      'icon': 'home',
      'isSystem': true,
    },
    {
      'name': '通讯',
      'description': '用于记录通讯相关支出',
      'color': '#607D8B',
      'icon': 'phone',
      'isSystem': true,
    },
    {
      'name': '医疗',
      'description': '用于记录医疗相关支出',
      'color': '#F44336',
      'icon': 'local_hospital',
      'isSystem': true,
    },
    {
      'name': '教育',
      'description': '用于记录教育相关支出',
      'color': '#4CAF50',
      'icon': 'school',
      'isSystem': true,
    },
  ];
} 