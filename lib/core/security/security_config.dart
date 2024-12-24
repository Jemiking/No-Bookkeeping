import 'dart:convert';
import 'package:shared_preferences.dart';
import 'encryption_manager.dart';

/// 安全配置管理器类，负责管理加密相关的配置
class SecurityConfig {
  static const String _keyPrefix = 'security_config_';
  static const String _encryptionKeyKey = '${_keyPrefix}encryption_key';
  static const String _securitySettingsKey = '${_keyPrefix}settings';
  
  final SharedPreferences _prefs;
  final EncryptionManager _encryptionManager;

  SecurityConfig(this._prefs, this._encryptionManager);

  /// 初始化安全配置
  Future<void> initialize() async {
    String? encryptionKey = _prefs.getString(_encryptionKeyKey);
    
    if (encryptionKey == null) {
      // 首次运行，生成新的加密密钥
      encryptionKey = _encryptionManager.generateNewKey();
      await _prefs.setString(_encryptionKeyKey, encryptionKey);
    }

    // 初始化加密管理器
    await _encryptionManager.initialize(encryptionKey);
  }

  /// 更新加密密钥
  Future<void> updateEncryptionKey() async {
    final newKey = _encryptionManager.generateNewKey();
    await _encryptionManager.reset(newKey);
    await _prefs.setString(_encryptionKeyKey, newKey);
  }

  /// 获取安全设置
  Map<String, dynamic> getSecuritySettings() {
    final settingsJson = _prefs.getString(_securitySettingsKey);
    if (settingsJson == null) return {};
    
    final encryptedSettings = _encryptionManager.decryptSensitiveData(settingsJson);
    return json.decode(encryptedSettings);
  }

  /// 更新安全设置
  Future<void> updateSecuritySettings(Map<String, dynamic> settings) async {
    final settingsJson = json.encode(settings);
    final encryptedSettings = _encryptionManager.encryptSensitiveData(settingsJson);
    await _prefs.setString(_securitySettingsKey, encryptedSettings);
  }

  /// 清除所有安全配置
  Future<void> clearSecurityConfig() async {
    await _prefs.remove(_encryptionKeyKey);
    await _prefs.remove(_securitySettingsKey);
  }

  /// 验证安全配置完整性
  bool validateSecurityConfig() {
    final encryptionKey = _prefs.getString(_encryptionKeyKey);
    return encryptionKey != null && encryptionKey.isNotEmpty;
  }

  /// 获取加密密钥状态
  Map<String, dynamic> getEncryptionKeyStatus() {
    final encryptionKey = _prefs.getString(_encryptionKeyKey);
    if (encryptionKey == null) {
      return {
        'status': 'missing',
        'message': '加密密钥未设置'
      };
    }

    return {
      'status': 'valid',
      'message': '加密密钥有效',
      'lastUpdated': _prefs.getInt('${_keyPrefix}key_updated_at') ?? 0
    };
  }

  /// 备份安全配置
  Map<String, String> exportSecurityConfig() {
    return {
      'encryption_key': _prefs.getString(_encryptionKeyKey) ?? '',
      'settings': _prefs.getString(_securitySettingsKey) ?? '',
    };
  }

  /// 恢复安全配置
  Future<void> importSecurityConfig(Map<String, String> config) async {
    if (config.containsKey('encryption_key')) {
      await _prefs.setString(_encryptionKeyKey, config['encryption_key']!);
    }
    if (config.containsKey('settings')) {
      await _prefs.setString(_securitySettingsKey, config['settings']!);
    }
    await initialize();
  }
} 