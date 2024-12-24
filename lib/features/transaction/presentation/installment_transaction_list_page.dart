import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/installment_transaction.dart';
import '../application/installment_transaction_service.dart';
import 'installment_transaction_form.dart';

class InstallmentTransactionListPage extends StatefulWidget {
  final String accountId;

  const InstallmentTransactionListPage({
    Key? key,
    required this.accountId,
  }) : super(key: key);

  @override
  State<InstallmentTransactionListPage> createState() => _InstallmentTransactionListPageState();
}

class _InstallmentTransactionListPageState extends State<InstallmentTransactionListPage> {
  late Future<List<InstallmentTransaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final service = context.read<InstallmentTransactionService>();
    _transactionsFuture = service.getAccountInstallmentTransactions(widget.accountId);
  }

  Future<void> _showTransactionForm({InstallmentTransaction? transaction}) async {
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
        child: InstallmentTransactionForm(
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

  Future<void> _deleteTransaction(InstallmentTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条分期付款吗？'),
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
        final service = context.read<InstallmentTransactionService>();
        await service.deleteInstallmentTransaction(transaction.id);
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

  Future<void> _toggleTransactionStatus(InstallmentTransaction transaction) async {
    try {
      final service = context.read<InstallmentTransactionService>();
      if (transaction.isActive) {
        await service.deactivateInstallmentTransaction(transaction.id);
      } else {
        final updatedTransaction = transaction.copyWith(
          isActive: true,
          updatedAt: DateTime.now(),
        );
        await service.updateInstallmentTransaction(updatedTransaction);
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

  Future<void> _showInstallmentDetails(InstallmentTransaction transaction) async {
    final service = context.read<InstallmentTransactionService>();
    final nextDates = await service.getNextInstallmentDates(transaction.id, 5);
    final remainingAmount = await service.calculateRemainingAmount(transaction.id);
    final paidAmount = await service.calculatePaidAmount(transaction.id);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('分期详情'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('总金额: ${transaction.totalAmount} ${transaction.currency}'),
              Text('已还金额: $paidAmount ${transaction.currency}'),
              Text('剩余金额: $remainingAmount ${transaction.currency}'),
              Text('每期金额: ${transaction.installmentAmount} ${transaction.currency}'),
              Text('剩余期数: ${transaction.remainingInstallments}/${transaction.totalInstallments}'),
              if (nextDates.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('未来还款日期:'),
                ...nextDates.map((date) => Text(
                  '${date.year}-${date.month}-${date.day}',
                )),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分期付款'),
      ),
      body: FutureBuilder<List<InstallmentTransaction>>(
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
              child: Text('暂无分期付款'),
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
                    Icons.payments,
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
                    '${transaction.remainingInstallments}/${transaction.totalInstallments} 期 - ${transaction.installmentAmount} ${transaction.currency}/期',
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
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showInstallmentDetails(transaction),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTransactionForm(transaction: transaction),
                      ),
                    ],
                  ),
                  onTap: () => _showInstallmentDetails(transaction),
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