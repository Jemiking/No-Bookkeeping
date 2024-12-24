import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calendar_state.dart';
import '../events/calendar_events.dart';

class TransactionListView extends StatefulWidget {
  const TransactionListView({Key? key}) : super(key: key);

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  static const double LIST_TOP_RADIUS = 16.0;
  static const double ARROW_BUTTON_HEIGHT = 24.0;
  static const double ARROW_BUTTON_MARGIN = 6.0;

  @override
  void initState() {
    super.initState();
    final calendarState = context.read<CalendarState>();
    calendarState.eventBus.addEventListener(_handleTransactionEvent);
  }

  @override
  void dispose() {
    final calendarState = context.read<CalendarState>();
    calendarState.eventBus.removeEventListener(_handleTransactionEvent);
    super.dispose();
  }

  void _handleTransactionEvent(CalendarEvent event) {
    if (event is DailyTransactionsLoadedEvent) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = context.watch<CalendarState>();
    final transactions = calendarState.currentDayTransactions;
    final isLoading = calendarState.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
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
            height: ARROW_BUTTON_HEIGHT + ARROW_BUTTON_MARGIN * 2,
            child: Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: transactions.isEmpty
                ? _buildEmptyState()
                : _buildTransactionList(transactions),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无交易记录',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<dynamic> transactions) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 88,
        ),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionItem(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionItem([dynamic transaction]) {
    // TODO: 根据实际的交易数据模型来展示
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
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF6B5B95),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
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
          const Text(
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