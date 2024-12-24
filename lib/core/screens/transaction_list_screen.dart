import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme_manager.dart';
import '../models/transaction.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final List<Transaction> _transactions = [
    // TODO: 从数据库加载交易记录
  ];

  String _selectedMonth = DateFormat('yyyy年MM月').format(DateTime.now());
  String _selectedFilter = '全部';

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const Text('选择月份'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 12,
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(
                    Duration(days: 30 * index),
                  );
                  final month = DateFormat('yyyy年MM月').format(date);
                  return ListTile(
                    title: Text(month),
                    selected: month == _selectedMonth,
                    onTap: () {
                      setState(() {
                        _selectedMonth = month;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('全部'),
              value: '全部',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value.toString();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('收入'),
              value: '收入',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value.toString();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('支出'),
              value: '支出',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value.toString();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showMonthPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_selectedMonth),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 月度统计
          Container(
            padding: const EdgeInsets.all(16.0),
            color: theme.primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: '收入',
                  amount: '¥8,000.00',
                  color: Colors.green,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.dividerColor,
                ),
                _buildStatItem(
                  label: '支出',
                  amount: '¥3,580.00',
                  color: Colors.red,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.dividerColor,
                ),
                _buildStatItem(
                  label: '结余',
                  amount: '¥4,420.00',
                  color: theme.primaryColor,
                ),
              ],
            ),
          ),
          // 交易列表
          Expanded(
            child: ListView.builder(
              itemCount: 1, // TODO: 替换为实际数据
              itemBuilder: (context, index) {
                return _buildTransactionGroup(
                  date: '今天',
                  transactions: [
                    _TransactionItem(
                      icon: Icons.restaurant,
                      title: '早餐',
                      category: '餐饮',
                      amount: -38.00,
                      time: '08:30',
                      account: '招商银行',
                    ),
                    _TransactionItem(
                      icon: Icons.directions_subway,
                      title: '地铁',
                      category: '交通',
                      amount: -7.00,
                      time: '09:15',
                      account: '交通卡',
                    ),
                    _TransactionItem(
                      icon: Icons.work,
                      title: '工资',
                      category: '工资',
                      amount: 8000.00,
                      time: '10:00',
                      account: '招商银行',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionGroup({
    required String date,
    required List<_TransactionItem> transactions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        ...transactions.map((transaction) => _buildTransactionTile(transaction)),
      ],
    );
  }

  Widget _buildTransactionTile(_TransactionItem transaction) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        // TODO: 导航到交易详情页
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(
                transaction.icon,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: 12.0),
            // 标题和分类
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${transaction.category} · ${transaction.account}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            // 金额和时间
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.amount > 0
                      ? '+${transaction.amount.toStringAsFixed(2)}'
                      : transaction.amount.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: transaction.amount > 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  transaction.time,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem {
  final IconData icon;
  final String title;
  final String category;
  final double amount;
  final String time;
  final String account;

  _TransactionItem({
    required this.icon,
    required this.title,
    required this.category,
    required this.amount,
    required this.time,
    required this.account,
  });
} 