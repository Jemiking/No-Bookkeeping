import 'package:flutter/material.dart';
import 'package:money_tracker/features/account/screens/account_overview_screen.dart';

class AccountDetailScreen extends StatelessWidget {
  final AccountData account;

  const AccountDetailScreen({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // TODO: 导航到编辑页面
                  break;
                case 'delete':
                  _showDeleteConfirmDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('编辑'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('删除'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 账户余额卡片
          _buildBalanceCard(),
          // 交易记录列表
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: account.color.withOpacity(0.1),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: account.color.withOpacity(0.2),
            child: Icon(
              account.icon,
              size: 30,
              color: account.color,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '账户余额',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥${account.balance}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: account.balance >= 0 ? Colors.black : Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('本月收入', '¥8,000'),
              _buildStatItem('本月支出', '¥3,580'),
            ],
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

  Widget _buildTransactionList() {
    // 模拟交易数据
    final transactions = [
      _TransactionData(
        type: TransactionType.expense,
        amount: 38.0,
        category: '餐饮',
        date: DateTime.now(),
        description: '早餐',
      ),
      _TransactionData(
        type: TransactionType.expense,
        amount: 7.0,
        category: '交通',
        date: DateTime.now(),
        description: '地铁',
      ),
      _TransactionData(
        type: TransactionType.income,
        amount: 8000.0,
        category: '工资',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: '12月工资',
      ),
    ];

    return ListView.builder(
      itemCount: transactions.length + 1, // +1 for the header
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '近期交易',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final transaction = transactions[index - 1];
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
          subtitle: Text(transaction.category),
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
            // TODO: 导航到交易详情页面
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个账户吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 实现删除逻辑
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 返回账户列表页面
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

enum TransactionType {
  expense,
  income,
}

class _TransactionData {
  final TransactionType type;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  _TransactionData({
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });
} 