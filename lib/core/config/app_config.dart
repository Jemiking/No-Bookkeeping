import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String appName = 'Money Tracker';
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  Future<void> initialize() async {
    // 在这里添加任何需要的配置初始化
  }
} 