import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 日期选择器组件
class DatePicker extends StatelessWidget {
  /// 选中的日期
  final DateTime selectedDate;

  /// 日期改变回调
  final ValueChanged<DateTime> onDateChanged;

  /// 最小日期
  final DateTime? minDate;

  /// 最大日期
  final DateTime? maxDate;

  /// 日期格式
  final String dateFormat;

  /// 是否显示年份
  final bool showYear;

  /// 是否显示月份
  final bool showMonth;

  /// 是否显示日期
  final bool showDay;

  /// 构造函数
  const DatePicker({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
    this.minDate,
    this.maxDate,
    this.dateFormat = 'yyyy-MM-dd',
    this.showYear = true,
    this.showMonth = true,
    this.showDay = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16.0),
          _buildCalendar(context),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(BuildContext context) {
    final dateStr = DateFormat(dateFormat).format(selectedDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            final newDate = DateTime(
              selectedDate.year,
              selectedDate.month - 1,
              selectedDate.day,
            );
            if (_isDateValid(newDate)) {
              onDateChanged(newDate);
            }
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          dateStr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          onPressed: () {
            final newDate = DateTime(
              selectedDate.year,
              selectedDate.month + 1,
              selectedDate.day,
            );
            if (_isDateValid(newDate)) {
              onDateChanged(newDate);
            }
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  /// 构建日历
  Widget _buildCalendar(BuildContext context) {
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;

    final firstDayOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month,
      1,
    );

    final firstWeekday = firstDayOfMonth.weekday;
    final days = List.generate(42, (index) {
      final dayNumber = index - firstWeekday + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return null;
      }
      return dayNumber;
    });

    return Column(
      children: [
        _buildWeekdayHeader(),
        const SizedBox(height: 8.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            if (day == null) {
              return const SizedBox();
            }

            final date = DateTime(
              selectedDate.year,
              selectedDate.month,
              day,
            );

            final isSelected = date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day;

            final isEnabled = _isDateValid(date);

            return _buildDayCell(
              context,
              day,
              isSelected,
              isEnabled,
              date,
            );
          },
        ),
      ],
    );
  }

  /// 构建星期头部
  Widget _buildWeekdayHeader() {
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((weekday) {
        return SizedBox(
          width: 32.0,
          child: Center(
            child: Text(
              weekday,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建日期单元格
  Widget _buildDayCell(
    BuildContext context,
    int day,
    bool isSelected,
    bool isEnabled,
    DateTime date,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled
            ? () {
                onDateChanged(date);
              }
            : null,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : isEnabled
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).disabledColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 检查日期是否有效
  bool _isDateValid(DateTime date) {
    if (minDate != null && date.isBefore(minDate!)) {
      return false;
    }
    if (maxDate != null && date.isAfter(maxDate!)) {
      return false;
    }
    return true;
  }
} 