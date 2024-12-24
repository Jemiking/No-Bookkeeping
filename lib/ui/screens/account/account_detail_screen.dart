import 'package:flutter/material.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/models/transaction.dart';
import '../../../core/services/account_service.dart';
import '../../../core/services/transaction_service.dart';

/// 账户详情页面
class AccountDetailScreen extends StatefulWidget {
  /// 账户ID
  final int accountId;

  /// 构造函数
  const AccountDetailScreen({
    Key? key,
    required this.accountId,
  }) : super(key: key);

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  final AccountService _accountService = AccountService();
  final TransactionService _transactionService = TransactionService();

  Account? _account;
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccountDetails();
  }

  /// 加载账户详情
  Future<void> _loadAccountDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final account = await _accountService.getAccount(widget.accountId);
      if (account == null) {
        setState(() {
          _error = '账户不存在';
          _isLoading = false;
        });
        return;
      }

      final transactions = await _transactionService.getTransactionsByAccount(
        widget.accountId,
        limit: 10,
      );

      setState(() {
        _account = account;
        _recentTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载账户详情失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_account?.name ?? '账户详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 跳转到账户编辑页面
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'delete':
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('删除账户'),
                        content: const Text('确定要删除该账户吗？删除后无法恢复。'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              '删除',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirmed == true) {
                    try {
                      await _accountService.deleteAccount(widget.accountId);
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('删除账户失败：$e'),
                          ),
                        );
                      }
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    '删除账户',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 跳转到交易编辑页面
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loadAccountDetails,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_account == null) {
      return const Center(
        child: Text('账户不存在'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAccountDetails,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAccountCard(),
          const SizedBox(height: 16.0),
          _buildStatisticsCard(),
          const SizedBox(height: 16.0),
          _buildRecentTransactionsCard(),
        ],
      ),
    );
  }

  /// 构建账户卡片
  Widget _buildAccountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_account?.icon != null)
                  Icon(
                    IconData(
                      int.parse(_account!.icon!),
                      fontFamily: 'MaterialIcons',
                    ),
                    color: Theme.of(context).colorScheme.primary,
                    size: 32.0,
                  ),
                if (_account?.icon != null)
                  const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _account!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_account?.note != null) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          _account!.note!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              '当前余额',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              _account!.balance.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _account!.balance >= 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatisticsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '本月统计',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildStatisticsItem(
                    label: '收入',
                    amount: 1000.0, // TODO: 从服务获取实际数据
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildStatisticsItem(
                    label: '支出',
                    amount: 500.0, // TODO: 从服务获取实际数据
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatisticsItem({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 4.0),
        Text(
          amount.toStringAsFixed(2),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// 构建最近交易卡片
  Widget _buildRecentTransactionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '最近���易',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: 跳转到交易列表页面
                  },
                  child: const Text('查看全部'),
                ),
              ],
            ),
            if (_recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48.0,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '暂无交易记录',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentTransactions.length,
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  final transaction = _recentTransactions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.5),
                      child: Icon(
                        Icons.receipt_outlined,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(transaction.note ?? '无备注'),
                    subtitle: Text(
                      transaction.date.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    trailing: Text(
                      transaction.amount.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: transaction.amount >= 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    onTap: () {
                      // TODO: 跳转到交易详情页面
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
} 