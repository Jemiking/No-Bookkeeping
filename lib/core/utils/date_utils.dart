import '../../features/statistics/domain/statistics_engine.dart';

/// 生成时间区间列表
List<DateTime> generatePeriods(
  DateTime startDate,
  DateTime endDate,
  StatisticsPeriod period,
) {
  final periods = <DateTime>[];
  var currentDate = startDate;

  while (currentDate.isBefore(endDate)) {
    periods.add(currentDate);
    currentDate = getNextPeriod(currentDate, period);
  }

  return periods;
}

/// 获取下一个时间区间的起始时间
DateTime getNextPeriod(DateTime date, StatisticsPeriod period) {
  switch (period) {
    case StatisticsPeriod.day:
      return DateTime(date.year, date.month, date.day + 1);
    case StatisticsPeriod.week:
      return DateTime(date.year, date.month, date.day + 7);
    case StatisticsPeriod.month:
      return DateTime(date.year, date.month + 1, 1);
    case StatisticsPeriod.quarter:
      return DateTime(date.year, date.month + 3, 1);
    case StatisticsPeriod.year:
      return DateTime(date.year + 1, 1, 1);
    case StatisticsPeriod.custom:
      return date; // 自定义周期需要外部指定
  }
}

/// 获取上一个时间区间的起始时间
DateTime getPreviousPeriod(DateTime date, StatisticsPeriod period) {
  switch (period) {
    case StatisticsPeriod.day:
      return DateTime(date.year, date.month, date.day - 1);
    case StatisticsPeriod.week:
      return DateTime(date.year, date.month, date.day - 7);
    case StatisticsPeriod.month:
      return DateTime(date.year, date.month - 1, 1);
    case StatisticsPeriod.quarter:
      return DateTime(date.year, date.month - 3, 1);
    case StatisticsPeriod.year:
      return DateTime(date.year - 1, 1, 1);
    case StatisticsPeriod.custom:
      return date; // 自定义周期需要外部指定
  }
}

/// 减去一年
DateTime minusOneYear(DateTime date) {
  return DateTime(date.year - 1, date.month, date.day);
}

/// 获取时间区间的结束时间
DateTime getPeriodEndDate(DateTime startDate, StatisticsPeriod period) {
  switch (period) {
    case StatisticsPeriod.day:
      return DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59);
    case StatisticsPeriod.week:
      final endDate = startDate.add(const Duration(days: 6));
      return DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    case StatisticsPeriod.month:
      final nextMonth = DateTime(startDate.year, startDate.month + 1, 1);
      return nextMonth.subtract(const Duration(seconds: 1));
    case StatisticsPeriod.quarter:
      final nextQuarter = DateTime(startDate.year, startDate.month + 3, 1);
      return nextQuarter.subtract(const Duration(seconds: 1));
    case StatisticsPeriod.year:
      final nextYear = DateTime(startDate.year + 1, 1, 1);
      return nextYear.subtract(const Duration(seconds: 1));
    case StatisticsPeriod.custom:
      return startDate; // 自定义周期需要外部指定
  }
}

/// 获取时间区间的显示文本
String getPeriodDisplayText(DateTime date, StatisticsPeriod period) {
  switch (period) {
    case StatisticsPeriod.day:
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    case StatisticsPeriod.week:
      final endDate = date.add(const Duration(days: 6));
      return '${date.year}年第${(date.day / 7).ceil()}周';
    case StatisticsPeriod.month:
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    case StatisticsPeriod.quarter:
      final quarter = ((date.month - 1) / 3).floor() + 1;
      return '${date.year}年第$quarter季度';
    case StatisticsPeriod.year:
      return '${date.year}年';
    case StatisticsPeriod.custom:
      return '自定义周期';
  }
}

/// 判断是否是同一时间区间
bool isSamePeriod(DateTime date1, DateTime date2, StatisticsPeriod period) {
  switch (period) {
    case StatisticsPeriod.day:
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    case StatisticsPeriod.week:
      final weekStart1 = date1.subtract(Duration(days: date1.weekday - 1));
      final weekStart2 = date2.subtract(Duration(days: date2.weekday - 1));
      return weekStart1.year == weekStart2.year &&
          weekStart1.month == weekStart2.month &&
          weekStart1.day == weekStart2.day;
    case StatisticsPeriod.month:
      return date1.year == date2.year && date1.month == date2.month;
    case StatisticsPeriod.quarter:
      final quarter1 = ((date1.month - 1) / 3).floor();
      final quarter2 = ((date2.month - 1) / 3).floor();
      return date1.year == date2.year && quarter1 == quarter2;
    case StatisticsPeriod.year:
      return date1.year == date2.year;
    case StatisticsPeriod.custom:
      return false; // 自定义周期需要外部判断
  }
}

/// 获取时间区间的起始时间
DateTime getPeriodStartDate(DateTime date, StatisticsPeriod period) {
  switch (period) {
    case StatisticsPeriod.day:
      return DateTime(date.year, date.month, date.day);
    case StatisticsPeriod.week:
      final weekDay = date.weekday;
      return date.subtract(Duration(days: weekDay - 1));
    case StatisticsPeriod.month:
      return DateTime(date.year, date.month, 1);
    case StatisticsPeriod.quarter:
      final quarter = ((date.month - 1) / 3).floor();
      return DateTime(date.year, quarter * 3 + 1, 1);
    case StatisticsPeriod.year:
      return DateTime(date.year, 1, 1);
    case StatisticsPeriod.custom:
      return date; // 自定义周期需要外部指定
  }
} 