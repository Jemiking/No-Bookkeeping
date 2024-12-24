import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calendar_state.dart';

class SwipeableCalendarContent extends StatefulWidget {
  const SwipeableCalendarContent({Key? key}) : super(key: key);

  @override
  State<SwipeableCalendarContent> createState() => _SwipeableCalendarContentState();
}

class _SwipeableCalendarContentState extends State<SwipeableCalendarContent> {
  static const double WEEK_HEIGHT = 65.0;
  static const double HEADER_HEIGHT = 35.0;
  
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = Offset.zero;
    });
  }
  
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset += Offset(details.delta.dx, 0);
    });
  }
  
  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    final calendarState = context.read<CalendarState>();
    final double velocity = details.primaryVelocity ?? 0;
    final double dragDistance = _dragOffset.dx.abs();
    
    if (dragDistance > 50 || velocity.abs() > 500) {
      final int direction = _dragOffset.dx > 0 ? -1 : 1;
      if (calendarState.isExpanded) {
        if (direction < 0) {
          calendarState.previousMonth();
        } else {
          calendarState.nextMonth();
        }
      } else {
        if (direction < 0) {
          calendarState.previousWeek();
        } else {
          calendarState.nextWeek();
        }
      }
    }
    
    setState(() {
      _isDragging = false;
      _dragOffset = Offset.zero;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekDayHeader(),
        Expanded(
          child: GestureDetector(
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            child: Transform.translate(
              offset: _dragOffset,
              child: _buildCalendarGrid(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeekDayHeader() {
    final weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    return Container(
      height: HEADER_HEIGHT,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                color: Color(0xFF6B5B95),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
  
  Widget _buildCalendarGrid() {
    final calendarState = context.watch<CalendarState>();
    final selectedDate = calendarState.selectedDate;
    final isExpanded = calendarState.isExpanded;
    final screenWidth = MediaQuery.of(context).size.width;
    final cellWidth = (screenWidth - 8) / 7; // 考虑左右边距各4
    final cellHeight = WEEK_HEIGHT;
    
    if (!isExpanded) {
      // 在周视图中，计算本周的日期范围
      final weekStartDate = _getWeekStartDate(selectedDate);
      final weekDates = List.generate(7, (index) {
        final date = weekStartDate.add(Duration(days: index));
        return date;
      });
      
      return GridView.builder(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: cellWidth / cellHeight,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
        ),
        itemCount: 7,
        itemBuilder: (context, index) {
          return _buildCalendarDayCell(
            weekDates[index],
            selectedDate,
            isExpanded,
          );
        },
      );
    }
    
    // 月视图
    return GridView.builder(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: cellWidth / cellHeight,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemCount: _calculateTotalCells(selectedDate),
      itemBuilder: (context, index) {
        final firstDayOffset = _getFirstDayOffset(selectedDate);
        final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
        final daysInPrevMonth = DateTime(selectedDate.year, selectedDate.month, 0).day;
        
        DateTime cellDate;
        
        if (index < firstDayOffset) {
          // 上个月的日期
          final prevMonthDay = daysInPrevMonth - (firstDayOffset - index - 1);
          cellDate = DateTime(
            selectedDate.year,
            selectedDate.month - 1,
            prevMonthDay,
          );
        } else if (index >= firstDayOffset + daysInMonth) {
          // 下个月的日期
          final nextMonthDay = index - (firstDayOffset + daysInMonth) + 1;
          cellDate = DateTime(
            selectedDate.year,
            selectedDate.month + 1,
            nextMonthDay,
          );
        } else {
          // 当前月的日期
          final day = index - firstDayOffset + 1;
          cellDate = DateTime(selectedDate.year, selectedDate.month, day);
        }
        
        return _buildCalendarDayCell(cellDate, selectedDate, isExpanded);
      },
    );
  }
  
  int _calculateTotalCells(DateTime date) {
    final firstDayOffset = _getFirstDayOffset(date);
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    return ((firstDayOffset + daysInMonth) / 7).ceil() * 7;
  }
  
  int _getFirstDayOffset(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }
  
  DateTime _getWeekStartDate(DateTime date) {
    // 获取当前日期是周几（0-6，周日到周六）
    int weekday = date.weekday % 7;
    // 计算到本周周日的偏移天数
    int daysToSubtract = weekday;
    // 返回本周的第一天（周日）
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }
  
  Widget _buildCalendarDayCell(DateTime cellDate, DateTime selectedDate, bool isExpanded) {
    final calendarState = context.watch<CalendarState>();
    final isCurrentMonth = cellDate.month == selectedDate.month;
    final isSelected = cellDate.year == selectedDate.year && 
                      cellDate.month == selectedDate.month && 
                      cellDate.day == selectedDate.day;
    final isToday = _isToday(cellDate);
    final isOtherMonth = !isCurrentMonth && isExpanded;
    
    // 获取日期的收支总额
    final dayTotal = calendarState.getDayTotal(cellDate);
    final hasTransactions = dayTotal['income']! > 0 || dayTotal['expense']! > 0;
    
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6B5B95).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? const Color(0xFF6B5B95) : Colors.grey.withOpacity(0.1),
          width: isSelected ? 1.0 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<CalendarState>().selectDate(cellDate);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isToday && !isOtherMonth)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6B5B95),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    '${cellDate.day}',
                    style: TextStyle(
                      color: _getTextColor(isOtherMonth, isToday, isSelected),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (hasTransactions) ...[
                const SizedBox(height: 2),
                if (dayTotal['expense']! > 0)
                  Text(
                    '-￥${dayTotal['expense']!.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isOtherMonth ? Colors.grey.withOpacity(0.5) : Colors.red,
                      fontSize: 10,
                    ),
                  ),
                if (dayTotal['income']! > 0)
                  Text(
                    '+￥${dayTotal['income']!.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isOtherMonth ? Colors.grey.withOpacity(0.5) : Colors.green,
                      fontSize: 10,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getTextColor(bool isOtherMonth, bool isToday, bool isSelected) {
    if (isOtherMonth) {
      return Colors.grey.withOpacity(0.5);
    }
    if (isToday) {
      return Colors.white;
    }
    if (isSelected) {
      return const Color(0xFF6B5B95);
    }
    return Colors.black87;
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
} 