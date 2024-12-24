import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/calendar_state.dart';
import 'widgets/animated_calendar_view.dart';
import 'widgets/swipeable_calendar_content.dart';
import 'widgets/transaction_list_view.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarState(),
      child: const _CalendarPageContent(),
    );
  }
}

class _CalendarPageContent extends StatelessWidget {
  const _CalendarPageContent();

  static const double SYSTEM_STATUS_BAR_HEIGHT = 24.0;
  static const double HEADER_PADDING = 16.0;
  static const double HEADER_HEIGHT = 56.0;
  static const double TOTAL_HEADER_HEIGHT = HEADER_HEIGHT + HEADER_PADDING * 2;

  @override
  Widget build(BuildContext context) {
    final calendarState = context.watch<CalendarState>();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Expanded(
              child: Stack(
                children: [
                  AnimatedCalendarView(),
                  TransactionListView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 实现添加交易功能
        },
        backgroundColor: const Color(0xFF6B5B95),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final calendarState = context.watch<CalendarState>();
    final selectedDate = calendarState.selectedDate;
    
    return Container(
      padding: const EdgeInsets.all(HEADER_PADDING),
      height: TOTAL_HEADER_HEIGHT,
      color: const Color(0xFF6B5B95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${selectedDate.year}年${selectedDate.month}月',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // TODO: 实现搜���功能
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
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
} 