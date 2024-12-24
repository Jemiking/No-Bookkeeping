import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:your_app_name/core/security/security_service.dart';

void main() {
  late SecurityService securityService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    securityService = SecurityService.instance;
    await securityService.initialize();
  });

  group('生物识别测试', () {
    test('生物识别启用状态测试', () async {
      expect(securityService.isBiometricEnabled(), false);
      
      await securityService.enableBiometric();
      expect(securityService.isBiometricEnabled(), true);
      
      await securityService.disableBiometric();
      expect(securityService.isBiometricEnabled(), false);
    });

    test('生物识别状态信息测试', () async {
      final status = await securityService.getBiometricStatus();
      
      expect(status, isA<Map<String, dynamic>>());
      expect(status['isEnabled'], false);
      expect(status['availableBiometrics'], isA<List>());
      expect(status.containsKey('hasFaceId'), true);
      expect(status.containsKey('hasFingerprint'), true);
      expect(status.containsKey('hasIris'), true);
    });

    test('生物识别可用性测试', () async {
      final isSupported = await securityService.isBiometricSupported();
      expect(isSupported, isA<bool>());
      
      final availableBiometrics = await securityService.getAvailableBiometrics();
      expect(availableBiometrics, isA<List<BiometricType>>());
    });

    test('生物识别验证流程测试', () async {
      // 注意：这里我们只测试API调用是否正确，不测试实际的生物识别验证
      // 因为在测试环境中无法模拟真实的生物识别硬件
      
      await securityService.enableBiometric();
      expect(securityService.isBiometricEnabled(), true);
      
      // 验证异常情况
      expect(
        () => securityService.authenticateBiometric(),
        throwsA(isA<UnsupportedError>()),
      );
      
      // 验证取消操作
      await securityService.cancelBiometricAuthentication();
    });

    test('生物识别配置持久化测试', () async {
      await securityService.enableBiometric();
      expect(securityService.isBiometricEnabled(), true);
      
      // 重新初始化服务
      await securityService.reset();
      await securityService.initialize();
      
      // 验证配置是否保持
      expect(securityService.isBiometricEnabled(), true);
    });
  });
} 