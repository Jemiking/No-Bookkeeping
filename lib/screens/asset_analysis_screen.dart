import 'package:flutter/material.dart';
import 'package:money_tracker/models/domain/account.dart';
import 'package:money_tracker/services/account_service.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:money_tracker/services/transaction_service.dart';

class AssetAnalysisScreen extends StatefulWidget {
  const AssetAnalysisScreen({super.key});

  @override
  State<AssetAnalysisScreen> createState() => _AssetAnalysisScreenState();
}

class _AssetAnalysisScreenState extends State<AssetAnalysisScreen> {
  final AccountService _accountService = AccountService(DatabaseService());
  final TransactionService _transactionService = TransactionService(DatabaseService());
  bool _isLoading = false;
  List<Account> _accounts = [];
  double _totalIncome = 0;
  double _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accounts = await _accountService.getAllAccounts();
      final totalIncome = await _transactionService.getTotalIncome();
      final totalExpense = await _transactionService.getTotalExpense();

      setState(() {
        _accounts = accounts;
        _totalIncome = totalIncome;
        _totalExpense = totalExpense;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAssets = _accounts.fold<double>(
      0,
      (sum, account) => sum + account.balance,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('资产分析'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '资产概览',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                label: '总资产',
                                amount: totalAssets,
                                color: Colors.blue,
                              ),
                              _buildSummaryItem(
                                label: '总收入',
                                amount: _totalIncome,
                                color: Colors.green,
                              ),
                              _buildSummaryItem(
                                label: '总支出',
                                amount: _totalExpense,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '账户分布',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_accounts.isEmpty)
                            const Center(child: Text('暂无账户'))
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _accounts.length,
                              itemBuilder: (context, index) {
                                final account = _accounts[index];
                                final percentage = account.balance / totalAssets * 100;
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.account_balance),
                                      title: Text(account.name),
                                      subtitle: Text('余额: ${account.balance}'),
                                      trailing: Text('${percentage.toStringAsFixed(1)}%'),
                                    ),
                                    if (index < _accounts.length - 1)
                                      const Divider(),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required Color color,
  }) {
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
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
} 