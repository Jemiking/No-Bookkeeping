import 'package:sqflite/sqflite.dart';

/// 基础数据访问对象接口
abstract class BaseDao<T> {
  /// 获取数据库实例
  Future<Database> get database;

  /// 获取表名
  String get tableName;

  /// 从Map创建实体对象
  T fromMap(Map<String, dynamic> map);

  /// 将实体对象转换为Map
  Map<String, dynamic> toMap(T entity);

  /// 插入单个实体
  Future<String> insert(T entity);

  /// 批量插入实体
  Future<List<String>> insertAll(List<T> entities);

  /// 更新单个实体
  Future<int> update(T entity);

  /// 批量更新实体
  Future<int> updateAll(List<T> entities);

  /// 删除单个实体
  Future<int> delete(String id);

  /// 批量删除实体
  Future<int> deleteAll(List<String> ids);

  /// 根据ID查询单个实体
  Future<T?> findById(String id);

  /// 查询所有实体
  Future<List<T>> findAll();

  /// 根据条件查询实体
  Future<List<T>> findWhere(String where, List<dynamic> whereArgs);

  /// 分页查询实体
  Future<List<T>> findPage(int offset, int limit, {String? orderBy});

  /// 统计总数
  Future<int> count();

  /// 根据条件统计数量
  Future<int> countWhere(String where, List<dynamic> whereArgs);

  /// 检查记录是否存在
  Future<bool> exists(String id);

  /// 清空表
  Future<void> clear();

  /// 执行自定义查询
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]);

  /// 执行自定义更新
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]);

  /// 执行事务
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action);

  /// 批量操作
  Future<void> batch(void Function(Batch batch) actions);

  /// 验证实体
  bool validate(T entity);

  /// 获取实体的主键值
  String getEntityId(T entity);
} 