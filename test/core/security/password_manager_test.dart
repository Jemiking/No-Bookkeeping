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

  group('密码管理测试', () {
    const testPassword = 'TestPassword123!';
    const newPassword = 'NewPassword456@';

    test('密码设置测试', () async {
      expect(securityService.hasPassword(), false);
      
      await securityService.setPassword(testPassword);
      expect(securityService.hasPassword(), true);
    });

    test('密码验证测试', () async {
      await securityService.setPassword(testPassword);
      
      final isValid = await securityService.verifyPassword(testPassword);
      expect(isValid, true);
      
      final isInvalid = await securityService.verifyPassword('WrongPassword');
      expect(isInvalid, false);
    });

    test('密码更改测试', () async {
      await securityService.setPassword(testPassword);
      
      await securityService.changePassword(testPassword, newPassword);
      
      final oldPasswordValid = await securityService.verifyPassword(testPassword);
      expect(oldPasswordValid, false);
      
      final newPasswordValid = await securityService.verifyPassword(newPassword);
      expect(newPasswordValid, true);
    });

    test('密码重置测试', () async {
      await securityService.setPassword(testPassword);
      expect(securityService.hasPassword(), true);
      
      await securityService.resetPassword();
      expect(securityService.hasPassword(), false);
    });

    test('密码锁定测试', () async {
      await securityService.setPassword(testPassword);
      
      // 尝试5次错误密码
      for (var i = 0; i < 5; i++) {
        final result = await securityService.verifyPassword('WrongPassword');
        expect(result, false);
      }
      
      // 验证账户已锁定
      expect(
        () => securityService.verifyPassword(testPassword),
        throwsA(isA<StateError>()),
      );
      
      final isLocked = await securityService.isPasswordLocked();
      expect(isLocked, true);
      
      final lockTime = await securityService.getPasswordLockTime();
      expect(lockTime, greaterThan(0));
    });

    test('密码状态测试', () async {
      final initialStatus = securityService.getPasswordStatus();
      expect(initialStatus['hasPassword'], false);
      expect(initialStatus['remainingAttempts'], equals(5));
      
      await securityService.setPassword(testPassword);
      
      final status = securityService.getPasswordStatus();
      expect(status['hasPassword'], true);
      expect(status['remainingAttempts'], equals(5));
      expect(status['isLocked'], false);
    });

    test('错误密码尝试次数测试', () async {
      await securityService.setPassword(testPassword);
      
      // 尝试3次错误密码
      for (var i = 0; i < 3; i++) {
        await securityService.verifyPassword('WrongPassword');
      }
      
      final status = securityService.getPasswordStatus();
      expect(status['remainingAttempts'], equals(2));
      
      // 使用正确密码重置尝试次数
      await securityService.verifyPassword(testPassword);
      
      final resetStatus = securityService.getPasswordStatus();
      expect(resetStatus['remainingAttempts'], equals(5));
    });
  });
} 