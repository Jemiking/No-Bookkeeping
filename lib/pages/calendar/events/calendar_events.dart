import 'package:flutter/foundation.dart';
import '../models/calendar_state.dart';

// 日历事件基类
abstract class CalendarEvent {}

// 日期选择事件
class DateSelectedEvent extends CalendarEvent {
  final DateTime date;
  DateSelectedEvent(this.date);
}

// 视图模式切换事件
class ViewModeChangedEvent extends CalendarEvent {
  final CalendarViewMode mode;
  ViewModeChangedEvent(this.mode);
}

// 月份切换事件
class MonthChangedEvent extends CalendarEvent {
  final DateTime month;
  MonthChangedEvent(this.month);
}

// 周切换事件
class WeekChangedEvent extends CalendarEvent {
  final DateTime week;
  WeekChangedEvent(this.week);
}

// 展开/收缩事件
class CalendarExpandedEvent extends CalendarEvent {
  final bool isExpanded;
  CalendarExpandedEvent(this.isExpanded);
}

// 交易相关事件
class TransactionAddedEvent extends CalendarEvent {
  final DateTime date;
  final double amount;
  final String category;
  TransactionAddedEvent(this.date, this.amount, this.category);
}

class TransactionUpdatedEvent extends CalendarEvent {
  final String id;
  final DateTime date;
  final double amount;
  final String category;
  TransactionUpdatedEvent(this.id, this.date, this.amount, this.category);
}

class TransactionDeletedEvent extends CalendarEvent {
  final String id;
  TransactionDeletedEvent(this.id);
}

class DailyTransactionsLoadedEvent extends CalendarEvent {
  final DateTime date;
  final List<dynamic> transactions;
  DailyTransactionsLoadedEvent(this.date, this.transactions);
}

// 事件总线
class CalendarEventBus extends ChangeNotifier {
  final Map<Type, List<Function(CalendarEvent)>> _typeListeners = {};
  final List<Function(CalendarEvent)> _globalListeners = [];
  
  void addEventListener(Function(CalendarEvent) listener, {Type? eventType}) {
    if (eventType != null) {
      _typeListeners.putIfAbsent(eventType, () => []).add(listener);
    } else {
      _globalListeners.add(listener);
    }
  }
  
  void removeEventListener(Function(CalendarEvent) listener, {Type? eventType}) {
    if (eventType != null) {
      _typeListeners[eventType]?.remove(listener);
    } else {
      _globalListeners.remove(listener);
    }
  }
  
  void fireEvent(CalendarEvent event) {
    // 调用特定类型的监听器
    _typeListeners[event.runtimeType]?.forEach((listener) => listener(event));
    // 调用全局监听器
    _globalListeners.forEach((listener) => listener(event));
    notifyListeners();
  }
  
  @override
  void dispose() {
    _typeListeners.clear();
    _globalListeners.clear();
    super.dispose();
  }
}

// 事件处理器 Mixin
mixin CalendarEventHandler {
  final CalendarEventBus eventBus = CalendarEventBus();
  
  void handleEvent(CalendarEvent event) {
    if (event is DateSelectedEvent) {
      onDateSelected(event.date);
    } else if (event is ViewModeChangedEvent) {
      onViewModeChanged(event.mode);
    } else if (event is MonthChangedEvent) {
      onMonthChanged(event.month);
    } else if (event is WeekChangedEvent) {
      onWeekChanged(event.week);
    } else if (event is CalendarExpandedEvent) {
      onCalendarExpanded(event.isExpanded);
    } else if (event is TransactionAddedEvent) {
      onTransactionAdded(event.date, event.amount, event.category);
    } else if (event is TransactionUpdatedEvent) {
      onTransactionUpdated(event.id, event.date, event.amount, event.category);
    } else if (event is TransactionDeletedEvent) {
      onTransactionDeleted(event.id);
    } else if (event is DailyTransactionsLoadedEvent) {
      onDailyTransactionsLoaded(event.date, event.transactions);
    }
  }
  
  void onDateSelected(DateTime date) {}
  void onViewModeChanged(CalendarViewMode mode) {}
  void onMonthChanged(DateTime month) {}
  void onWeekChanged(DateTime week) {}
  void onCalendarExpanded(bool isExpanded) {}
  
  void onTransactionAdded(DateTime date, double amount, String category) {}
  void onTransactionUpdated(String id, DateTime date, double amount, String category) {}
  void onTransactionDeleted(String id) {}
  void onDailyTransactionsLoaded(DateTime date, List<dynamic> transactions) {}
  
  void dispose() {
    eventBus.dispose();
  }
} 