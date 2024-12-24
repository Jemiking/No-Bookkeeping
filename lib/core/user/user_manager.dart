import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences.dart';
import 'package:your_app_name/core/services/security_service.dart';

class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();
  static UserManager get instance => _instance;

  late SharedPreferences _prefs;
  late SecurityService _securityService;
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'user_token';

  User? _currentUser;
  String? _token;
  bool _isInitialized = false;

  UserManager._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _securityService = SecurityService.instance;
    await _loadUserData();
    _isInitialized = true;
  }

  Future<void> _loadUserData() async {
    final encryptedUserData = _prefs.getString(_userKey);
    final encryptedToken = _prefs.getString(_tokenKey);

    if (encryptedUserData != null) {
      try {
        final decryptedData = await _securityService.decrypt(encryptedUserData);
        _currentUser = User.fromJson(jsonDecode(decryptedData));
      } catch (e) {
        debugPrint('加载用户数据错误: $e');
        _currentUser = null;
      }
    }

    if (encryptedToken != null) {
      try {
        _token = await _securityService.decrypt(encryptedToken);
      } catch (e) {
        debugPrint('加载令牌错误: $e');
        _token = null;
      }
    }

    notifyListeners();
  }

  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      final userData = jsonEncode(_currentUser!.toJson());
      final encryptedData = await _securityService.encrypt(userData);
      await _prefs.setString(_userKey, encryptedData);
    } else {
      await _prefs.remove(_userKey);
    }

    if (_token != null) {
      final encryptedToken = await _securityService.encrypt(_token!);
      await _prefs.setString(_tokenKey, encryptedToken);
    } else {
      await _prefs.remove(_tokenKey);
    }
  }

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null;

  // Authentication methods
  Future<bool> login(String username, String password) async {
    try {
      // TODO: 实现实际的登录API调用
      // 这里使用模拟数据
      if (username == 'test' && password == 'test123') {
        _currentUser = User(
          id: '1',
          username: username,
          email: 'test@example.com',
          nickname: '测试用户',
          avatar: 'assets/images/default_avatar.png',
          createdAt: DateTime.now(),
        );
        _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        await _saveUserData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('登录错误: $e');
      return false;
    }
  }

  Future<bool> register(String username, String password, String email) async {
    try {
      // TODO: 实现实际的注册API调用
      // 这里使用模拟数据
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: email,
        nickname: username,
        avatar: 'assets/images/default_avatar.png',
        createdAt: DateTime.now(),
      );
      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await _saveUserData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('注册错误: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    await _saveUserData();
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? nickname,
    String? email,
    String? avatar,
  }) async {
    try {
      if (_currentUser == null) return false;

      // TODO: 实现实际的更新个人资料API调用
      _currentUser = _currentUser!.copyWith(
        nickname: nickname,
        email: email,
        avatar: avatar,
      );
      await _saveUserData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('更新个人资料错误: $e');
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      if (_currentUser == null) return false;

      // TODO: 实现实际的修改密码API调用
      // 这里使用模拟验证
      if (oldPassword == 'test123') {
        await _saveUserData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('修改密码错误: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      // TODO: 实现实际的重置密码API调用
      return true;
    } catch (e) {
      debugPrint('重置密码错误: $e');
      return false;
    }
  }

  Future<bool> verifyToken() async {
    try {
      if (_token == null) return false;

      // TODO: 实现实际的令牌验证API调用
      return true;
    } catch (e) {
      debugPrint('验证令牌错误: $e');
      return false;
    }
  }

  Future<void> refreshToken() async {
    try {
      if (_token == null) return;

      // TODO: 实现实际的令牌刷新API调用
      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await _saveUserData();
      notifyListeners();
    } catch (e) {
      debugPrint('刷新令牌错误: $e');
    }
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String nickname;
  final String avatar;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.nickname,
    required this.avatar,
    required this.createdAt,
    this.lastLoginAt,
  });

  User copyWith({
    String? nickname,
    String? email,
    String? avatar,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id,
      username: username,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nickname': nickname,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 