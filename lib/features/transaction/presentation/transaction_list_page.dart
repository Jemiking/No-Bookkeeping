import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/transaction.dart';
import '../application/transaction_service.dart';
import 'transaction_form.dart';

class TransactionListPage extends StatefulWidget {
  final String accountId;

  const TransactionListPage({
    Key? key,
    required this.accountId,
  }) : super(key: key);

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final service = context.read<TransactionService>();
    _transactionsFuture = service.getAccountTransactions(widget.accountId);
  }

  Future<void> _showTransactionForm({Transaction? transaction}) async {
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
        child: TransactionForm(
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

  Future<void> _deleteTransaction(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
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
        final service = context.read<TransactionService>();
        await service.deleteTransaction(transaction.id);
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

  String _formatAmount(Transaction transaction) {
    final symbol = transaction.type == TransactionType.expense ? '-' : '+';
    return '$symbol${transaction.amount} ${transaction.currency}';
  }

  Color _getAmountColor(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易记录'),
      ),
      body: FutureBuilder<List<Transaction>>(
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
              child: Text('暂无交易记录'),
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
                    color: _getAmountColor(transaction),
                  ),
                  title: Text(
                    transaction.description ?? '无描述',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${transaction.date.year}-${transaction.date.month}-${transaction.date.day}',
                  ),
                  trailing: Text(
                    _formatAmount(transaction),
                    style: TextStyle(
                      color: _getAmountColor(transaction),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _showTransactionForm(transaction: transaction),
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