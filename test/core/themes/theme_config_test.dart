import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_tracker/core/themes/theme_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeConfig Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('预设主题列表不为空', () {
      expect(ThemeConfig.presetThemes, isNotEmpty);
      expect(ThemeConfig.presetThemes.length, equals(5));
    });

    test('保存和加载主题配置', () async {
      // 保存主题配置
      await ThemeConfig.saveThemePreference(
        isDarkMode: true,
        primaryColor: Colors.red,
        accentColor: Colors.redAccent,
        fontFamily: 'TestFont',
      );

      // 加载主题配置
      final theme = await ThemeConfig.loadThemePreference();

      // 验证主题配置
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.primaryColor, equals(Colors.red));
      expect(theme.fontFamily, equals('TestFont'));
    });

    test('重置主题配置', () async {
      // 先保存一些配置
      await ThemeConfig.saveThemePreference(
        isDarkMode: true,
        primaryColor: Colors.red,
        accentColor: Colors.redAccent,
        fontFamily: 'TestFont',
      );

      // 重置配置
      await ThemeConfig.resetThemePreference();

      // 加载配置并验证是否恢复默认值
      final theme = await ThemeConfig.loadThemePreference();
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.primaryColor, equals(ThemeConfig.defaultPrimaryColor));
      expect(theme.fontFamily, equals(ThemeConfig.defaultFontFamily));
    });

    test('获取当前主题配置', () async {
      // 保存配置
      await ThemeConfig.saveThemePreference(
        isDarkMode: true,
        primaryColor: Colors.red,
        accentColor: Colors.redAccent,
        fontFamily: 'TestFont',
      );

      // 获取当前配置
      final config = await ThemeConfig.getCurrentThemeConfig();

      // 验证配置
      expect(config['isDarkMode'], isTrue);
      expect(config['primaryColor'], equals(Colors.red));
      expect(config['accentColor'], equals(Colors.redAccent));
      expect(config['fontFamily'], equals('TestFont'));
    });

    test('导出和导入主题配置', () async {
      // 保存初始配置
      await ThemeConfig.saveThemePreference(
        isDarkMode: true,
        primaryColor: Colors.red,
        accentColor: Colors.redAccent,
        fontFamily: 'TestFont',
      );

      // 导出配置
      final exportedConfig = await ThemeConfig.exportThemeConfig();

      // 重置配置
      await ThemeConfig.resetThemePreference();

      // 导入之前导出的配置
      await ThemeConfig.importThemeConfig(exportedConfig);

      // 获取当前配置并验证
      final currentConfig = await ThemeConfig.getCurrentThemeConfig();
      expect(currentConfig['isDarkMode'], isTrue);
      expect(currentConfig['primaryColor'], equals(Colors.red));
      expect(currentConfig['accentColor'], equals(Colors.redAccent));
      expect(currentConfig['fontFamily'], equals('TestFont'));
    });

    test('默认主题配置', () async {
      // 不保存任何配置，直接加载
      final theme = await ThemeConfig.loadThemePreference();

      // 验证默认配置
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.primaryColor, equals(ThemeConfig.defaultPrimaryColor));
      expect(theme.fontFamily, equals(ThemeConfig.defaultFontFamily));
    });

    test('主题配置的持久化', () async {
      // 保存配置
      await ThemeConfig.saveThemePreference(
        isDarkMode: true,
        primaryColor: Colors.purple,
        accentColor: Colors.purpleAccent,
        fontFamily: 'PersistentFont',
      );

      // 清除内存中的实例
      await SharedPreferences.getInstance().then((prefs) => prefs.clear());

      // 重新初始化SharedPreferences并加载配置
      SharedPreferences.setMockInitialValues({
        'is_dark_mode': true,
        'primary_color': Colors.purple.value,
        'accent_color': Colors.purpleAccent.value,
        'font_family': 'PersistentFont',
      });

      // 加载配置并验证
      final theme = await ThemeConfig.loadThemePreference();
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.primaryColor, equals(Colors.purple));
      expect(theme.fontFamily, equals('PersistentFont'));
    });
  });
} 