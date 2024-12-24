import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class BudgetManagementScreen extends StatefulWidget {
  final BudgetService budgetService;

  const BudgetManagementScreen({Key? key, required this.budgetService}) : super(key: key);

  @override
  _BudgetManagementScreenState createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  List<Budget> _budgets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    setState(() => _isLoading = true);
    try {
      final budgets = await widget.budgetService.getAll();
      setState(() {
        _budgets = budgets;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载预算失败: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预算管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _budgets.isEmpty
              ? const Center(child: Text('暂无预算'))
              : ListView.builder(
                  itemCount: _budgets.length,
                  itemBuilder: (context, index) {
                    final budget = _budgets[index];
                    return _buildBudgetCard(budget);
                  },
                ),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final progress = budget.progress;
    final isOverBudget = budget.isOverBudget;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${budget.currency} ${budget.amount}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('已支出: ${budget.currency} ${budget.spent}'),
                Text('剩余: ${budget.currency} ${budget.remaining}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${budget.startDate.toString().split(' ')[0]} - ${budget.endDate.toString().split(' ')[0]}'),
                Text('进度: ${progress.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddBudgetDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    double amount = 0;
    String currency = 'CNY';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加预算'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: '预算名称'),
                  validator: (value) => value?.isEmpty ?? true ? '请输入预算名称' : null,
                  onSaved: (value) => name = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: '预算金额'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return '请输入预算金额';
                    if (double.tryParse(value) == null) return '请输入有效金额';
                    return null;
                  },
                  onSaved: (value) => amount = double.parse(value ?? '0'),
                ),
                DropdownButtonFormField<String>(
                  value: currency,
                  decoration: const InputDecoration(labelText: '货币'),
                  items: const [
                    DropdownMenuItem(value: 'CNY', child: Text('人民币 (CNY)')),
                    DropdownMenuItem(value: 'USD', child: Text('美元 (USD)')),
                    DropdownMenuItem(value: 'EUR', child: Text('欧元 (EUR)')),
                  ],
                  onChanged: (value) => currency = value ?? 'CNY',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        child: Text('开始日期: ${startDate.toString().split(' ')[0]}'),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => startDate = date);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        child: Text('结束日期: ${endDate.toString().split(' ')[0]}'),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => endDate = date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('保存'),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final budget = Budget(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  amount: amount,
                  startDate: startDate,
                  endDate: endDate,
                  currency: currency,
                );
                try {
                  await widget.budgetService.create(budget);
                  Navigator.of(context).pop();
                  _loadBudgets();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('创建预算失败: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
} 
} 