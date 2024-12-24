import '../database/dao/user_dao.dart';
import '../models/user_model.dart';
import 'base_service.dart';

/// User service implementation
class UserService implements BaseService<User> {
  final UserDao _userDao;

  UserService(this._userDao);

  @override
  Future<String> create(User user) async {
    return await _userDao.insert(user);
  }

  @override
  Future<bool> delete(String id) async {
    return await _userDao.delete(id);
  }

  @override
  Future<bool> exists(String id) async {
    return await _userDao.exists(id);
  }

  @override
  Future<List<User>> getAll() async {
    return await _userDao.getAll();
  }

  @override
  Future<User?> getById(String id) async {
    return await _userDao.get(id);
  }

  @override
  Future<bool> update(User user) async {
    return await _userDao.update(user);
  }

  @override
  Future<int> count() async {
    return await _userDao.count();
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    return await _userDao.getUserByEmail(email);
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    return await _userDao.emailExists(email);
  }

  /// Search users by name
  Future<List<User>> searchByName(String name) async {
    return await _userDao.searchByName(name);
  }

  /// Update user avatar
  Future<bool> updateAvatar(String userId, String? avatarUrl) async {
    return await _userDao.updateAvatar(userId, avatarUrl);
  }

  /// Update user email
  Future<bool> updateEmail(String userId, String email) async {
    return await _userDao.updateEmail(userId, email);
  }

  /// Update user name
  Future<bool> updateName(String userId, String name) async {
    return await _userDao.updateName(userId, name);
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    return await _userDao.getUserStatistics();
  }
} 