import 'package:flutter/material.dart';
import '../../../core/database/models/transaction.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/services/account_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/tag_service.dart';

/// 交易详情页面
class TransactionDetailScreen extends StatefulWidget {
  /// 交易ID
  final int transactionId;

  /// 构造函数
  const TransactionDetailScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  final TagService _tagService = TagService();

  Transaction? _transaction;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  /// 加载交易信息
  Future<void> _loadTransaction() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final transaction = await _transactionService.getTransaction(
        widget.transactionId,
      );
      if (transaction == null) {
        setState(() {
          _error = '交易不存在';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _transaction = transaction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载交易失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 跳转到交易编辑页面
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'delete':
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('删除交易'),
                        content: const Text('确定要删除该交易吗？删除后无法恢复。'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              '删除',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirmed == true) {
                    try {
                      await _transactionService.deleteTransaction(
                        widget.transactionId,
                      );
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('删除交易失败：$e'),
                          ),
                        );
                      }
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    '删除交易',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ];
            },
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
              onPressed: _loadTransaction,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_transaction == null) {
      return const Center(
        child: Text('交易不存在'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountCard(),
          const SizedBox(height: 16.0),
          _buildDetailsCard(),
          const SizedBox(height: 16.0),
          _buildTagsCard(),
          const SizedBox(height: 16.0),
          _buildNoteCard(),
        ],
      ),
    );
  }

  /// 构建金额卡片
  Widget _buildAmountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '金额',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              _transaction!.amount.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _transaction!.amount >= 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建详情卡片
  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '详细信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            _buildDetailItem(
              label: '账户',
              child: FutureBuilder(
                future: _accountService.getAccount(_transaction!.accountId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text('加载中...');
                  }
                  final account = snapshot.data!;
                  return Text(account.name);
                },
              ),
            ),
            const Divider(),
            _buildDetailItem(
              label: '分类',
              child: FutureBuilder(
                future: _categoryService.getCategory(_transaction!.categoryId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text('加载中...');
                  }
                  final category = snapshot.data!;
                  return Text(category.name);
                },
              ),
            ),
            const Divider(),
            _buildDetailItem(
              label: '日期',
              child: Text(_transaction!.date.toString()),
            ),
            const Divider(),
            _buildDetailItem(
              label: '创建时间',
              child: Text(_transaction!.createdAt.toString()),
            ),
            if (_transaction!.updatedAt != null) ...[
              const Divider(),
              _buildDetailItem(
                label: '更新时间',
                child: Text(_transaction!.updatedAt.toString()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建详情项
  Widget _buildDetailItem({
    required String label,
    required Widget child,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyLarge!,
            child: child,
          ),
        ),
      ],
    );
  }

  /// 构建标签卡片
  Widget _buildTagsCard() {
    if (_transaction!.tags.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '标签',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _transaction!.tags.map((tagId) {
                return FutureBuilder(
                  future: _tagService.getTag(tagId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }
                    final tag = snapshot.data!;
                    return Chip(
                      label: Text(tag.name),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.5),
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建备注卡片
  Widget _buildNoteCard() {
    if (_transaction!.note == null) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '备注',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              _transaction!.note!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
} 