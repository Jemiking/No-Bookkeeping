import 'dart:convert';
import 'package:shared_preferences.dart';
import 'security_service.dart';

/// 密码管理器类，负责处理密码相关的功能
class PasswordManager {
  static const String _keyPrefix = 'password_';
  static const String _passwordHashKey = '${_keyPrefix}hash';
  static const String _passwordSaltKey = '${_keyPrefix}salt';
  static const String _passwordAttemptsKey = '${_keyPrefix}attempts';
  static const String _passwordLockedUntilKey = '${_keyPrefix}locked_until';
  
  static const int _maxAttempts = 5;
  static const int _lockDurationMinutes = 30;

  final SharedPreferences _prefs;
  final SecurityService _securityService;

  PasswordManager(this._prefs, this._securityService);

  /// 设置密码
  Future<void> setPassword(String password) async {
    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    
    await Future.wait([
      _prefs.setString(_passwordHashKey, hash),
      _prefs.setString(_passwordSaltKey, salt),
      _prefs.setInt(_passwordAttemptsKey, 0),
      _prefs.remove(_passwordLockedUntilKey),
    ]);
  }

  /// 验证密码
  Future<bool> verifyPassword(String password) async {
    if (await isLocked()) {
      throw StateError('密码已被锁定，请稍后重试');
    }

    final storedHash = _prefs.getString(_passwordHashKey);
    final salt = _prefs.getString(_passwordSaltKey);
    
    if (storedHash == null || salt == null) {
      return false;
    }

    final hash = _hashPassword(password, salt);
    final isValid = hash == storedHash;

    if (!isValid) {
      await _handleFailedAttempt();
    } else {
      await _resetAttempts();
    }

    return isValid;
  }

  /// 更改密码
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (!await verifyPassword(currentPassword)) {
      throw StateError('当前密码错误');
    }
    await setPassword(newPassword);
  }

  /// 重置密码
  Future<void> resetPassword() async {
    await Future.wait([
      _prefs.remove(_passwordHashKey),
      _prefs.remove(_passwordSaltKey),
      _prefs.remove(_passwordAttemptsKey),
      _prefs.remove(_passwordLockedUntilKey),
    ]);
  }

  /// 检查是否设置了密码
  bool hasPassword() {
    return _prefs.getString(_passwordHashKey) != null;
  }

  /// 检查密码是否被锁定
  Future<bool> isLocked() async {
    final lockedUntil = _prefs.getInt(_passwordLockedUntilKey);
    if (lockedUntil == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return now < lockedUntil;
  }

  /// 获取剩余锁定时间（分钟）
  Future<int> getRemainingLockTime() async {
    final lockedUntil = _prefs.getInt(_passwordLockedUntilKey);
    if (lockedUntil == null) return 0;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = lockedUntil - now;
    
    if (remaining <= 0) {
      await _prefs.remove(_passwordLockedUntilKey);
      return 0;
    }
    
    return (remaining / (1000 * 60)).ceil();
  }

  /// 生成随机盐值
  String _generateSalt() {
    final random = List<int>.generate(32, (i) => base64.decode(_securityService.generateHash(i.toString()))[0]);
    return base64.encode(random);
  }

  /// 使用密码和盐值生成哈希
  String _hashPassword(String password, String salt) {
    final combined = password + salt;
    return _securityService.generateHash(combined);
  }

  /// 处理密码验证失败
  Future<void> _handleFailedAttempt() async {
    final attempts = (_prefs.getInt(_passwordAttemptsKey) ?? 0) + 1;
    await _prefs.setInt(_passwordAttemptsKey, attempts);
    
    if (attempts >= _maxAttempts) {
      final lockUntil = DateTime.now().add(Duration(minutes: _lockDurationMinutes)).millisecondsSinceEpoch;
      await _prefs.setInt(_passwordLockedUntilKey, lockUntil);
    }
  }

  /// 重置失败尝试次数
  Future<void> _resetAttempts() async {
    await Future.wait([
      _prefs.setInt(_passwordAttemptsKey, 0),
      _prefs.remove(_passwordLockedUntilKey),
    ]);
  }

  /// 获取密码状态信息
  Map<String, dynamic> getPasswordStatus() {
    final hasPass = hasPassword();
    final attempts = _prefs.getInt(_passwordAttemptsKey) ?? 0;
    final remainingAttempts = _maxAttempts - attempts;
    
    return {
      'hasPassword': hasPass,
      'remainingAttempts': remainingAttempts,
      'maxAttempts': _maxAttempts,
      'isLocked': _prefs.getInt(_passwordLockedUntilKey) != null,
    };
  }
} 