import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme_manager.dart';
import '../models/transaction.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Transaction _transaction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 从数据库加载交易记录
      // 临时数据
      _transaction = Transaction(
        id: widget.transactionId,
        title: '早餐',
        amount: -38.00,
        categoryId: 'food',
        categoryName: '餐饮',
        accountId: 'cmb',
        accountName: '招商银行',
        date: DateTime.now(),
        type: 'expense',
        note: '肠粉+豆浆',
        attachments: [
          'receipts/20240122_001.jpg',
          'receipts/20240122_002.jpg',
        ],
        tags: ['早餐', '工作日'],
        location: '广州市天河区',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败：$e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // TODO: 实现删除逻辑
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('删除失败：$e')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('生成图片'),
              onTap: () {
                // TODO: 实现生成图片分享
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('导出Excel'),
              onTap: () {
                // TODO: 实现导出Excel
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享到其他应用'),
              onTap: () {
                // TODO: 实现分享到其他应用
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('账单详情'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareOptions,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 导航到编辑页面
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 金额区域
            Container(
              padding: const EdgeInsets.all(24.0),
              color: theme.primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    _transaction.amount > 0
                        ? '+${_transaction.amount.toStringAsFixed(2)}'
                        : _transaction.amount.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: _transaction.amount > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _transaction.type == 'expense' ? '支出' : '收入',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            // 详细信息
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.category,
                    label: '分类',
                    value: _transaction.categoryName,
                  ),
                  _buildInfoItem(
                    icon: Icons.account_balance_wallet,
                    label: '账户',
                    value: _transaction.accountName,
                  ),
                  _buildInfoItem(
                    icon: Icons.access_time,
                    label: '时间',
                    value: DateFormat('yyyy-MM-dd HH:mm').format(_transaction.date),
                  ),
                  if (_transaction.location != null)
                    _buildInfoItem(
                      icon: Icons.location_on,
                      label: '位置',
                      value: _transaction.location!,
                    ),
                  if (_transaction.note.isNotEmpty)
                    _buildInfoItem(
                      icon: Icons.note,
                      label: '备注',
                      value: _transaction.note,
                    ),
                ],
              ),
            ),
            // 标签
            if (_transaction.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '标签',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _transaction.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            // 附件
            if (_transaction.attachments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '附件',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _transaction.attachments.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // TODO: 查看附件
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(Icons.insert_drive_file),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.0,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 