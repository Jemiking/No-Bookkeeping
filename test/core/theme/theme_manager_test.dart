import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_app_name/core/theme/theme_manager.dart';

void main() {
  group('主题管理器测试', () {
    late ThemeManager themeManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeManager = ThemeManager.instance;
      await themeManager.initialize();
    });

    test('单例模式测试', () {
      final instance1 = ThemeManager.instance;
      final instance2 = ThemeManager.instance;

      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('默认主题设置测试', () {
      expect(themeManager.themeMode, equals(ThemeMode.system));
      expect(themeManager.primaryColor, equals(Colors.blue));
      expect(themeManager.secondaryColor, equals(Colors.blueAccent));
      expect(themeManager.useMaterial3, isTrue);
    });

    test('主题模式切换测试', () async {
      await themeManager.setThemeMode(ThemeMode.dark);
      expect(themeManager.themeMode, equals(ThemeMode.dark));

      await themeManager.setThemeMode(ThemeMode.light);
      expect(themeManager.themeMode, equals(ThemeMode.light));

      await themeManager.setThemeMode(ThemeMode.system);
      expect(themeManager.themeMode, equals(ThemeMode.system));
    });

    test('主题颜色设置测试', () async {
      await themeManager.setPrimaryColor(Colors.red);
      expect(themeManager.primaryColor, equals(Colors.red));

      await themeManager.setSecondaryColor(Colors.redAccent);
      expect(themeManager.secondaryColor, equals(Colors.redAccent));
    });

    test('Material3切换测试', () async {
      await themeManager.setUseMaterial3(false);
      expect(themeManager.useMaterial3, isFalse);

      await themeManager.setUseMaterial3(true);
      expect(themeManager.useMaterial3, isTrue);
    });

    test('主题持久化测试', () async {
      // 设置主题
      await themeManager.setThemeMode(ThemeMode.dark);
      await themeManager.setPrimaryColor(Colors.red);
      await themeManager.setSecondaryColor(Colors.redAccent);
      await themeManager.setUseMaterial3(false);

      // 重新初始化
      await themeManager.initialize();

      // 验证主题设置是否保持
      expect(themeManager.themeMode, equals(ThemeMode.dark));
      expect(themeManager.primaryColor, equals(Colors.red));
      expect(themeManager.secondaryColor, equals(Colors.redAccent));
      expect(themeManager.useMaterial3, isFalse);
    });

    test('预设主题测试', () {
      expect(ThemeManager.presetThemes, isNotEmpty);
      expect(ThemeManager.presetThemes.first.name, equals('默认蓝'));
      expect(ThemeManager.presetThemes.first.primaryColor, equals(Colors.blue));
      expect(ThemeManager.presetThemes.first.secondaryColor, equals(Colors.blueAccent));
    });

    test('应用预设主题测试', () async {
      final preset = ThemeManager.presetThemes[1]; // 活力橙
      await themeManager.applyThemePreset(preset);

      expect(themeManager.primaryColor, equals(preset.primaryColor));
      expect(themeManager.secondaryColor, equals(preset.secondaryColor));
    });

    testWidgets('亮色主题应用测试', (WidgetTester tester) async {
      final lightTheme = themeManager.lightTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(),
        ),
      );

      final scaffold = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(scaffold.theme, equals(lightTheme));
      expect(scaffold.theme?.brightness, equals(Brightness.light));
      expect(scaffold.theme?.colorScheme.primary, equals(themeManager.primaryColor));
      expect(scaffold.theme?.colorScheme.secondary, equals(themeManager.secondaryColor));
    });

    testWidgets('暗色主题应用测试', (WidgetTester tester) async {
      final darkTheme = themeManager.darkTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const Scaffold(),
        ),
      );

      final scaffold = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(scaffold.theme, equals(darkTheme));
      expect(scaffold.theme?.brightness, equals(Brightness.dark));
      expect(scaffold.theme?.colorScheme.primary, equals(themeManager.primaryColor));
      expect(scaffold.theme?.colorScheme.secondary, equals(themeManager.secondaryColor));
    });

    testWidgets('主题切换通知测试', (WidgetTester tester) async {
      int notificationCount = 0;

      themeManager.addListener(() {
        notificationCount++;
      });

      await themeManager.setThemeMode(ThemeMode.dark);
      expect(notificationCount, equals(1));

      await themeManager.setPrimaryColor(Colors.red);
      expect(notificationCount, equals(2));

      await themeManager.setSecondaryColor(Colors.redAccent);
      expect(notificationCount, equals(3));

      await themeManager.setUseMaterial3(false);
      expect(notificationCount, equals(4));
    });

    test('主题序列化测试', () async {
      // 设置主题
      await themeManager.setPrimaryColor(Colors.red);
      await themeManager.setSecondaryColor(Colors.redAccent);
      await themeManager.setUseMaterial3(false);

      // 获取序列化数据
      final prefs = await SharedPreferences.getInstance();
      final customTheme = prefs.getString('custom_theme');

      expect(customTheme, isNotNull);
      expect(customTheme, contains('${Colors.red.value}'));
      expect(customTheme, contains('${Colors.redAccent.value}'));
      expect(customTheme, contains('false'));
    });

    test('主题反序列化测试', () async {
      // 设置序列化数据
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'custom_theme',
        '${Colors.purple.value}|${Colors.purpleAccent.value}|true',
      );

      // 重新初始化
      await themeManager.initialize();

      expect(themeManager.primaryColor, equals(Colors.purple));
      expect(themeManager.secondaryColor, equals(Colors.purpleAccent));
      expect(themeManager.useMaterial3, isTrue);
    });

    test('无效主题数据处理测试', () async {
      // 设置无效的序列化数据
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_theme', 'invalid_data');

      // 重新初始化
      await themeManager.initialize();

      // 验证使用默认值
      expect(themeManager.primaryColor, equals(Colors.blue));
      expect(themeManager.secondaryColor, equals(Colors.blueAccent));
      expect(themeManager.useMaterial3, isTrue);
    });
  });
} 