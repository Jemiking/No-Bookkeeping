import 'package:sqflite/sqflite.dart';
import '../../models/user_model.dart';
import '../database_helper.dart';
import '../table_definitions.dart';
import 'base_dao.dart';

/// User DAO implementation
class UserDao extends BaseDao<User> {
  final DatabaseHelper _databaseHelper;

  UserDao(this._databaseHelper);

  @override
  Future<Database> get database => _databaseHelper.database;

  @override
  String get tableName => TableDefinitions.usersTable;

  @override
  Map<String, dynamic> toMap(User model) => model.toMap();

  @override
  User fromMap(Map<String, dynamic> map) => User.fromMap(map);

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    final maps = await query(
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    final count = await count(
      where: 'email = ?',
      whereArgs: [email],
    );
    return count > 0;
  }

  /// Search users by name
  Future<List<User>> searchByName(String name) async {
    return query(
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
      orderBy: 'name ASC',
    );
  }

  /// Get users created after date
  Future<List<User>> getUsersCreatedAfter(DateTime date) async {
    return query(
      where: 'created_at > ?',
      whereArgs: [date.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
    );
  }

  /// Get users updated after date
  Future<List<User>> getUsersUpdatedAfter(DateTime date) async {
    return query(
      where: 'updated_at > ?',
      whereArgs: [date.millisecondsSinceEpoch],
      orderBy: 'updated_at DESC',
    );
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_users,
        MIN(created_at) as oldest_user,
        MAX(created_at) as newest_user,
        COUNT(DISTINCT email) as users_with_email
      FROM $tableName
    ''');
    return result.first;
  }

  /// Delete inactive users
  Future<int> deleteInactiveUsers(DateTime lastActiveDate) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'updated_at < ?',
      whereArgs: [lastActiveDate.millisecondsSinceEpoch],
    );
  }

  /// Update user avatar
  Future<bool> updateAvatar(String userId, String? avatarUrl) async {
    final db = await database;
    final count = await db.update(
      tableName,
      {
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  /// Update user email
  Future<bool> updateEmail(String userId, String email) async {
    final exists = await emailExists(email);
    if (exists) return false;

    final db = await database;
    final count = await db.update(
      tableName,
      {
        'email': email,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  /// Update user name
  Future<bool> updateName(String userId, String name) async {
    final db = await database;
    final count = await db.update(
      tableName,
      {
        'name': name,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }
} 