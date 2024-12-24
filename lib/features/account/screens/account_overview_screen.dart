import 'package:flutter/material.dart';

class AccountOverviewScreen extends StatelessWidget {
  const AccountOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 导航到添加账户页面
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 总资产卡片
            _buildTotalAssetCard(),
            // 账户列表
            _buildAccountSection('现金账户', [
              AccountData(
                name: '现金',
                balance: 1580.0,
                icon: Icons.money,
                color: Colors.green,
              ),
            ]),
            _buildAccountSection('银行卡', [
              AccountData(
                name: '招商银行',
                balance: 15800.0,
                icon: Icons.credit_card,
                color: Colors.blue,
              ),
              AccountData(
                name: '工商银行',
                balance: 8000.0,
                icon: Icons.credit_card,
                color: Colors.red,
              ),
            ]),
            _buildAccountSection('信用卡', [
              AccountData(
                name: '交通银行',
                balance: -3580.0,
                icon: Icons.credit_score,
                color: Colors.orange,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAssetCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '总资产',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '¥25,380.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAssetSummaryItem('总收入', '¥35,800'),
              _buildAssetSummaryItem('总支出', '¥10,420'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetSummaryItem(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(String title, List<AccountData> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...accounts.map((account) => _buildAccountItem(account)).toList(),
      ],
    );
  }

  Widget _buildAccountItem(AccountData account) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: account.color.withOpacity(0.1),
        child: Icon(
          account.icon,
          color: account.color,
        ),
      ),
      title: Text(account.name),
      trailing: Text(
        '¥${account.balance}',
        style: TextStyle(
          color: account.balance >= 0 ? Colors.black : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // TODO: 导航到账户详情页面
      },
    );
  }
}

class AccountData {
  final String name;
  final double balance;
  final IconData icon;
  final Color color;

  AccountData({
    required this.name,
    required this.balance,
    required this.icon,
    required this.color,
  });
} 