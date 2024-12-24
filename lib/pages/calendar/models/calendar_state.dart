import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:async';
import '../events/calendar_events.dart';

enum CalendarViewMode {
  month,
  week,
}

class CalendarState extends ChangeNotifier with CalendarEventHandler {
  static const int CACHE_SIZE_LIMIT = 100;
  static const Duration DEBOUNCE_DURATION = Duration(milliseconds: 300);
  
  DateTime _selectedDate;
  bool _isExpanded;
  CalendarViewMode _viewMode;
  Map<DateTime, List<dynamic>> _transactionCache = {};
  bool _isLoading = false;
  DateTime? _lastLoadTime;
  Timer? _debounceTimer;
  
  // 构造函数
  CalendarState({
    DateTime? initialDate,
    bool isExpanded = true,
    CalendarViewMode viewMode = CalendarViewMode.month,
  }) : 
    _selectedDate = initialDate ?? DateTime.now(),
    _isExpanded = isExpanded,
    _viewMode = viewMode {
    eventBus.addEventListener(handleEvent);
    // 立即加载当前月的数据
    _initializeData();
  }
  
  // 初始化数据
  void _initializeData() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    
    // 立即生成并缓存本月所有日期的数据
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(now.year, now.month, day);
      final key = DateTime(date.year, date.month, date.day);
      
      if (day % 3 == 0) {
        _transactionCache[key] = [
          {'id': '1', 'amount': -35.0, 'category': '餐饮', 'time': '12:30', 'note': '银行'},
          {'id': '2', 'amount': -35.0, 'category': '餐饮', 'time': '12:30', 'note': '银行'},
        ];
      } else {
        _transactionCache[key] = [];
      }
    }
    
    // 通知监听器数据已更新
    notifyListeners();
  }
  
  // Getters
  DateTime get selectedDate => _selectedDate;
  bool get isExpanded => _isExpanded;
  CalendarViewMode get viewMode => _viewMode;
  bool get isLoading => _isLoading;
  List<dynamic> get currentDayTransactions => 
      _transactionCache[_selectedDate] ?? [];
  
  // 缓存管理
  void _cleanupCache() {
    if (_transactionCache.length > CACHE_SIZE_LIMIT) {
      final sortedDates = _transactionCache.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      
      for (var i = CACHE_SIZE_LIMIT; i < sortedDates.length; i++) {
        _transactionCache.remove(sortedDates[i]);
      }
    }
  }
  
  bool _shouldReload(DateTime date) {
    if (_lastLoadTime == null) return true;
    
    final now = DateTime.now();
    final timeDiff = now.difference(_lastLoadTime!);
    return timeDiff.inMinutes >= 5 || date.day != _lastLoadTime!.day;
  }
  
  // 加载整个月的数据
  Future<void> _loadMonthData(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final firstDay = DateTime(date.year, date.month, 1);
      final lastDay = DateTime(date.year, date.month + 1, 0);
      
      // 加载当前月所有日期的数据，但不清除现有数据
      for (int day = 1; day <= lastDay.day; day++) {
        final currentDate = DateTime(date.year, date.month, day);
        final key = DateTime(currentDate.year, currentDate.month, currentDate.day);
        
        // 如果缓存中没有该日期的数据，则初始化为空列表
        if (!_transactionCache.containsKey(key)) {
          _transactionCache[key] = [];
        }
      }
      
      _lastLoadTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      print('加载月度数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 修改月份切换时的数据加载
  void _handleMonthChange(DateTime newDate) {
    _loadMonthData(newDate);
  }
  
  // 事务相关方法
  Future<void> _loadTransactionsForDate(DateTime date) async {
    if (_isLoading) return;
    
    final key = DateTime(date.year, date.month, date.day);
    // 如果缓存中有数据且不需要重新加载，直接返回
    if (_transactionCache.containsKey(key) && !_shouldReload(date)) {
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // TODO: 实现从数据库加载数据的逻辑
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 临时使用模拟数据
      if (date.day % 3 == 0) {
        _transactionCache[key] = [
          {'id': '1', 'amount': -35.0, 'category': '餐饮', 'time': '12:30', 'note': '银行'},
          {'id': '2', 'amount': -35.0, 'category': '餐饮', 'time': '12:30', 'note': '银行'},
        ];
      } else {
        _transactionCache[key] = [];
      }
      
      _lastLoadTime = DateTime.now();
      _cleanupCache();
      
      eventBus.fireEvent(DailyTransactionsLoadedEvent(date, _transactionCache[key] ?? []));
    } catch (e) {
      print('加载交易数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addTransaction(double amount, String category, {String note = '', DateTime? date}) async {
    try {
      final transactionDate = date ?? _selectedDate;
      final key = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
      final now = DateTime.now();
      final transaction = {
        'id': now.millisecondsSinceEpoch.toString(),
        'amount': amount,
        'category': category,
        'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'note': note,
        'date': transactionDate,
      };
      
      // 确保缓存中有该日期的列表
      if (!_transactionCache.containsKey(key)) {
        _transactionCache[key] = [];
      }
      
      // 添加新交易
      _transactionCache[key]!.add(transaction);
      
      // 如果添加的是不同日期的交易，切换到该日期
      if (date != null && date != _selectedDate) {
        selectDate(date);
      }
      
      // 触发事件和更新
      eventBus.fireEvent(TransactionAddedEvent(transactionDate, amount, category));
      notifyListeners();
      
      // 延迟一下再加载当前月的数据，确保新添加的交易已经被正确处理
      await Future.delayed(const Duration(milliseconds: 100));
      await _loadTransactionsForDate(transactionDate);
    } catch (e) {
      print('添加交易失败: $e');
      rethrow;
    }
  }
  
  Future<void> updateTransaction(String id, double amount, String category) async {
    try {
      // TODO: 实现更新交易的逻辑
      await Future.delayed(const Duration(milliseconds: 300));
      
      eventBus.fireEvent(TransactionUpdatedEvent(id, _selectedDate, amount, category));
      // 强制重新加载以确保数据一致性
      _transactionCache.remove(_selectedDate);
      await _loadTransactionsForDate(_selectedDate);
    } catch (e) {
      print('更新交易失败: $e');
    }
  }
  
  Future<void> deleteTransaction(String id) async {
    try {
      // TODO: 实现删除交易的逻辑
      await Future.delayed(const Duration(milliseconds: 300));
      
      eventBus.fireEvent(TransactionDeletedEvent(id));
      // 强制重新加载以确保数据一致性
      _transactionCache.remove(_selectedDate);
      await _loadTransactionsForDate(_selectedDate);
    } catch (e) {
      print('删除交易失败: $e');
    }
  }
  
  // 重写事件处理方法
  @override
  void onDateSelected(DateTime date) {
    super.onDateSelected(date);
    _loadTransactionsForDate(date);
  }
  
  @override
  void onMonthChanged(DateTime month) {
    super.onMonthChanged(month);
    _handleMonthChange(month);
  }
  
  @override
  void onWeekChanged(DateTime week) {
    super.onWeekChanged(week);
    _loadTransactionsForDate(week);
  }
  
  @override
  void onTransactionAdded(DateTime date, double amount, String category) {
    super.onTransactionAdded(date, amount, category);
    _loadTransactionsForDate(date);
  }
  
  @override
  void onTransactionUpdated(String id, DateTime date, double amount, String category) {
    super.onTransactionUpdated(id, date, amount, category);
    _loadTransactionsForDate(date);
  }
  
  @override
  void onTransactionDeleted(String id) {
    super.onTransactionDeleted(id);
    _loadTransactionsForDate(_selectedDate);
  }
  
  // 清理资源
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _transactionCache.clear();
    super.dispose();
  }
  
  // 日历视图控制方法
  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void previousMonth() {
    final newDate = DateTime(
      _selectedDate.year,
      _selectedDate.month - 1,
      math.min(_selectedDate.day, DateTime(_selectedDate.year, _selectedDate.month - 1, 0).day),
    );
    selectDate(newDate);
  }

  void nextMonth() {
    final newDate = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      math.min(_selectedDate.day, DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day),
    );
    selectDate(newDate);
  }

  void previousWeek() {
    selectDate(_selectedDate.subtract(const Duration(days: 7)));
  }

  void nextWeek() {
    selectDate(_selectedDate.add(const Duration(days: 7)));
  }

  void selectDate(DateTime date) {
    if (_selectedDate == date) return;
    _selectedDate = date;
    _loadTransactionsForDate(date);
    notifyListeners();
    eventBus.fireEvent(DateSelectedEvent(date));
  }

  // 获取指定日期的交易数据
  List<dynamic> getTransactionsForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _transactionCache[key] ?? [];
  }

  // 获取指定日期的收支总额
  Map<String, double> getDayTotal(DateTime date) {
    final transactions = getTransactionsForDate(date);
    double income = 0;
    double expense = 0;
    
    for (final transaction in transactions) {
      if (transaction['amount'] > 0) {
        income += transaction['amount'];
      } else {
        expense += transaction['amount'].abs();
      }
    }
    
    return {
      'income': income,
      'expense': expense,
    };
  }
} 