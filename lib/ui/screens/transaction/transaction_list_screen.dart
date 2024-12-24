import 'package:flutter/material.dart';
import '../../../core/database/models/transaction.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/services/account_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/tag_service.dart';

/// 交易列表页面
class TransactionListScreen extends StatefulWidget {
  /// 账户ID（可选，用于筛选特定账户的交易）
  final int? accountId;

  /// 构造函数
  const TransactionListScreen({
    Key? key,
    this.accountId,
  }) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  final TagService _tagService = TagService();

  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadMoreTransactions();
      }
    }
  }

  /// 加载交易列表
  Future<void> _loadTransactions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final transactions = await _transactionService.getTransactions(
        accountId: widget.accountId,
        page: 1,
        pageSize: _pageSize,
      );

      setState(() {
        _transactions = transactions;
        _isLoading = false;
        _hasMore = transactions.length == _pageSize;
        _currentPage = 1;
      });
    } catch (e) {
      setState(() {
        _error = '加载交易失败：$e';
        _isLoading = false;
      });
    }
  }

  /// 加载更多交易
  Future<void> _loadMoreTransactions() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final transactions = await _transactionService.getTransactions(
        accountId: widget.accountId,
        page: _currentPage + 1,
        pageSize: _pageSize,
      );

      setState(() {
        _transactions.addAll(transactions);
        _isLoading = false;
        _hasMore = transactions.length == _pageSize;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _error = '加载更多交易失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 显示筛选对话框
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 跳转到交易编辑页面
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_isLoading && _transactions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _transactions.isEmpty) {
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
              onPressed: _loadTransactions,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64.0,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16.0),
            Text(
              '暂无交易记录',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: 跳转到交易编辑页面
              },
              child: const Text('添加交易'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: _transactions.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _transactions.length) {
            return _buildLoadingIndicator();
          }
          return _buildTransactionCard(_transactions[index]);
        },
      ),
    );
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  /// 构建交易卡片
  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          // TODO: 跳转到交易详情页面
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.5),
                    child: Icon(
                      Icons.receipt_outlined,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.note ?? '无备注',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          transaction.date.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    transaction.amount.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: transaction.amount >= 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (transaction.tags.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: transaction.tags.map((tagId) {
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
                            color:
                                Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 8.0),
              Row(
                children: [
                  FutureBuilder(
                    future: _accountService.getAccount(transaction.accountId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      final account = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          account.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8.0),
                  FutureBuilder(
                    future: _categoryService.getCategory(transaction.categoryId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      final category = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          category.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 