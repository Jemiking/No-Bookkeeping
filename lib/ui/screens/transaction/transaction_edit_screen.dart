import 'package:flutter/material.dart';
import '../../../core/database/models/transaction.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/models/category.dart';
import '../../../core/database/models/tag.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/services/account_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/tag_service.dart';
import '../../widgets/amount_input.dart';
import '../../widgets/date_picker.dart';
import '../../widgets/category_selector.dart';
import '../../widgets/tag_selector.dart';
import '../../widgets/note_input.dart';

/// 交易编辑页面
class TransactionEditScreen extends StatefulWidget {
  /// 交易ID（为null时表示创建新交易）
  final int? transactionId;

  /// 账户ID（可选，用于预设账户）
  final int? accountId;

  /// 构造函数
  const TransactionEditScreen({
    Key? key,
    this.transactionId,
    this.accountId,
  }) : super(key: key);

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  final TagService _tagService = TagService();

  Transaction? _transaction;
  List<Account> _accounts = [];
  List<Category> _categories = [];
  List<Tag> _tags = [];
  bool _isLoading = true;
  String? _error;

  Account? _selectedAccount;
  Category? _selectedCategory;
  List<Tag> _selectedTags = [];
  double _amount = 0.0;
  DateTime _date = DateTime.now();
  String? _note;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final futures = [
        _accountService.getAllAccounts(),
        _categoryService.getAllCategories(),
        _tagService.getAllTags(),
      ];

      if (widget.transactionId != null) {
        futures.add(_transactionService.getTransaction(widget.transactionId!));
      }

      final results = await Future.wait(futures);

      setState(() {
        _accounts = results[0] as List<Account>;
        _categories = results[1] as List<Category>;
        _tags = results[2] as List<Tag>;

        if (widget.transactionId != null) {
          _transaction = results[3] as Transaction?;
          if (_transaction != null) {
            _selectedAccount = _accounts.firstWhere(
              (a) => a.id == _transaction!.accountId,
            );
            _selectedCategory = _categories.firstWhere(
              (c) => c.id == _transaction!.categoryId,
            );
            _selectedTags = _tags
                .where((t) => _transaction!.tags.contains(t.id))
                .toList();
            _amount = _transaction!.amount;
            _date = _transaction!.date;
            _note = _transaction!.note;
          }
        } else if (widget.accountId != null) {
          _selectedAccount = _accounts.firstWhere(
            (a) => a.id == widget.accountId,
            orElse: () => _accounts.first,
          );
        } else {
          _selectedAccount = _accounts.first;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载数据失败：$e';
        _isLoading = false;
      });
    }
  }

  /// 保存交易
  Future<void> _saveTransaction() async {
    if (_selectedAccount == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择账户和分类'),
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final transaction = Transaction(
        id: widget.transactionId,
        accountId: _selectedAccount!.id!,
        categoryId: _selectedCategory!.id!,
        amount: _amount,
        date: _date,
        note: _note,
        tags: _selectedTags.map((t) => t.id!).toList(),
      );

      if (widget.transactionId == null) {
        await _transactionService.createTransaction(transaction);
      } else {
        await _transactionService.updateTransaction(transaction);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = '保存交易失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionId == null ? '新建交易' : '编辑交易'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTransaction,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountInput(),
          const SizedBox(height: 16.0),
          _buildAccountSelector(),
          const SizedBox(height: 16.0),
          _buildCategorySelector(),
          const SizedBox(height: 16.0),
          _buildDatePicker(),
          const SizedBox(height: 16.0),
          _buildTagSelector(),
          const SizedBox(height: 16.0),
          _buildNoteInput(),
        ],
      ),
    );
  }

  /// 构建金额输入
  Widget _buildAmountInput() {
    return AmountInput(
      initialAmount: _amount,
      onAmountChanged: (value) {
        setState(() {
          _amount = value;
        });
      },
    );
  }

  /// 构建账户选择器
  Widget _buildAccountSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '账户',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _accounts.map((account) {
                return ChoiceChip(
                  label: Text(account.name),
                  selected: _selectedAccount?.id == account.id,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedAccount = account;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分类选择器
  Widget _buildCategorySelector() {
    return CategorySelector(
      categories: _categories,
      selectedCategory: _selectedCategory,
      onCategorySelected: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  /// 构建日期选择器
  Widget _buildDatePicker() {
    return DatePicker(
      selectedDate: _date,
      onDateChanged: (date) {
        setState(() {
          _date = date;
        });
      },
    );
  }

  /// 构建标签选择器
  Widget _buildTagSelector() {
    return TagSelector(
      tags: _tags,
      selectedTags: _selectedTags,
      onTagsSelected: (tags) {
        setState(() {
          _selectedTags = tags;
        });
      },
    );
  }

  /// 构建备注输入
  Widget _buildNoteInput() {
    return NoteInput(
      initialNote: _note,
      onNoteChanged: (note) {
        setState(() {
          _note = note;
        });
      },
    );
  }
} 