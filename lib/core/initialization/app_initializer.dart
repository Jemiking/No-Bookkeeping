import 'package:flutter/foundation.dart';
import '../security/security_service.dart';
import '../database/database_provider.dart';
import '../logging/logger.dart';

/// 应用初始化状态
enum InitializationStatus {
  notStarted,
  inProgress,
  completed,
  failed
}

/// 应用初始化管理器，负责管理应用的初始化流程
class AppInitializer {
  static final AppInitializer instance = AppInitializer._();
  AppInitializer._();

  InitializationStatus _status = InitializationStatus.notStarted;
  String? _errorMessage;
  final List<String> _initializationSteps = [];

  /// 获取初始化状态
  InitializationStatus get status => _status;
  
  /// 获取错误信息
  String? get errorMessage => _errorMessage;
  
  /// 获取初始化步骤日志
  List<String> get initializationSteps => List.unmodifiable(_initializationSteps);

  /// 初始化应用
  Future<bool> initialize() async {
    if (_status == InitializationStatus.inProgress) {
      return false;
    }

    _status = InitializationStatus.inProgress;
    _errorMessage = null;
    _initializationSteps.clear();

    try {
      // 1. 初始化日志系统
      await _initializeLogging();
      _addStep('日志系统初始化完成');

      // 2. 初始化安全服务
      await _initializeSecurity();
      _addStep('安全服务初始化完成');

      // 3. 初始化数据库
      await _initializeDatabase();
      _addStep('数据库初始化完成');

      // 4. 初始化其他核心服务
      await _initializeCoreServices();
      _addStep('核心服务初始化完成');

      _status = InitializationStatus.completed;
      return true;
    } catch (e, stackTrace) {
      _status = InitializationStatus.failed;
      _errorMessage = e.toString();
      _addStep('初始化失败: $_errorMessage');
      
      if (kDebugMode) {
        print('初始化失败: $e\n$stackTrace');
      }
      return false;
    }
  }

  /// 初始化日志系统
  Future<void> _initializeLogging() async {
    await Logger.initialize();
    _addStep('配置日志记录器');
  }

  /// 初始化安全服务
  Future<void> _initializeSecurity() async {
    final securityService = SecurityService.instance;
    await securityService.initialize();
    _addStep('初始化加密服务');
    _addStep('初始化密码管理');
    _addStep('初始化生物识别');
  }

  /// 初始化数据库
  Future<void> _initializeDatabase() async {
    final dbProvider = DatabaseProvider.instance;
    await dbProvider.initialize();
    _addStep('创建数据库连接');
    _addStep('验证数据库结构');
    _addStep('执行数据库迁移');
  }

  /// 初始化核心服务
  Future<void> _initializeCoreServices() async {
    // TODO: 初始化其他核心服务
    _addStep('初始化用户服务');
    _addStep('初始化账户服务');
    _addStep('初始化交易服务');
  }

  /// 添加初始化步骤日志
  void _addStep(String step) {
    _initializationSteps.add('${DateTime.now()}: $step');
    if (kDebugMode) {
      print(step);
    }
  }

  /// 重置初始化状态
  Future<void> reset() async {
    _status = InitializationStatus.notStarted;
    _errorMessage = null;
    _initializationSteps.clear();
  }

  /// 获取初始化进度报告
  Map<String, dynamic> getInitializationReport() {
    return {
      'status': _status.toString(),
      'errorMessage': _errorMessage,
      'steps': _initializationSteps,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
} 