import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderConfig {
  final bool enableAbnormalReminder;
  final bool enablePeriodicReminder;
  final Duration checkInterval;
  final List<TimeOfDay> dailyRemindTimes;
  final double abnormalThreshold;

  ReminderConfig({
    this.enableAbnormalReminder = true,
    this.enablePeriodicReminder = true,
    this.checkInterval = const Duration(minutes: 30),
    this.dailyRemindTimes = const [],
    this.abnormalThreshold = 0.5, // 50%的变化被视为异常
  });
}

class ReminderService {
  final ReminderConfig config;
  final FlutterLocalNotificationsPlugin _notifications;
  Timer? _checkTimer;
  bool _isInitialized = false;

  ReminderService(this.config) : _notifications = FlutterLocalNotificationsPlugin();

  // 初始化提醒服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 初始化通知插件
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 启动定时检查
    if (config.enableAbnormalReminder || config.enablePeriodicReminder) {
      _startPeriodicCheck();
    }

    // 设置每日定时提醒
    if (config.enablePeriodicReminder) {
      await _scheduleDailyReminders();
    }

    _isInitialized = true;
  }

  // 处理通知点击事件
  void _onNotificationTapped(NotificationResponse response) {
    // 处理通知点击事件
  }

  // 启动定期检查
  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(config.checkInterval, (_) {
      _checkAbnormalConditions();
    });
  }

  // 检查异常情况
  Future<void> _checkAbnormalConditions() async {
    if (!config.enableAbnormalReminder) return;

    try {
      // 检查支出异常
      await _checkExpenseAbnormal();
      
      // 检查收入异常
      await _checkIncomeAbnormal();
      
      // 检查余额异常
      await _checkBalanceAbnormal();
      
      // 检查预算超支
      await _checkBudgetOverspend();
      
      // 检查账户安全
      await _checkAccountSecurity();
    } catch (e) {
      print('检查异常情况时出错: $e');
    }
  }

  // 检查支出异常
  Future<void> _checkExpenseAbnormal() async {
    try {
      // 获取最近的支出数据
      final recentExpenses = await _getRecentExpenses();
      
      // 计算平均支出
      final averageExpense = _calculateAverage(recentExpenses);
      
      // 获取最新支出
      final latestExpense = await _getLatestExpense();
      
      // 检查是否超过阈值
      if (_isAbnormal(latestExpense, averageExpense)) {
        await _showAbnormalExpenseNotification(
          latestExpense,
          averageExpense,
        );
      }
    } catch (e) {
      print('检查支出异常时出错: $e');
    }
  }

  // 检查收入异常
  Future<void> _checkIncomeAbnormal() async {
    try {
      // 获取最近的收入数据
      final recentIncomes = await _getRecentIncomes();
      
      // 计算平均收入
      final averageIncome = _calculateAverage(recentIncomes);
      
      // 获取最新收入
      final latestIncome = await _getLatestIncome();
      
      // 检查是否超过阈值
      if (_isAbnormal(latestIncome, averageIncome)) {
        await _showAbnormalIncomeNotification(
          latestIncome,
          averageIncome,
        );
      }
    } catch (e) {
      print('检查收入异常时出错: $e');
    }
  }

  // 检查余额异常
  Future<void> _checkBalanceAbnormal() async {
    try {
      // 获取账户余额历史
      final balanceHistory = await _getBalanceHistory();
      
      // 计算平均余额
      final averageBalance = _calculateAverage(balanceHistory);
      
      // 获取当前余额
      final currentBalance = await _getCurrentBalance();
      
      // 检查是否超过阈值
      if (_isAbnormal(currentBalance, averageBalance)) {
        await _showAbnormalBalanceNotification(
          currentBalance,
          averageBalance,
        );
      }
    } catch (e) {
      print('检查余额异常时出错: $e');
    }
  }

  // 检查预算超支
  Future<void> _checkBudgetOverspend() async {
    try {
      // 获取所有预算
      final budgets = await _getAllBudgets();
      
      // 检查每个预算的使用情况
      for (final budget in budgets) {
        final usage = await _getBudgetUsage(budget);
        if (usage > 1.0) { // 超过100%
          await _showBudgetOverspendNotification(budget, usage);
        } else if (usage > 0.8) { // 超过80%
          await _showBudgetWarningNotification(budget, usage);
        }
      }
    } catch (e) {
      print('检查预算超支时出错: $e');
    }
  }

  // 检查账户安全
  Future<void> _checkAccountSecurity() async {
    try {
      // 检查异常登录
      final hasAbnormalLogin = await _checkAbnormalLogin();
      if (hasAbnormalLogin) {
        await _showSecurityWarningNotification('检测到异常登录');
      }
      
      // 检查数据同步状态
      final syncStatus = await _checkSyncStatus();
      if (!syncStatus.isSuccess) {
        await _showSecurityWarningNotification('数据同步失败');
      }
      
      // 检查数据备份状态
      final backupStatus = await _checkBackupStatus();
      if (!backupStatus.isSuccess) {
        await _showSecurityWarningNotification('数据备份失败');
      }
    } catch (e) {
      print('检查账户安全时出错: $e');
    }
  }

  // 设置每日定时提醒
  Future<void> _scheduleDailyReminders() async {
    if (!config.enablePeriodicReminder) return;

    for (final time in config.dailyRemindTimes) {
      final id = time.hour * 60 + time.minute;
      
      await _notifications.zonedSchedule(
        id,
        '记账提醒',
        '该记录今天的收支了',
        _nextInstanceOfTime(time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            '每日提醒',
            channelDescription: '每日记账提醒',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // 显示异常支出通知
  Future<void> _showAbnormalExpenseNotification(
    double latestExpense,
    double averageExpense,
  ) async {
    await _notifications.show(
      0,
      '支出异常提醒',
      '检测到异常支出：￥$latestExpense\n平均支出：￥$averageExpense',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'abnormal_expense',
          '支出异常',
          channelDescription: '支出异常提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // 显示异常收入通知
  Future<void> _showAbnormalIncomeNotification(
    double latestIncome,
    double averageIncome,
  ) async {
    await _notifications.show(
      1,
      '收入异常提醒',
      '检测到异常收入：￥$latestIncome\n平均收入：￥$averageIncome',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'abnormal_income',
          '收入异常',
          channelDescription: '收入异常提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // 显示异常余额通知
  Future<void> _showAbnormalBalanceNotification(
    double currentBalance,
    double averageBalance,
  ) async {
    await _notifications.show(
      2,
      '余额异常提醒',
      '检测到余额异常变动：￥$currentBalance\n平均余额：￥$averageBalance',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'abnormal_balance',
          '余额异常',
          channelDescription: '余额异常提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // 显示预算超支通知
  Future<void> _showBudgetOverspendNotification(
    dynamic budget,
    double usage,
  ) async {
    await _notifications.show(
      3,
      '预算超支提醒',
      '${budget.name}预算已超支：${(usage * 100).toStringAsFixed(1)}%',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_overspend',
          '预算超支',
          channelDescription: '预算超支提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // 显示预算警告通知
  Future<void> _showBudgetWarningNotification(
    dynamic budget,
    double usage,
  ) async {
    await _notifications.show(
      4,
      '预算警告提醒',
      '${budget.name}预算使用已达：${(usage * 100).toStringAsFixed(1)}%',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_warning',
          '预算警告',
          channelDescription: '预算警告提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // 显示安全警告通知
  Future<void> _showSecurityWarningNotification(String message) async {
    await _notifications.show(
      5,
      '安全警告',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'security_warning',
          '安全警告',
          channelDescription: '安全警告提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // 计算下一个提醒时间
  TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = TZDateTime.now(local);
    var scheduledDate = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // 判断是否异常
  bool _isAbnormal(double current, double average) {
    if (average == 0) return false;
    return (current - average).abs() / average > config.abnormalThreshold;
  }

  // 计算平均值
  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  // 获取最近的支出数据
  Future<List<double>> _getRecentExpenses() async {
    // 实现获取最近支出数据的逻辑
    return [];
  }

  // 获取最新支出
  Future<double> _getLatestExpense() async {
    // 实现获取最新支出的逻辑
    return 0;
  }

  // 获取最近的收入数据
  Future<List<double>> _getRecentIncomes() async {
    // 实现获取最近收入数据的逻辑
    return [];
  }

  // 获取最新收入
  Future<double> _getLatestIncome() async {
    // 实现获取最新收入的逻辑
    return 0;
  }

  // 获取余额历史
  Future<List<double>> _getBalanceHistory() async {
    // 实现获取余额历史的逻辑
    return [];
  }

  // 获取当前余额
  Future<double> _getCurrentBalance() async {
    // 实现获取当前余额的逻辑
    return 0;
  }

  // 获取所有预算
  Future<List<dynamic>> _getAllBudgets() async {
    // 实现获取所有预算的逻辑
    return [];
  }

  // 获取预算使用情况
  Future<double> _getBudgetUsage(dynamic budget) async {
    // 实现获取预算使用情况的逻辑
    return 0;
  }

  // 检查异常登录
  Future<bool> _checkAbnormalLogin() async {
    // 实现检查异常登录的逻辑
    return false;
  }

  // 检查同步状态
  Future<SyncStatus> _checkSyncStatus() async {
    // 实现检查同步状态的逻辑
    return SyncStatus(isSuccess: true, message: '');
  }

  // 检查备份状态
  Future<BackupStatus> _checkBackupStatus() async {
    // 实现检查备份状态的逻辑
    return BackupStatus(isSuccess: true, message: '');
  }

  // 销毁服务
  void dispose() {
    _checkTimer?.cancel();
  }
}

class SyncStatus {
  final bool isSuccess;
  final String message;

  SyncStatus({
    required this.isSuccess,
    required this.message,
  });
}

class BackupStatus {
  final bool isSuccess;
  final String message;

  BackupStatus({
    required this.isSuccess,
    required this.message,
  });
} 