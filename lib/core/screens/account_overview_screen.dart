import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';
import '../models/account.dart';

class AccountOverviewScreen extends StatefulWidget {
  const AccountOverviewScreen({Key? key}) : super(key: key);

  @override
  State<AccountOverviewScreen> createState() => _AccountOverviewScreenState();
}

class _AccountOverviewScreenState extends State<AccountOverviewScreen> {
  bool _isLoading = true;
  bool _isBalanceVisible = true;
  List<Account> _accounts = [];
  double _totalAssets = 0;
  double _totalLiabilities = 0;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 从数据库加载账户数据
      // 临时数据
      _accounts = [
        Account(
          id: '1',
          name: '现金',
          type: '现金账户',
          balance: 1580.00,
          icon: Icons.money,
          color: Colors.green,
          isArchived: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Account(
          id: '2',
          name: '招商银行',
          type: '储蓄卡',
          balance: 15800.00,
          icon: Icons.credit_card,
          color: Colors.blue,
          isArchived: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Account(
          id: '3',
          name: '工商银行',
          type: '储蓄卡',
          balance: 8000.00,
          icon: Icons.credit_card,
          color: Colors.red,
          isArchived: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Account(
          id: '4',
          name: '交通银行信用卡',
          type: '信用卡',
          balance: -3580.00,
          icon: Icons.credit_card,
          color: Colors.orange,
          isArchived: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      _totalAssets = _accounts
          .where((account) => account.balance > 0)
          .fold(0, (sum, account) => sum + account.balance);

      _totalLiabilities = _accounts
          .where((account) => account.balance < 0)
          .fold(0, (sum, account) => sum + account.balance);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败：$e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAccountOptions(Account account) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑账户'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 导航到账户编辑页面
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('归档账户'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现账户归档功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除账户'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(account);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除账户"${account.name}"吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // TODO: 实现删除账户逻辑
                setState(() {
                  _accounts.remove(account);
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('删除失败：$e')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户总览'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isBalanceVisible = !_isBalanceVisible;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 资产概览
          Container(
            padding: const EdgeInsets.all(24.0),
            color: theme.primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Text(
                  '总资产',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  _isBalanceVisible
                      ? '¥${(_totalAssets + _totalLiabilities).toStringAsFixed(2)}'
                      : '****',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBalanceItem(
                      label: '资产',
                      amount: _totalAssets,
                      color: Colors.green,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.dividerColor,
                    ),
                    _buildBalanceItem(
                      label: '负债',
                      amount: _totalLiabilities.abs(),
                      color: Colors.red,
                      isNegative: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 账户列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 现金账户
                if (_accounts.any((account) => account.type == '现金账户'))
                  _buildAccountGroup(
                    title: '现金账户',
                    accounts: _accounts
                        .where((account) => account.type == '现金账户')
                        .toList(),
                  ),
                // 储蓄卡
                if (_accounts.any((account) => account.type == '储蓄卡'))
                  _buildAccountGroup(
                    title: '储蓄卡',
                    accounts: _accounts
                        .where((account) => account.type == '储蓄卡')
                        .toList(),
                  ),
                // 信用卡
                if (_accounts.any((account) => account.type == '信用卡'))
                  _buildAccountGroup(
                    title: '信用卡',
                    accounts: _accounts
                        .where((account) => account.type == '信用卡')
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 导航到添加账户页面
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBalanceItem({
    required String label,
    required double amount,
    required Color color,
    bool isNegative = false,
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
          _isBalanceVisible
              ? '${isNegative ? '-' : ''}¥${amount.toStringAsFixed(2)}'
              : '****',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountGroup({
    required String title,
    required List<Account> accounts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        ...accounts.map((account) => _buildAccountTile(account)),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildAccountTile(Account account) {
    return InkWell(
      onTap: () {
        // TODO: 导航到账户详情页面
      },
      onLongPress: () => _showAccountOptions(account),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: account.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(
                account.icon,
                color: account.color,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    account.type,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _isBalanceVisible
                  ? '¥${account.balance.toStringAsFixed(2)}'
                  : '****',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 