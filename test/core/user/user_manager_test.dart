import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_app_name/core/user/user_manager.dart';

void main() {
  group('用户管理器测试', () {
    late UserManager userManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      userManager = UserManager.instance;
      await userManager.initialize();
    });

    test('单例模式测试', () {
      final instance1 = UserManager.instance;
      final instance2 = UserManager.instance;

      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('初始状态测试', () {
      expect(userManager.currentUser, isNull);
      expect(userManager.token, isNull);
      expect(userManager.isLoggedIn, isFalse);
    });

    test('登录测试', () async {
      // 错误的凭据
      final wrongResult = await userManager.login('wrong', 'wrong');
      expect(wrongResult, isFalse);
      expect(userManager.isLoggedIn, isFalse);

      // 正确的凭据
      final correctResult = await userManager.login('test', 'test123');
      expect(correctResult, isTrue);
      expect(userManager.isLoggedIn, isTrue);
      expect(userManager.currentUser, isNotNull);
      expect(userManager.token, isNotNull);
      expect(userManager.currentUser!.username, equals('test'));
    });

    test('注册测试', () async {
      final result = await userManager.register(
        'newuser',
        'password123',
        'newuser@example.com',
      );

      expect(result, isTrue);
      expect(userManager.isLoggedIn, isTrue);
      expect(userManager.currentUser, isNotNull);
      expect(userManager.token, isNotNull);
      expect(userManager.currentUser!.username, equals('newuser'));
      expect(userManager.currentUser!.email, equals('newuser@example.com'));
    });

    test('登出测试', () async {
      // 先登录
      await userManager.login('test', 'test123');
      expect(userManager.isLoggedIn, isTrue);

      // 登出
      await userManager.logout();
      expect(userManager.isLoggedIn, isFalse);
      expect(userManager.currentUser, isNull);
      expect(userManager.token, isNull);
    });

    test('更新个人资料测试', () async {
      // 未登录状态
      final resultBeforeLogin = await userManager.updateProfile(
        nickname: 'New Name',
      );
      expect(resultBeforeLogin, isFalse);

      // 登录后更新
      await userManager.login('test', 'test123');
      final resultAfterLogin = await userManager.updateProfile(
        nickname: 'New Name',
        email: 'newemail@example.com',
      );

      expect(resultAfterLogin, isTrue);
      expect(userManager.currentUser!.nickname, equals('New Name'));
      expect(userManager.currentUser!.email, equals('newemail@example.com'));
    });

    test('修改密码测试', () async {
      // 未登录状态
      final resultBeforeLogin = await userManager.changePassword(
        'oldpass',
        'newpass',
      );
      expect(resultBeforeLogin, isFalse);

      // 登录后修改
      await userManager.login('test', 'test123');
      
      // 错误的旧密码
      final resultWrongOldPass = await userManager.changePassword(
        'wrongpass',
        'newpass',
      );
      expect(resultWrongOldPass, isFalse);

      // 正确的旧密码
      final resultCorrectOldPass = await userManager.changePassword(
        'test123',
        'newpass',
      );
      expect(resultCorrectOldPass, isTrue);
    });

    test('重置密码测试', () async {
      final result = await userManager.resetPassword('test@example.com');
      expect(result, isTrue);
    });

    test('令牌验证测试', () async {
      // 未登录状态
      final resultBeforeLogin = await userManager.verifyToken();
      expect(resultBeforeLogin, isFalse);

      // 登录后验证
      await userManager.login('test', 'test123');
      final resultAfterLogin = await userManager.verifyToken();
      expect(resultAfterLogin, isTrue);
    });

    test('令牌刷新测试', () async {
      // 未登录状态
      await userManager.refreshToken();
      expect(userManager.token, isNull);

      // 登录后刷新
      await userManager.login('test', 'test123');
      final oldToken = userManager.token;
      await userManager.refreshToken();
      expect(userManager.token, isNotNull);
      expect(userManager.token, isNot(equals(oldToken)));
    });

    test('用户数据持久化测试', () async {
      // 登录并保存数据
      await userManager.login('test', 'test123');
      final originalUser = userManager.currentUser;
      final originalToken = userManager.token;

      // 重新初始化
      await userManager.initialize();

      // 验证数据恢复
      expect(userManager.currentUser, isNotNull);
      expect(userManager.token, isNotNull);
      expect(userManager.currentUser!.id, equals(originalUser!.id));
      expect(userManager.token, equals(originalToken));
    });

    test('用户模型测试', () {
      final user = User(
        id: '1',
        username: 'test',
        email: 'test@example.com',
        nickname: 'Test User',
        avatar: 'avatar.png',
        createdAt: DateTime(2024),
        lastLoginAt: DateTime(2024, 1, 1),
      );

      // 复制测试
      final copiedUser = user.copyWith(
        nickname: 'New Name',
        email: 'new@example.com',
      );
      expect(copiedUser.id, equals(user.id));
      expect(copiedUser.nickname, equals('New Name'));
      expect(copiedUser.email, equals('new@example.com'));
      expect(copiedUser.username, equals(user.username));

      // JSON序列化测试
      final json = user.toJson();
      final fromJson = User.fromJson(json);
      expect(fromJson, equals(user));
      expect(fromJson.hashCode, equals(user.hashCode));
    });

    test('错误处理测试', () async {
      // 模拟无效的持久化数据
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', 'invalid_data');
      await prefs.setString('user_token', 'invalid_token');

      // 重新初始化
      await userManager.initialize();

      // 验证错误恢复
      expect(userManager.currentUser, isNull);
      expect(userManager.token, isNull);
      expect(userManager.isLoggedIn, isFalse);
    });

    test('通知监听测试', () async {
      int notificationCount = 0;
      userManager.addListener(() {
        notificationCount++;
      });

      // 登录
      await userManager.login('test', 'test123');
      expect(notificationCount, equals(1));

      // 更新个人资料
      await userManager.updateProfile(nickname: 'New Name');
      expect(notificationCount, equals(2));

      // 刷新令牌
      await userManager.refreshToken();
      expect(notificationCount, equals(3));

      // 登出
      await userManager.logout();
      expect(notificationCount, equals(4));
    });
  });
} 