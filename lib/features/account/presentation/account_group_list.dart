import 'package:flutter/material.dart';
import '../domain/account.dart';
import '../domain/account_group.dart';
import '../domain/balance_calculator.dart';

class AccountGroupList extends StatelessWidget {
  final List<AccountGroup> groups;
  final Map<String, Account> accountMap;
  final Function(AccountGroup) onEdit;
  final Function(String) onDelete;
  final BalanceCalculator balanceCalculator;

  const AccountGroupList({
    Key? key,
    required this.groups,
    required this.accountMap,
    required this.onEdit,
    required this.onDelete,
    required this.balanceCalculator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ExpansionTile(
            title: Text(group.name),
            subtitle: group.description != null
                ? Text(
                    group.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<Map<String, double>>(
                  stream: balanceCalculator.watchBalances(group.accountIds),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final balances = snapshot.data!;
                    final totalByCurrency = <String, double>{};

                    for (final accountId in group.accountIds) {
                      final account = accountMap[accountId];
                      if (account != null) {
                        final balance = balances[accountId] ?? 0;
                        totalByCurrency[account.currency] =
                            (totalByCurrency[account.currency] ?? 0) + balance;
                      }
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: totalByCurrency.entries.map((entry) {
                        return Text(
                          '${entry.value.toStringAsFixed(2)} ${entry.key}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit(group);
                        break;
                      case 'delete':
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('确认删除'),
                            content: const Text('确定要删除这个账户组吗？此操作不可撤销。'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onDelete(group.id);
                                },
                                child: const Text(
                                  '删除',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('编辑'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.accountIds.length,
                itemBuilder: (context, index) {
                  final accountId = group.accountIds[index];
                  final account = accountMap[accountId];
                  if (account == null) return const SizedBox.shrink();

                  return ListTile(
                    leading: Icon(_getAccountTypeIcon(account.type)),
                    title: Text(account.name),
                    subtitle: Text(account.currency),
                    trailing: StreamBuilder<double>(
                      stream: balanceCalculator.watchBalance(account.id),
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.money;
      case AccountType.bankCard:
        return Icons.credit_card;
      case AccountType.creditCard:
        return Icons.credit_score;
      case AccountType.alipay:
        return Icons.account_balance_wallet;
      case AccountType.wechat:
        return Icons.chat;
      case AccountType.other:
        return Icons.account_balance;
    }
  }
} 