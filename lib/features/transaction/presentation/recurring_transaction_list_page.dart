import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/recurring_transaction.dart';
import '../application/recurring_transaction_service.dart';
import 'recurring_transaction_form.dart';

class RecurringTransactionListPage extends StatefulWidget {
  final String accountId;

  const RecurringTransactionListPage({
    Key? key,
    required this.accountId,
  }) : super(key: key);

  @override
  State<RecurringTransactionListPage> createState() => _RecurringTransactionListPageState();
}

class _RecurringTransactionListPageState extends State<RecurringTransactionListPage> {
  late Future<List<RecurringTransaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final service = context.read<RecurringTransactionService>();
    _transactionsFuture = service.getAccountRecurringTransactions(widget.accountId);
  }

  Future<void> _showTransactionForm({RecurringTransaction? transaction}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: RecurringTransactionForm(
          transaction: transaction,
          accountId: widget.accountId,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _loadTransactions();
      });
    }
  }

  Future<void> _deleteTransaction(RecurringTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条定期交易吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = context.read<RecurringTransactionService>();
        await service.deleteRecurringTransaction(transaction.id);
        setState(() {
          _loadTransactions();
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _toggleTransactionStatus(RecurringTransaction transaction) async {
    try {
      final service = context.read<RecurringTransactionService>();
      if (transaction.isActive) {
        await service.deactivateRecurringTransaction(transaction.id);
      } else {
        final updatedTransaction = transaction.copyWith(
          isActive: true,
          updatedAt: DateTime.now(),
        );
        await service.updateRecurringTransaction(updatedTransaction);
      }
      setState(() {
        _loadTransactions();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('状态更新失败: ${e.toString()}')),
        );
      }
    }
  }

  String _formatPeriod(RecurringPeriod period) {
    switch (period) {
      case RecurringPeriod.daily:
        return '每天';
      case RecurringPeriod.weekly:
        return '每周';
      case RecurringPeriod.monthly:
        return '每月';
      case RecurringPeriod.yearly:
        return '每年';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定期交易'),
      ),
      body: FutureBuilder<List<RecurringTransaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('加载失败: ${snapshot.error}'),
            );
          }

          final transactions = snapshot.data!;
          if (transactions.isEmpty) {
            return const Center(
              child: Text('暂无定期交易'),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Dismissible(
                key: Key(transaction.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) => _deleteTransaction(transaction),
                child: ListTile(
                  leading: Icon(
                    transaction.type == TransactionType.income
                        ? Icons.arrow_downward
                        : transaction.type == TransactionType.expense
                            ? Icons.arrow_upward
                            : Icons.swap_horiz,
                    color: transaction.isActive ? null : Colors.grey,
                  ),
                  title: Text(
                    transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: transaction.isActive ? null : Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    '${_formatPeriod(transaction.period)} - ${transaction.amount} ${transaction.currency}',
                    style: TextStyle(
                      color: transaction.isActive ? null : Colors.grey,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: transaction.isActive,
                        onChanged: (_) => _toggleTransactionStatus(transaction),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTransactionForm(transaction: transaction),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 