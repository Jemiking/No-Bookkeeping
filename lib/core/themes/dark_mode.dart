import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class DarkModeConfig {
  static const String _darkModeKey = 'dark_mode_preference';
  static const String _followSystemKey = 'follow_system_theme';
  static const String _autoDarkModeKey = 'auto_dark_mode';
  static const String _darkModeStartTimeKey = 'dark_mode_start_time';
  static const String _darkModeEndTimeKey = 'dark_mode_end_time';

  // 获取暗黑模式状态
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final followSystem = prefs.getBool(_followSystemKey) ?? true;
    
    if (followSystem) {
      // 跟随系统主题
      return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    }

    final autoDarkMode = prefs.getBool(_autoDarkModeKey) ?? false;
    if (autoDarkMode) {
      // 自动切换暗黑模式
      return _isInDarkModeTimeRange();
    }

    // 手动设置的暗黑模式状态
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // 设置暗黑模式状态
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
    await prefs.setBool(_followSystemKey, false);
    await prefs.setBool(_autoDarkModeKey, false);
  }

  // 设置是否跟随系统主题
  static Future<void> setFollowSystem(bool follow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_followSystemKey, follow);
    if (follow) {
      await prefs.setBool(_autoDarkModeKey, false);
    }
  }

  // 获取是否跟随系统主题
  static Future<bool> isFollowingSystem() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_followSystemKey) ?? true;
  }

  // 设置自动暗黑模式
  static Future<void> setAutoDarkMode(bool auto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoDarkModeKey, auto);
    if (auto) {
      await prefs.setBool(_followSystemKey, false);
    }
  }

  // 获取是否启用自动暗黑模式
  static Future<bool> isAutoDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoDarkModeKey) ?? false;
  }

  // 设置暗黑模式时间范围
  static Future<void> setDarkModeTimeRange(TimeOfDay startTime, TimeOfDay endTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_darkModeStartTimeKey, '${startTime.hour}:${startTime.minute}');
    await prefs.setString(_darkModeEndTimeKey, '${endTime.hour}:${endTime.minute}');
  }

  // 获取暗黑模式时间范围
  static Future<Map<String, TimeOfDay>> getDarkModeTimeRange() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeStr = prefs.getString(_darkModeStartTimeKey) ?? '22:00';
    final endTimeStr = prefs.getString(_darkModeEndTimeKey) ?? '06:00';

    final startTimeParts = startTimeStr.split(':');
    final endTimeParts = endTimeStr.split(':');

    return {
      'startTime': TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      'endTime': TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
    };
  }

  // 检查当前时间是否在暗黑模式时间范围内
  static Future<bool> _isInDarkModeTimeRange() async {
    final timeRange = await getDarkModeTimeRange();
    final now = TimeOfDay.now();
    final startTime = timeRange['startTime']!;
    final endTime = timeRange['endTime']!;

    // 将时间转换为分钟数进行比较
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes <= endMinutes) {
      // 时间范围在同一天内
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      // 时间范围跨越午夜
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }

  // 获取暗黑模式主题数据
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue[700]!,
        secondary: Colors.blue[500]!,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: Colors.red[700]!,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white70),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      dividerColor: Colors.white12,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
} 