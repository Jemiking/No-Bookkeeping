import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_manager.dart';
import 'security_config.dart';
import 'password_manager.dart';
import 'biometric_manager.dart';

/// 安全服务类，提供统一的安全功能接口
class SecurityService {
  late final EncryptionManager _encryptionManager;
  late final SecurityConfig _securityConfig;
  late final PasswordManager _passwordManager;
  late final BiometricManager _biometricManager;
  bool _isInitialized = false;

  SecurityService._();
  static final SecurityService instance = SecurityService._();

  /// 初始化安全服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _encryptionManager = EncryptionManager();
    _securityConfig = SecurityConfig(prefs, _encryptionManager);
    _passwordManager = PasswordManager(prefs, this);
    _biometricManager = BiometricManager(prefs);
    
    await _securityConfig.initialize();
    _isInitialized = true;
  }

  /// 加密敏感数据
  String encryptData(String data) {
    _checkInitialization();
    return _encryptionManager.encryptSensitiveData(data);
  }

  /// 解密数据
  String decryptData(String encryptedData) {
    _checkInitialization();
    return _encryptionManager.decryptSensitiveData(encryptedData);
  }

  /// 生成数据哈希
  String generateHash(String data) {
    _checkInitialization();
    return _encryptionManager.generateHash(data);
  }

  /// 更新加密密钥
  Future<void> rotateEncryptionKey() async {
    _checkInitialization();
    await _securityConfig.updateEncryptionKey();
  }

  /// 获取安全设置
  Map<String, dynamic> getSecuritySettings() {
    _checkInitialization();
    return _securityConfig.getSecuritySettings();
  }

  /// 更新安全设置
  Future<void> updateSecuritySettings(Map<String, dynamic> settings) async {
    _checkInitialization();
    await _securityConfig.updateSecuritySettings(settings);
  }

  /// 验证安全配置状态
  bool validateSecurityStatus() {
    _checkInitialization();
    return _securityConfig.validateSecurityConfig();
  }

  /// 获取加密密钥状态
  Map<String, dynamic> getEncryptionKeyStatus() {
    _checkInitialization();
    return _securityConfig.getEncryptionKeyStatus();
  }

  /// 备份安全配置
  Map<String, String> exportSecurityConfig() {
    _checkInitialization();
    return _securityConfig.exportSecurityConfig();
  }

  /// 恢复安全配置
  Future<void> importSecurityConfig(Map<String, String> config) async {
    _checkInitialization();
    await _securityConfig.importSecurityConfig(config);
  }

  /// 重置安全服务
  Future<void> reset() async {
    _checkInitialization();
    await _securityConfig.clearSecurityConfig();
    await initialize();
  }

  /// 检查初始化状态
  void _checkInitialization() {
    if (!_isInitialized) {
      throw StateError('SecurityService未初始化，请先调用initialize()方法');
    }
  }

  /// 设置应用密码
  Future<void> setPassword(String password) async {
    _checkInitialization();
    await _passwordManager.setPassword(password);
  }

  /// 验证应用密码
  Future<bool> verifyPassword(String password) async {
    _checkInitialization();
    return _passwordManager.verifyPassword(password);
  }

  /// 更改应用密码
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _checkInitialization();
    await _passwordManager.changePassword(currentPassword, newPassword);
  }

  /// 重置应用密码
  Future<void> resetPassword() async {
    _checkInitialization();
    await _passwordManager.resetPassword();
  }

  /// 检查是否设置了密码
  bool hasPassword() {
    _checkInitialization();
    return _passwordManager.hasPassword();
  }

  /// 检查密码是否被锁定
  Future<bool> isPasswordLocked() async {
    _checkInitialization();
    return _passwordManager.isLocked();
  }

  /// 获取剩余锁定时间
  Future<int> getPasswordLockTime() async {
    _checkInitialization();
    return _passwordManager.getRemainingLockTime();
  }

  /// 获取密码状态
  Map<String, dynamic> getPasswordStatus() {
    _checkInitialization();
    return _passwordManager.getPasswordStatus();
  }

  /// 检查设备是否支持生物识别
  Future<bool> isBiometricSupported() async {
    _checkInitialization();
    return _biometricManager.isDeviceSupported();
  }

  /// 检查是否已启用生物识别
  bool isBiometricEnabled() {
    _checkInitialization();
    return _biometricManager.isBiometricEnabled();
  }

  /// 启用生物识别
  Future<void> enableBiometric() async {
    _checkInitialization();
    await _biometricManager.enableBiometric();
  }

  /// 禁用生物识别
  Future<void> disableBiometric() async {
    _checkInitialization();
    await _biometricManager.disableBiometric();
  }

  /// 获取可用的生物识别方式
  Future<List<BiometricType>> getAvailableBiometrics() async {
    _checkInitialization();
    return _biometricManager.getAvailableBiometrics();
  }

  /// 验证生物识别
  Future<bool> authenticateBiometric({
    String? localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool sensitiveTransaction = true,
  }) async {
    _checkInitialization();
    return _biometricManager.authenticate(
      localizedReason: localizedReason ?? '请验证生物识别以继续',
      useErrorDialogs: useErrorDialogs,
      stickyAuth: stickyAuth,
      sensitiveTransaction: sensitiveTransaction,
    );
  }

  /// 取消生物识别
  Future<void> cancelBiometricAuthentication() async {
    _checkInitialization();
    await _biometricManager.cancelAuthentication();
  }

  /// 获取生物识别状态
  Future<Map<String, dynamic>> getBiometricStatus() async {
    _checkInitialization();
    return _biometricManager.getBiometricStatus();
  }
} 