import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_app_name/core/security/security_service.dart';

void main() {
  late SecurityService securityService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    securityService = SecurityService.instance;
    await securityService.initialize();
  });

  group('SecurityService Tests', () {
    test('初始化测试', () {
      expect(securityService.validateSecurityStatus(), true);
    });

    test('加密解密测试', () {
      const testData = '测试数据';
      final encrypted = securityService.encryptData(testData);
      expect(encrypted, isNot(equals(testData)));
      
      final decrypted = securityService.decryptData(encrypted);
      expect(decrypted, equals(testData));
    });

    test('哈希生成测试', () {
      const testData = '测试数据';
      final hash1 = securityService.generateHash(testData);
      final hash2 = securityService.generateHash(testData);
      expect(hash1, equals(hash2));
    });

    test('安全设置测试', () async {
      final testSettings = {'key': 'value'};
      await securityService.updateSecuritySettings(testSettings);
      
      final retrievedSettings = securityService.getSecuritySettings();
      expect(retrievedSettings, equals(testSettings));
    });

    test('加密密钥状态测试', () {
      final status = securityService.getEncryptionKeyStatus();
      expect(status['status'], equals('valid'));
    });

    test('配置导出导入测试', () async {
      const testData = '测试数据';
      final encrypted = securityService.encryptData(testData);
      
      final config = securityService.exportSecurityConfig();
      await securityService.reset();
      await securityService.importSecurityConfig(config);
      
      final decrypted = securityService.decryptData(encrypted);
      expect(decrypted, equals(testData));
    });

    test('密钥轮换测试', () async {
      const testData = '测试数据';
      final encrypted = securityService.encryptData(testData);
      
      await securityService.rotateEncryptionKey();
      
      expect(
        () => securityService.decryptData(encrypted),
        throwsException,
      );
    });
  });
} 