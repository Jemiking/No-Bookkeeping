import 'package:flutter/material.dart';
import 'dart:math' as math;

// 将 WeekRange 类移到顶层
class WeekRange {
  final DateTime start;
  final DateTime end;
  final int startIndex;
  final int visibleDays;

  WeekRange({
    required this.start,
    required this.end,
    required this.startIndex,
    required this.visibleDays,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // 布局常量
  static const double SYSTEM_STATUS_BAR_HEIGHT = 24.0;
  static const double HEADER_PADDING = 16.0;
  static const double HEADER_HEIGHT = 56.0;
  static const double TOTAL_HEADER_HEIGHT = HEADER_HEIGHT + HEADER_PADDING * 2;
  static const double CALENDAR_MARGIN = 4.0;
  static const double ARROW_BUTTON_HEIGHT = 24.0;
  static const double ARROW_BUTTON_MARGIN = 6.0;
  static const double LIST_SHADOW_SPACE = 4.0;
  static const double LIST_TOP_RADIUS = 16.0;
  
  bool _isCalendarExpanded = true;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _rotationAnimation;
  DateTime _selectedDate = DateTime.now();
  final GlobalKey _calendarKey = GlobalKey();
  
  // 状态管理相关变量
  final double _weekHeight = 65.0;
  final double _headerHeight = 35.0;
  final double _monthViewHeight = 400.0;
  late ScrollController _calendarScrollController;
  late int _currentWeekIndex;

  @override
  void initState() {
    super.initState();
    _calendarScrollController = ScrollController();
    _currentWeekIndex = _calculateWeekIndex(_selectedDate);
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: _monthViewHeight,
      end: _headerHeight + _weekHeight,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  // 计算周索引的方法
  int _calculateWeekIndex(DateTime date) {
    final DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday % 7;
    return ((date.day + firstWeekday - 1) / 7).floor();
  }

  // 滚动到指定周的方法
  void _scrollToWeek(int weekIndex) {
    if (!_calendarScrollController.hasClients) return;
    
    _calendarScrollController.animateTo(
      weekIndex * _weekHeight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 计算当前周的日期范围
  WeekRange _calculateCurrentWeekRange() {
    final DateTime firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday % 7;
    final int daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    
    // 计算选中日期所在周的起始位置
    final int weekStartDay = _currentWeekIndex * 7 - firstWeekday + 1;
    final int visibleDays = math.min(7, daysInMonth - weekStartDay + 1);
    
    return WeekRange(
      start: DateTime(_selectedDate.year, _selectedDate.month, weekStartDay),
      end: DateTime(_selectedDate.year, _selectedDate.month, weekStartDay + visibleDays - 1),
      startIndex: _currentWeekIndex * 7,
      visibleDays: visibleDays,
    );
  }

  void _toggleCalendarExpansion() {
    setState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
      
      if (_isCalendarExpanded) {
        // 展开时，先滚动到正确位置，再执行动画
        if (_calendarScrollController.hasClients) {
          _calendarScrollController.jumpTo(_currentWeekIndex * _weekHeight);
        }
        _controller.reverse();
      } else {
        // 收缩时，确保显示当前选中的周
        _controller.forward().then((_) {
          if (_calendarScrollController.hasClients) {
            _scrollToWeek(_currentWeekIndex);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    AnimatedBuilder(
                      animation: _heightAnimation,
                      builder: (context, child) {
                        return SizedBox(
                          height: _heightAnimation.value,
                          child: _buildCalendar(),
                        );
                      },
                    ),
                  ],
                ),
                AnimatedBuilder(
                  animation: _heightAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: SYSTEM_STATUS_BAR_HEIGHT + TOTAL_HEADER_HEIGHT + _heightAnimation.value - LIST_TOP_RADIUS,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(LIST_TOP_RADIUS),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, -2),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: ARROW_BUTTON_HEIGHT + ARROW_BUTTON_MARGIN,
                              child: Center(
                                child: _buildExpandButton(),
                              ),
                            ),
                            Expanded(
                              child: _buildTransactionList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: const _AddTransactionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(HEADER_PADDING),
      height: TOTAL_HEADER_HEIGHT,
      color: const Color(0xFF6B5B95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_selectedDate.year}年${_selectedDate.month}月',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // TODO: 实现搜索功能
                },
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // TODO: 实现更多功能
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      key: _calendarKey,
      margin: const EdgeInsets.fromLTRB(CALENDAR_MARGIN, 0, CALENDAR_MARGIN, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            height: _headerHeight,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            child: _buildWeekDayHeader(),
          ),
          Expanded(
            child: GridView.builder(
              controller: _calendarScrollController,
              physics: _isCalendarExpanded 
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: (MediaQuery.of(context).size.width - 2 * CALENDAR_MARGIN) / 7 / _weekHeight,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              itemCount: _isCalendarExpanded 
                ? _calculateTotalCells()
                : _calculateCurrentWeekRange().visibleDays,
              itemBuilder: (context, index) {
                if (_isCalendarExpanded) {
                  return _buildCalendarDayCell(index);
                } else {
                  final weekRange = _calculateCurrentWeekRange();
                  return _buildCalendarDayCell(weekRange.startIndex + index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalCells() {
    final DateTime firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday % 7;
    final int daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    return ((daysInMonth + firstWeekday) / 7).ceil() * 7;
  }

  Widget _buildCalendarDayCell(int index) {
    final DateTime firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday % 7;
    
    if (index < firstWeekday) {
      return Container();
    }
    
    final int day = index - firstWeekday + 1;
    if (day > DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day) {
      return Container();
    }
    
    return _buildCalendarDay(day);
  }

  Widget _buildWeekDayHeader() {
    final weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        color: const Color(0xFF6B5B95),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarDay(int day) {
    final isSelected = day == _selectedDate.day;
    final now = DateTime.now();
    final isToday = day == now.day && 
                    _selectedDate.month == now.month && 
                    _selectedDate.year == now.year;
    
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
          setState(() {
            _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
            _currentWeekIndex = _calculateWeekIndex(_selectedDate);
            
            if (!_isCalendarExpanded) {
              _scrollToWeek(_currentWeekIndex);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isToday)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B5B95),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    '$day',
                    style: TextStyle(
                      color: isToday ? Colors.white : (isSelected ? const Color(0xFF6B5B95) : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '-￥58',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                ),
              ),
              Text(
                '+￥100',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _toggleCalendarExpansion,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 3.14159 * 2,
                child: Icon(
                  Icons.expand_less,
                  color: const Color(0xFF6B5B95),
                  size: 14,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 88,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildTransactionItem();
        },
      ),
    );
  }

  Widget _buildTransactionItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6B5B95).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant,
              color: const Color(0xFF6B5B95),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '午餐',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '12:30 银行',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-￥35.00',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTransactionButton extends StatelessWidget {
  const _AddTransactionButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: 实现添加记账功能
      },
      backgroundColor: const Color(0xFF6B5B95),
      child: const Icon(Icons.add),
    );
  }
}

/*
问题分析文档
===========

1. 当前问题回顾
   A. 原始需求
      - 日历展开/收缩功能
      - 显示选中周的内容
      - 箭头按钮始终可见
      - 动画过渡流畅

   B. 出现的问题
      - 布局出错误
      - 箭头按钮消失
      - 日期内容不可见
      - 动画不流畅

2. 之前尝试的方案（均未成功）
   A. 方案一：调整动画值
      - 修改高度动画范围
      - 问题：未解决根本问题

   B. 方案二：布局约束优化
      - 调整布局结构
      - 问题：引入新的布局错误

   C. 方案三：状态管理优化
      - 添加状态变量
      - 问题：状态同步问题

   D. 方案四：滚动控制优化
      - 改滚动逻辑
      - 问题：内容显示异常

   E. 方案五：箭头定位优化
      - 调整箭头位置计算
      - 问题：箭头仍然消失

   F. 方案六：布局重构
      - 简化布局级
      - 问题：约束传递错误

新解决方案
=========

1. 回归基础
   A. 保持简单原则
      - 使用最基础的布局结构
      - 减少嵌套层级
      - 避免复杂的动画计算

   B. 关注核心功能
      - 确保基本展开/收缩
      - 保证内容可见性
      - 维持箭头按钮状态

2. 分步骤实现
   A. 第一步：基础布局
      - 实现基本的日历结构
      - 确保布局稳定性
      - 验证约束传递

   B. 第二步：动画控制
      - 添加简单的高度动画
      - 确保动画流畅
      - 验证状态转换

   C. 第三步：内容显示
      - 实现周视图切换
      - 确保内容可见
      - 处理滚动行为

   D. 第四步：箭头控制
      - 优化箭头定位
      - 确保始终可见
      - 处理状态同步

3. 验证机制
   A. 每步验证
      - 验证布局稳定性
      - 检查动画效果
      - 测试交互响应

   B. 边界测试
      - 测试极限情况
      - 验证错误处理
      - 确保稳定性
*/
