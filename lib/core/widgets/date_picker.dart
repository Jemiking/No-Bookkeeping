import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 日期选择器组件
class DatePicker extends StatefulWidget {
  /// 初始日期
  final DateTime? initialDate;
  
  /// 最小日期
  final DateTime? firstDate;
  
  /// 最大日期
  final DateTime? lastDate;
  
  /// 日期选择回调
  final ValueChanged<DateTime>? onDateSelected;
  
  /// 日期格式
  final String? dateFormat;
  
  /// 是否显示年份选择器
  final bool showYearPicker;
  
  /// 是否显示月份选择器
  final bool showMonthPicker;
  
  /// 是否显示时间选择器
  final bool showTimePicker;
  
  /// 标题文本
  final String? title;
  
  /// 确认按钮文本
  final String? confirmText;
  
  /// 取消按钮文本
  final String? cancelText;

  const DatePicker({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.dateFormat,
    this.showYearPicker = true,
    this.showMonthPicker = true,
    this.showTimePicker = false,
    this.title,
    this.confirmText,
    this.cancelText,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime _selectedDate;
  late DateFormat _dateFormatter;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _dateFormatter = DateFormat(widget.dateFormat ?? 'yyyy-MM-dd');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(theme),
        _buildDatePicker(theme),
        if (widget.showTimePicker) _buildTimePicker(theme),
        _buildActions(theme),
      ],
    );
  }

  /// 构建头部
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title ?? '选择日期',
            style: theme.textTheme.titleMedium,
          ),
          Text(
            _dateFormatter.format(_selectedDate),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建日期选择器
  Widget _buildDatePicker(ThemeData theme) {
    return CalendarDatePicker(
      initialDate: _selectedDate,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      onDateChanged: (date) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedDate.hour,
            _selectedDate.minute,
          );
        });
      },
    );
  }

  /// 构建时间选择器
  Widget _buildTimePicker(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeField(
            context,
            _selectedDate.hour.toString().padLeft(2, '0'),
            (value) {
              final hour = int.tryParse(value);
              if (hour != null && hour >= 0 && hour < 24) {
                setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    hour,
                    _selectedDate.minute,
                  );
                });
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(':'),
          ),
          _buildTimeField(
            context,
            _selectedDate.minute.toString().padLeft(2, '0'),
            (value) {
              final minute = int.tryParse(value);
              if (minute != null && minute >= 0 && minute < 60) {
                setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedDate.hour,
                    minute,
                  );
                });
              }
            },
          ),
        ],
      ),
    );
  }

  /// 构建时间输入框
  Widget _buildTimeField(
    BuildContext context,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: TextEditingController(text: value),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(widget.cancelText ?? '取消'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              widget.onDateSelected?.call(_selectedDate);
              Navigator.of(context).pop();
            },
            child: Text(widget.confirmText ?? '确定'),
          ),
        ],
      ),
    );
  }

  /// 显示日期选择器对话框
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? dateFormat,
    bool showYearPicker = true,
    bool showMonthPicker = true,
    bool showTimePicker = false,
    String? title,
    String? confirmText,
    String? cancelText,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => DatePicker(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        dateFormat: dateFormat,
        showYearPicker: showYearPicker,
        showMonthPicker: showMonthPicker,
        showTimePicker: showTimePicker,
        title: title,
        confirmText: confirmText,
        cancelText: cancelText,
        onDateSelected: (date) {
          Navigator.of(context).pop(date);
        },
      ),
    );
  }
} 