import 'package:flutter/material.dart';
import '../models/transaction_template.dart';
import '../services/transaction_template_service.dart';

class TransactionTemplateList extends StatelessWidget {
  final List<TransactionTemplate> templates;
  final TransactionTemplateService templateService;

  const TransactionTemplateList({
    Key? key,
    required this.templates,
    required this.templateService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return ListTile(
          title: Text(template.name),
          subtitle: Text('¥${template.amount}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editTemplate(context, template),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTemplate(context, template),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _createTransactionFromTemplate(context, template),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editTemplate(BuildContext context, TransactionTemplate template) async {
    // 实现编辑模板的UI逻辑
  }

  Future<void> _deleteTemplate(BuildContext context, TransactionTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除模板"${template.name}"吗？'),
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
      final success = await templateService.deleteTemplate(template.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    }
  }

  Future<void> _createTransactionFromTemplate(
    BuildContext context,
    TransactionTemplate template,
  ) async {
    try {
      await templateService.createTransactionFromTemplate(template.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('创建交易成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('创建交易失败')),
      );
    }
  }
} 