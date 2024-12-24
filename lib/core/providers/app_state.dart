import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';
import '../../services/database_service.dart';
import '../utils/shared_preferences_helper.dart';

enum InitializationStatus {
  notStarted,
  inProgress,
  completed,
  error,
}

class AppState extends ChangeNotifier {
  final ThemeManager themeManager;
  final DatabaseService _databaseService;
  final SharedPreferencesHelper _prefsHelper;
  
  InitializationStatus _status = InitializationStatus.notStarted;
  String? _errorMessage;
  String _initializationStep = '';
  
  AppState()
      : themeManager = ThemeManager(),
        _databaseService = DatabaseService(),
        _prefsHelper = SharedPreferencesHelper();

  InitializationStatus get status => _status;
  bool get isInitialized => _status == InitializationStatus.completed;
  bool get hasError => _status == InitializationStatus.error;
  String? get errorMessage => _errorMessage;
  String get initializationStatus => _initializationStep;

  Future<void> initialize() async {
    if (_status == InitializationStatus.inProgress) return;
    
    _status = InitializationStatus.inProgress;
    _errorMessage = null;
    notifyListeners();

    try {
      // 初始化SharedPreferences
      _updateStatus('正在加载配置...');
      await _prefsHelper.initialize();

      // 初始化主题
      _updateStatus('正在初始化主题...');
      await _initializeTheme();

      // 初始化数据库
      _updateStatus('正在初始化数据库...');
      await _databaseService.initialize();

      _status = InitializationStatus.completed;
      notifyListeners();
    } catch (e) {
      _status = InitializationStatus.error;
      _errorMessage = '初始化失败: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _initializeTheme() async {
    final savedThemeMode = await _prefsHelper.getThemeMode();
    themeManager.setThemeMode(savedThemeMode ?? ThemeMode.system);
  }

  void _updateStatus(String step) {
    _initializationStep = step;
    notifyListeners();
  }

  Future<void> retryInitialization() async {
    await initialize();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    themeManager.setThemeMode(mode);
    await _prefsHelper.saveThemeMode(mode);
    notifyListeners();
  }
} 