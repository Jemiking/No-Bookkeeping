import 'package:flutter/material.dart';
import '../domain/account.dart';
import '../domain/currency_converter.dart';
import '../domain/balance_calculator.dart';
import 'currency_converter_dialog.dart';

class AccountList extends StatelessWidget {
  final List<Account> accounts;
  final Function(Account) onEdit;
  final Function(String) onDelete;
  final Function(String) onArchive;
  final CurrencyConverter currencyConverter;
  final BalanceCalculator balanceCalculator;

  const AccountList({
    Key? key,
    required this.accounts,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
    required this.currencyConverter,
    required this.balanceCalculator,
  }) : super(key: key);

  void _showCurrencyConverter(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (context) => CurrencyConverterDialog(
        currencyConverter: currencyConverter,
        initialCurrency: account.currency,
        initialAmount: account.balance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(account.name),
            subtitle: Text('${_getAccountTypeText(account.type)} • ${account.currency}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<double>(
                  stream: balanceCalculator.watchBalance(account.id),
                  initialData: account.balance,
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: snapshot.data != account.balance
                            ? Colors.green
                            : null,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.currency_exchange),
                  onPressed: () => _showCurrencyConverter(context, account),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit(account);
                        break;
                      case 'archive':
                        onArchive(account.id);
                        break;
                      case 'delete':
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('确认删除'),
                            content: const Text('确定要删除这个账户吗？此操作不可撤销。'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onDelete(account.id);
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
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(Icons.archive),
                          SizedBox(width: 8),
                          Text('归档'),
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
          ),
        );
      },
    );
  }

  String _getAccountTypeText(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '现金';
      case AccountType.bankCard:
        return '银行卡';
      case AccountType.creditCard:
        return '信用卡';
      case AccountType.alipay:
        return '支付宝';
      case AccountType.wechat:
        return '微信';
      case AccountType.other:
        return '其他';
    }
  }
} 