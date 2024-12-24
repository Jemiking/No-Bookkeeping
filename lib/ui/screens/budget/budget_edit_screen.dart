import 'package:flutter/material.dart';
import '../../../core/database/models/budget.dart';
import '../../../core/database/models/category.dart';
import '../../../core/services/budget_service.dart';
import '../../../core/services/category_service.dart';
import '../../widgets/amount_input.dart';
import '../../widgets/category_selector.dart';

/// 预算编辑页面
class BudgetEditScreen extends StatefulWidget {
  /// 预算ID（为null时表示创建新预算）
  final int? budgetId;

  /// 构造函数
  const BudgetEditScreen({
    Key? key,
    this.budgetId,
  }) : super(key: key);

  @override
  State<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends State<BudgetEditScreen> {
  final BudgetService _budgetService = BudgetService();
  final CategoryService _categoryService = CategoryService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  List<Category> _categories = [];
  Category? _selectedCategory;
  double _limit = 0.0;
  bool _isEnabled = true;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// 加载数据
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 加载分类列表
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _categories = categories;
      });

      // 如果是编辑模式，加载预算信息
      if (widget.budgetId != null) {
        final budget = await _budgetService.getBudget(widget.budgetId!);
        if (budget == null) {
          setState(() {
            _error = '预算不存在';
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _nameController.text = budget.name;
          _noteController.text = budget.note ?? '';
          _selectedCategory = _categories.firstWhere(
            (c) => c.id == budget.categoryId,
          );
          _limit = budget.limit;
          _isEnabled = budget.isEnabled;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载数据失败��$e';
        _isLoading = false;
      });
    }
  }

  /// 保存预算
  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择分类'),
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final budget = Budget(
        id: widget.budgetId,
        name: _nameController.text,
        categoryId: _selectedCategory!.id!,
        limit: _limit,
        amount: 0.0,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        isEnabled: _isEnabled,
      );

      if (widget.budgetId == null) {
        await _budgetService.createBudget(budget);
      } else {
        await _budgetService.updateBudget(budget);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _error = '保存预算失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budgetId == null ? '创建预算' : '编辑预算'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveBudget,
            child: const Text('保存'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 16.0),
            _buildCategorySelector(),
            const SizedBox(height: 16.0),
            _buildLimitInput(),
            const SizedBox(height: 16.0),
            _buildNoteField(),
            const SizedBox(height: 16.0),
            _buildEnabledSwitch(),
          ],
        ),
      ),
    );
  }

  /// 构建名称输入框
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '预算名称',
        hintText: '请输入预算名称',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入预算名称';
        }
        return null;
      },
    );
  }

  /// 构建分类选择器
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
        CategorySelector(
          categories: _categories,
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
      ],
    );
  }

  /// 构建限额输入
  Widget _buildLimitInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '预算限额',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
        AmountInput(
          initialAmount: _limit,
          onAmountChanged: (value) {
            setState(() {
              _limit = value;
            });
          },
        ),
      ],
    );
  }

  /// 构建备注输入框
  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: '备注',
        hintText: '请输入备注（选填）',
      ),
    );
  }

  /// 构建启用开关
  Widget _buildEnabledSwitch() {
    return SwitchListTile(
      title: const Text('启用预算'),
      value: _isEnabled,
      onChanged: (value) {
        setState(() {
          _isEnabled = value;
        });
      },
    );
  }
} 