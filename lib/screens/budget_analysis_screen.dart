import 'package:flutter/material.dart';
import 'package:money_tracker/models/domain/budget.dart';
import 'package:money_tracker/services/budget_service.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:money_tracker/services/transaction_service.dart';

class BudgetAnalysisScreen extends StatefulWidget {
  const BudgetAnalysisScreen({super.key});

  @override
  State<BudgetAnalysisScreen> createState() => _BudgetAnalysisScreenState();
}

class _BudgetAnalysisScreenState extends State<BudgetAnalysisScreen> {
  final BudgetService _budgetService = BudgetService(DatabaseService());
  final TransactionService _transactionService = TransactionService(DatabaseService());
  bool _isLoading = false;
  List<Budget> _budgets = [];
  Map<String, double> _expensesByCategory = {};

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
      final budgets = await _budgetService.getAllBudgets();
      final expensesByCategory = await _transactionService.getExpenseByCategory();

      setState(() {
        _budgets = budgets;
        _expensesByCategory = expensesByCategory;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('预算分析'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _budgets.length,
                itemBuilder: (context, index) {
                  final budget = _budgets[index];
                  final spent = _expensesByCategory[budget.id] ?? 0.0;
                  final progress = spent / budget.amount;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                budget.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${spent.toStringAsFixed(2)} / ${budget.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: progress >= 1 ? Colors.red : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1 ? Colors.red : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: progress >= 1 ? Colors.red : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
} 