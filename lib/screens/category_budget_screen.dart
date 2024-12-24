import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category_budget.dart';
import '../services/category_budget_service.dart';
import '../services/category_service.dart';
import '../widgets/custom_date_picker.dart';

class CategoryBudgetScreen extends StatefulWidget {
  const CategoryBudgetScreen({Key? key}) : super(key: key);

  @override
  _CategoryBudgetScreenState createState() => _CategoryBudgetScreenState();
}

class _CategoryBudgetScreenState extends State<CategoryBudgetScreen> {
  final CategoryBudgetService _budgetService = CategoryBudgetService();
  final CategoryService _categoryService = CategoryService();
  List<CategoryBudget> _budgets = [];
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
        SnackBar(content: Text('加���预算失败: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddEditBudgetDialog([CategoryBudget? budget]) async {
    final categories = await _categoryService.getAll();
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先添加支出分类')),
      );
      return;
    }

    String? selectedCategoryId = budget?.categoryId ?? categories.first.id;
    double amount = budget?.amount ?? 0;
    DateTime startDate = budget?.startDate ?? DateTime.now();
    DateTime endDate = budget?.endDate ?? DateTime.now().add(const Duration(days: 30));
    String notes = budget?.notes ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(budget == null ? '添加分类预算' : '编辑分类预算'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) => selectedCategoryId = value,
                decoration: const InputDecoration(labelText: '选择分类'),
              ),
              TextFormField(
                initialValue: amount.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '预算金额'),
                onChanged: (value) => amount = double.tryParse(value) ?? 0,
              ),
              CustomDatePicker(
                label: '开始日期',
                initialDate: startDate,
                onDateSelected: (date) => startDate = date,
              ),
              CustomDatePicker(
                label: '结束日期',
                initialDate: endDate,
                onDateSelected: (date) => endDate = date,
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
              if (selectedCategoryId == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写完整信息')),
                );
                return;
              }

              final newBudget = CategoryBudget(
                id: budget?.id ?? const Uuid().v4(),
                categoryId: selectedCategoryId!,
                amount: amount,
                startDate: startDate,
                endDate: endDate,
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
        title: const Text('分类预算管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _budgets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('暂无分类预算'),
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
                        title: FutureBuilder(
                          future: _categoryService.get(budget.categoryId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data!.name);
                            }
                            return const Text('加载中...');
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('预算: ¥${budget.amount.toStringAsFixed(2)}'),
                            Text('已用: ¥${budget.spent.toStringAsFixed(2)}'),
                            Text('剩余: ¥${budget.remaining.toStringAsFixed(2)}'),
                            Text('${budget.startDate.toString().split(' ')[0]} 至 ${budget.endDate.toString().split(' ')[0]}'),
                            if (budget.notes.isNotEmpty) Text('备注: ${budget.notes}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('编辑'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('删除'),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await _showAddEditBudgetDialog(budget);
                            } else if (value == 'delete') {
                              await _budgetService.delete(budget.id);
                              _loadBudgets();
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