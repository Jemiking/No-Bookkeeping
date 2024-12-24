import 'package:flutter/material.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  // 模拟数据
  final List<TransactionData> _transactions = [
    TransactionData(
      id: '1',
      type: TransactionType.expense,
      amount: 38.0,
      category: '餐饮',
      date: DateTime.now(),
      description: '早餐',
      account: '招商银行',
    ),
    TransactionData(
      id: '2',
      type: TransactionType.expense,
      amount: 7.0,
      category: '交通',
      date: DateTime.now(),
      description: '地铁',
      account: '交通卡',
    ),
    TransactionData(
      id: '3',
      type: TransactionType.income,
      amount: 8000.0,
      category: '工资',
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: '12月工资',
      account: '工商银行',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账单'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 显示筛选选项
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 显示搜索界面
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 月度统计
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('收入', '¥8,000'),
                _buildStatItem('支出', '¥3,580'),
                _buildStatItem('结余', '¥4,420'),
              ],
            ),
          ),
          // 账单列表
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final isFirstOfDay = index == 0 ||
                    !_isSameDay(
                      transaction.date,
                      _transactions[index - 1].date,
                    );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirstOfDay) _buildDateHeader(transaction.date),
                    _buildTransactionItem(transaction),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String amount) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        _formatDate(date),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionData transaction) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.type == TransactionType.expense
            ? Colors.red[100]
            : Colors.green[100],
        child: Icon(
          transaction.type == TransactionType.expense
              ? Icons.remove
              : Icons.add,
          color: transaction.type == TransactionType.expense
              ? Colors.red
              : Colors.green,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(transaction.account),
      trailing: Text(
        '${transaction.type == TransactionType.expense ? '-' : '+'}¥${transaction.amount}',
        style: TextStyle(
          color: transaction.type == TransactionType.expense
              ? Colors.red
              : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // TODO: 导航到账单详情页
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return '今天';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}

enum TransactionType {
  expense,
  income,
}

class TransactionData {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final String account;

  TransactionData({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.account,
  });
} 