import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/periodic_budget.dart';
import '../services/periodic_budget_service.dart';
import '../services/category_service.dart';

class PeriodicBudgetScreen extends StatefulWidget {
  const PeriodicBudgetScreen({Key? key}) : super(key: key);

  @override
  _PeriodicBudgetScreenState createState() => _PeriodicBudgetScreenState();
}

class _PeriodicBudgetScreenState extends State<PeriodicBudgetScreen> {
  final PeriodicBudgetService _budgetService = PeriodicBudgetService();
  final CategoryService _categoryService = CategoryService();
  List<PeriodicBudget> _budgets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    setState(() => _isLoading = true);
    try {
      final budgets = await _budgetService.getAll();
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

  String _getPeriodText(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.daily:
        return '每日';
      case BudgetPeriod.weekly:
        return '每周';
      case BudgetPeriod.monthly:
        return '每月';
      case BudgetPeriod.quarterly:
        return '每季度';
      case BudgetPeriod.yearly:
        return '每年';
    }
  }

  Future<void> _showAddEditBudgetDialog([PeriodicBudget? budget]) async {
    final categories = await _categoryService.getAll();
    String? selectedCategoryId = budget?.categoryId ?? categories.firstOrNull?.id;
    String name = budget?.name ?? '';
    double amount = budget?.amount ?? 0;
    BudgetPeriod period = budget?.period ?? BudgetPeriod.monthly;
    DateTime startDate = budget?.startDate ?? DateTime.now();
    String notes = budget?.notes ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(budget == null ? '添加周期预算' : '编辑周期预算'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: '预算名称'),
                onChanged: (value) => name = value,
              ),
              TextFormField(
                initialValue: amount.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '预算金额'),
                onChanged: (value) => amount = double.tryParse(value) ?? 0,
              ),
              DropdownButtonFormField<BudgetPeriod>(
                value: period,
                items: BudgetPeriod.values.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(_getPeriodText(p)),
                  );
                }).toList(),
                onChanged: (value) => period = value!,
                decoration: const InputDecoration(labelText: '周期'),
              ),
              if (categories.isNotEmpty)
                DropdownButtonFormField<String?>(
                  value: selectedCategoryId,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('不限分类'),
                    ),
                    ...categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }),
                  ],
                  onChanged: (value) => selectedCategoryId = value,
                  decoration: const InputDecoration(labelText: '分类（可选）'),
                ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    startDate = date;
                  }
                },
                child: Text('开始日期: ${startDate.toString().split(' ')[0]}'),
              ),
              TextFormField(
                initialValue: notes,
                decoration: const InputDecoration(labelText: '备注'),
                onChanged: (value) => notes = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (name.isEmpty || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写完整信息')),
                );
                return;
              }

              final newBudget = PeriodicBudget(
                id: budget?.id ?? const Uuid().v4(),
                name: name,
                amount: amount,
                period: period,
                startDate: startDate,
                categoryId: selectedCategoryId,
                notes: notes,
              );

              try {
                if (budget == null) {
                  await _budgetService.create(newBudget);
                } else {
                  await _budgetService.update(newBudget);
                }
                Navigator.pop(context);
                _loadBudgets();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('保存失败: ${e.toString()}')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('周期预算管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _budgets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('暂无周期预算'),
                      ElevatedButton(
                        onPressed: _showAddEditBudgetDialog,
                        child: const Text('添加预算'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _budgets.length,
                  itemBuilder: (context, index) {
                    final budget = _budgets[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(budget.name),
                            const SizedBox(width: 8),
                            Text(
                              _getPeriodText(budget.period),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (budget.categoryId != null)
                              FutureBuilder(
                                future: _categoryService.get(budget.categoryId!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text('分类: ${snapshot.data!.name}');
                                  }
                                  return const SizedBox();
                                },
                              ),
                            Text('预算: ¥${budget.amount.toStringAsFixed(2)}'),
                            Text('已用: ¥${budget.spent.toStringAsFixed(2)}'),
                            Text('剩余: ¥${budget.remaining.toStringAsFixed(2)}'),
                            Text('开始日期: ${budget.startDate.toString().split(' ')[0]}'),
                            if (budget.notes.isNotEmpty) Text('备注: ${budget.notes}'),
                            LinearProgressIndicator(
                              value: budget.progress / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                budget.isOverBudget ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('编辑'),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(budget.isActive ? '停用' : '启用'),
                            ),
                            const PopupMenuItem(
                              value: 'reset',
                              child: Text('重置支出'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('删除'),
                            ),
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 'edit':
                                await _showAddEditBudgetDialog(budget);
                                break;
                              case 'toggle':
                                if (budget.isActive) {
                                  await _budgetService.deactivate(budget.id);
                                } else {
                                  await _budgetService.activate(budget.id);
                                }
                                _loadBudgets();
                                break;
                              case 'reset':
                                await _budgetService.resetSpentAmount(budget.id);
                                _loadBudgets();
                                break;
                              case 'delete':
                                await _budgetService.delete(budget.id);
                                _loadBudgets();
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEditBudgetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 