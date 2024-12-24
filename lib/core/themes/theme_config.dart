import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class ThemeConfig {
  static const String _themePreferenceKey = 'theme_preference';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _primaryColorKey = 'primary_color';
  static const String _accentColorKey = 'accent_color';
  static const String _fontFamilyKey = 'font_family';

  // 默认主题配置
  static const Color defaultPrimaryColor = Colors.blue;
  static const Color defaultAccentColor = Colors.blueAccent;
  static const String defaultFontFamily = 'Roboto';

  // 预设主题列表
  static final List<ThemeData> presetThemes = [
    _createTheme(Colors.blue, Colors.blueAccent),
    _createTheme(Colors.green, Colors.greenAccent),
    _createTheme(Colors.purple, Colors.purpleAccent),
    _createTheme(Colors.orange, Colors.orangeAccent),
    _createTheme(Colors.red, Colors.redAccent),
  ];

  // 创建主题
  static ThemeData _createTheme(Color primaryColor, Color accentColor, {bool isDark = false}) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      fontFamily: defaultFontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }

  // 保存主题配置
  static Future<void> saveThemePreference({
    required bool isDarkMode,
    required Color primaryColor,
    required Color accentColor,
    String? fontFamily,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDarkMode);
    await prefs.setInt(_primaryColorKey, primaryColor.value);
    await prefs.setInt(_accentColorKey, accentColor.value);
    if (fontFamily != null) {
      await prefs.setString(_fontFamilyKey, fontFamily);
    }
  }

  // 加载主题配置
  static Future<ThemeData> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_isDarkModeKey) ?? false;
    final primaryColorValue = prefs.getInt(_primaryColorKey) ?? defaultPrimaryColor.value;
    final accentColorValue = prefs.getInt(_accentColorKey) ?? defaultAccentColor.value;
    final fontFamily = prefs.getString(_fontFamilyKey) ?? defaultFontFamily;

    return _createTheme(
      Color(primaryColorValue),
      Color(accentColorValue),
      isDark: isDarkMode,
    );
  }

  // 重置主题配置
  static Future<void> resetThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isDarkModeKey);
    await prefs.remove(_primaryColorKey);
    await prefs.remove(_accentColorKey);
    await prefs.remove(_fontFamilyKey);
  }

  // 获取当前主题配置
  static Future<Map<String, dynamic>> getCurrentThemeConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isDarkMode': prefs.getBool(_isDarkModeKey) ?? false,
      'primaryColor': Color(prefs.getInt(_primaryColorKey) ?? defaultPrimaryColor.value),
      'accentColor': Color(prefs.getInt(_accentColorKey) ?? defaultAccentColor.value),
      'fontFamily': prefs.getString(_fontFamilyKey) ?? defaultFontFamily,
    };
  }

  // 导出主题配置
  static Future<Map<String, dynamic>> exportThemeConfig() async {
    final config = await getCurrentThemeConfig();
    return {
      'isDarkMode': config['isDarkMode'],
      'primaryColor': config['primaryColor'].value.toRadixString(16),
      'accentColor': config['accentColor'].value.toRadixString(16),
      'fontFamily': config['fontFamily'],
    };
  }

  // 导入主题配置
  static Future<void> importThemeConfig(Map<String, dynamic> config) async {
    await saveThemePreference(
      isDarkMode: config['isDarkMode'] as bool,
      primaryColor: Color(int.parse(config['primaryColor'], radix: 16)),
      accentColor: Color(int.parse(config['accentColor'], radix: 16)),
      fontFamily: config['fontFamily'] as String?,
    );
  }
} 