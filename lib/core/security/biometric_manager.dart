import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences.dart';
import 'package:flutter/services.dart';

/// 生物识别管理器类，负责处理生物识别相关的功能
class BiometricManager {
  static const String _keyPrefix = 'biometric_';
  static const String _biometricEnabledKey = '${_keyPrefix}enabled';
  
  final LocalAuthentication _localAuth;
  final SharedPreferences _prefs;

  BiometricManager(this._prefs) : _localAuth = LocalAuthentication();

  /// 检查设备是否支持生物识别
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// 检查是否已启用生物识别
  bool isBiometricEnabled() {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// 启用生物识别
  Future<void> enableBiometric() async {
    await _prefs.setBool(_biometricEnabledKey, true);
  }

  /// 禁用生物识别
  Future<void> disableBiometric() async {
    await _prefs.setBool(_biometricEnabledKey, false);
  }

  /// 获取可用的生物识别方式
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  /// 验证生物识别
  Future<bool> authenticate({
    String localizedReason = '请验证生物识别以继续',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool sensitiveTransaction = true,
  }) async {
    if (!await isDeviceSupported()) {
      throw UnsupportedError('设备不支持生物识别');
    }

    if (!isBiometricEnabled()) {
      throw StateError('生物识别未启用');
    }

    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
        ),
      );
    } on PlatformException catch (e) {
      throw StateError('生物识别验证失败: ${e.message}');
    }
  }

  /// 取消生物识别
  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException catch (_) {
      // 忽略取消过程中的错误
    }
  }

  /// 获取生物识别状态信息
  Future<Map<String, dynamic>> getBiometricStatus() async {
    final isSupported = await isDeviceSupported();
    final isEnabled = isBiometricEnabled();
    final availableBiometrics = await getAvailableBiometrics();

    return {
      'isSupported': isSupported,
      'isEnabled': isEnabled,
      'availableBiometrics': availableBiometrics.map((type) => type.toString()).toList(),
      'hasFaceId': availableBiometrics.contains(BiometricType.face),
      'hasFingerprint': availableBiometrics.contains(BiometricType.fingerprint),
      'hasIris': availableBiometrics.contains(BiometricType.iris),
    };
  }
} 