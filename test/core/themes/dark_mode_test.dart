import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_tracker/core/themes/dark_mode.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DarkModeConfig Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('默认应该跟随系统主题', () async {
      final isFollowingSystem = await DarkModeConfig.isFollowingSystem();
      expect(isFollowingSystem, isTrue);
    });

    test('手动设置暗黑模式', () async {
      // 设置暗黑模式
      await DarkModeConfig.setDarkMode(true);

      // 验证设置
      final isDark = await DarkModeConfig.isDarkMode();
      final isFollowingSystem = await DarkModeConfig.isFollowingSystem();
      final isAutoDarkMode = await DarkModeConfig.isAutoDarkMode();

      expect(isDark, isTrue);
      expect(isFollowingSystem, isFalse);
      expect(isAutoDarkMode, isFalse);
    });

    test('设置跟随系统主题', () async {
      // 先设置手动暗黑模式
      await DarkModeConfig.setDarkMode(true);

      // 然后设置跟随系统
      await DarkModeConfig.setFollowSystem(true);

      // 验证设置
      final isFollowingSystem = await DarkModeConfig.isFollowingSystem();
      final isAutoDarkMode = await DarkModeConfig.isAutoDarkMode();

      expect(isFollowingSystem, isTrue);
      expect(isAutoDarkMode, isFalse);
    });

    test('设置自动暗黑模式', () async {
      // 设置自动暗黑模式
      await DarkModeConfig.setAutoDarkMode(true);

      // 验证设置
      final isAutoDarkMode = await DarkModeConfig.isAutoDarkMode();
      final isFollowingSystem = await DarkModeConfig.isFollowingSystem();

      expect(isAutoDarkMode, isTrue);
      expect(isFollowingSystem, isFalse);
    });

    test('设置暗黑模式时间范围', () async {
      final startTime = const TimeOfDay(hour: 20, minute: 30);
      final endTime = const TimeOfDay(hour: 6, minute: 30);

      // 设置时间范围
      await DarkModeConfig.setDarkModeTimeRange(startTime, endTime);

      // 获取时间范围并验证
      final timeRange = await DarkModeConfig.getDarkModeTimeRange();

      expect(timeRange['startTime']?.hour, equals(20));
      expect(timeRange['startTime']?.minute, equals(30));
      expect(timeRange['endTime']?.hour, equals(6));
      expect(timeRange['endTime']?.minute, equals(30));
    });

    test('获取默认暗黑模式时间范围', () async {
      // 获取默认时间范围
      final timeRange = await DarkModeConfig.getDarkModeTimeRange();

      expect(timeRange['startTime']?.hour, equals(22));
      expect(timeRange['startTime']?.minute, equals(0));
      expect(timeRange['endTime']?.hour, equals(6));
      expect(timeRange['endTime']?.minute, equals(0));
    });

    test('暗黑模式主题配置', () {
      final darkTheme = DarkModeConfig.getDarkTheme();

      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(darkTheme.scaffoldBackgroundColor, equals(const Color(0xFF121212)));
      expect(darkTheme.colorScheme.surface, equals(const Color(0xFF1E1E1E)));
      expect(darkTheme.colorScheme.primary, equals(Colors.blue[700]));
      expect(darkTheme.colorScheme.secondary, equals(Colors.blue[500]));
    });

    test('暗黑模式主题组件样式', () {
      final darkTheme = DarkModeConfig.getDarkTheme();

      // 验证卡片主题
      expect(darkTheme.cardTheme.color, equals(const Color(0xFF1E1E1E)));
      expect(darkTheme.cardTheme.elevation, equals(2));

      // 验证应用栏主题
      expect(darkTheme.appBarTheme.backgroundColor, equals(const Color(0xFF1E1E1E)));
      expect(darkTheme.appBarTheme.foregroundColor, equals(Colors.white));
      expect(darkTheme.appBarTheme.elevation, equals(0));

      // 验证底部导航栏主题
      expect(darkTheme.bottomNavigationBarTheme.backgroundColor, equals(const Color(0xFF1E1E1E)));
      expect(darkTheme.bottomNavigationBarTheme.selectedItemColor, equals(Colors.blue));
      expect(darkTheme.bottomNavigationBarTheme.unselectedItemColor, equals(Colors.grey));

      // 验证文本主题
      expect(darkTheme.textTheme.bodyLarge?.color, equals(Colors.white));
      expect(darkTheme.textTheme.bodyMedium?.color, equals(Colors.white70));

      // 验证输入框主题
      expect(darkTheme.inputDecorationTheme.filled, isTrue);
      expect(darkTheme.inputDecorationTheme.fillColor, equals(const Color(0xFF2C2C2C)));
    });
  });
} 