import 'package:flutter/material.dart';
import '../services/transaction_batch_service.dart';

class TransactionBatchOperationPanel extends StatelessWidget {
  final List<String> selectedTransactionIds;
  final TransactionBatchService batchService;

  const TransactionBatchOperationPanel({
    Key? key,
    required this.selectedTransactionIds,
    required this.batchService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOperationButton(
                context,
                icon: Icons.delete,
                label: '批量删除',
                onPressed: () => _handleBatchDelete(context),
              ),
              _buildOperationButton(
                context,
                icon: Icons.category,
                label: '更新分类',
                onPressed: () => _handleUpdateCategory(context),
              ),
              _buildOperationButton(
                context,
                icon: Icons.label,
                label: '更新标签',
                onPressed: () => _handleUpdateTags(context),
              ),
              _buildOperationButton(
                context,
                icon: Icons.file_download,
                label: '批量导出',
                onPressed: () => _handleBatchExport(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(label, style: Theme.of(context).textTheme.caption),
      ],
    );
  }

  Future<void> _handleBatchDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${selectedTransactionIds.length} 条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await batchService.batchDeleteTransactions(selectedTransactionIds);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    }
  }

  Future<void> _handleUpdateCategory(BuildContext context) async {
    // 实现更新分类的UI逻辑
  }

  Future<void> _handleUpdateTags(BuildContext context) async {
    // 实现更新标签的UI逻辑
  }

  Future<void> _handleBatchExport(BuildContext context) async {
    // 实现批量导出的UI逻辑
  }
} 