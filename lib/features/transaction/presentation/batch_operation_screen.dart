import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/batch_operation.dart';
import '../providers/batch_operation_provider.dart';

class BatchOperationScreen extends ConsumerWidget {
  const BatchOperationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchOperations = ref.watch(batchOperationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('批量操作'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(batchOperationsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: batchOperations.when(
        data: (operations) => _buildOperationsList(context, ref, operations),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('加载失败：${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildOperationsList(
    BuildContext context,
    WidgetRef ref,
    List<BatchOperation> operations,
  ) {
    if (operations.isEmpty) {
      return const Center(
        child: Text('暂无批量操作'),
      );
    }

    return ListView.builder(
      itemCount: operations.length,
      itemBuilder: (context, index) {
        final operation = operations[index];
        return _BatchOperationCard(operation: operation);
      },
    );
  }
}

class _BatchOperationCard extends ConsumerWidget {
  final BatchOperation operation;

  const _BatchOperationCard({
    Key? key,
    required this.operation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(batchOperationResultProvider(operation.id));

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildDetails(context),
            if (!operation.isCompleted) ...[
              const SizedBox(height: 16),
              _buildActions(context, ref),
            ],
            if (operation.isCompleted) ...[
              const SizedBox(height: 16),
              _buildResult(context, result),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getOperationTypeText(operation.type),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        operation.isCompleted ? '已完成' : '待执行',
        style: TextStyle(
          color: operation.isCompleted ? Colors.white : Colors.black,
        ),
      ),
      backgroundColor: operation.isCompleted ? Colors.green : Colors.grey[300],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('创建时间：${_formatDateTime(operation.createdAt)}'),
        const SizedBox(height: 4),
        Text('交易数量：${operation.transactionIds.length}'),
        if (operation.error != null) ...[
          const SizedBox(height: 4),
          Text(
            '错误信息：${operation.error}',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            ref.read(batchOperationsProvider.notifier).deleteBatchOperation(
                  operation.id,
                );
          },
          child: const Text('删除'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            final executor = BatchOperationExecutor(
              ref.read(batchOperationServiceProvider),
              onProgress: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            );

            await executor.execute(operation);
            ref.read(batchOperationsProvider.notifier).refresh();
          },
          child: const Text('执行'),
        ),
      ],
    );
  }

  Widget _buildResult(
    BuildContext context,
    AsyncValue<BatchOperationResult?> result,
  ) {
    return result.when(
      data: (data) {
        if (data == null) {
          return const Text('无执行结果');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '执行结果',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('成功：${data.successfulIds.length}'),
            Text('失败：${data.failedIds.length}'),
            if (data.failedIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '失败详情：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...data.errors.entries.map(
                (e) => Text('${e.key}: ${e.value}'),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text(
        '加载结果失败：${error.toString()}',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  String _getOperationTypeText(BatchOperationType type) {
    switch (type) {
      case BatchOperationType.delete:
        return '批量删除';
      case BatchOperationType.update:
        return '批量更新';
      case BatchOperationType.archive:
        return '批量归档';
      case BatchOperationType.unarchive:
        return '批量取消归档';
      case BatchOperationType.changeCategory:
        return '批量修改分类';
      case BatchOperationType.changeAccount:
        return '批量修改账户';
      case BatchOperationType.addTags:
        return '批量添加标签';
      case BatchOperationType.removeTags:
        return '批量移除标签';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class BatchOperationDialog extends ConsumerWidget {
  final List<String> selectedTransactionIds;

  const BatchOperationDialog({
    Key? key,
    required this.selectedTransactionIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('批量操作'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOperationButton(
            context,
            ref,
            '删除',
            BatchOperationType.delete,
          ),
          _buildOperationButton(
            context,
            ref,
            '归档',
            BatchOperationType.archive,
          ),
          _buildOperationButton(
            context,
            ref,
            '取消归档',
            BatchOperationType.unarchive,
          ),
          _buildOperationButton(
            context,
            ref,
            '修改分类',
            BatchOperationType.changeCategory,
            showUpdateDataDialog: true,
          ),
          _buildOperationButton(
            context,
            ref,
            '修改账户',
            BatchOperationType.changeAccount,
            showUpdateDataDialog: true,
          ),
          _buildOperationButton(
            context,
            ref,
            '添加标签',
            BatchOperationType.addTags,
            showUpdateDataDialog: true,
          ),
          _buildOperationButton(
            context,
            ref,
            '移除标签',
            BatchOperationType.removeTags,
            showUpdateDataDialog: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }

  Widget _buildOperationButton(
    BuildContext context,
    WidgetRef ref,
    String text,
    BatchOperationType type, {
    bool showUpdateDataDialog = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          Map<String, dynamic>? updateData;
          if (showUpdateDataDialog) {
            updateData = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => _UpdateDataDialog(type: type),
            );
            if (updateData == null) return;
          }

          if (context.mounted) {
            final id = await ref.read(batchOperationsProvider.notifier)
                .createBatchOperation(
              type: type,
              transactionIds: selectedTransactionIds,
              updateData: updateData,
            );

            if (context.mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BatchOperationScreen(),
                ),
              );
            }
          }
        },
        child: Text(text),
      ),
    );
  }
}

class _UpdateDataDialog extends StatefulWidget {
  final BatchOperationType type;

  const _UpdateDataDialog({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  _UpdateDataDialogState createState() => _UpdateDataDialogState();
}

class _UpdateDataDialogState extends State<_UpdateDataDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _updateData = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_getDialogTitle()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildFormFields(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop(_updateData);
            }
          },
          child: const Text('确定'),
        ),
      ],
    );
  }

  String _getDialogTitle() {
    switch (widget.type) {
      case BatchOperationType.changeCategory:
        return '选择分类';
      case BatchOperationType.changeAccount:
        return '选择账户';
      case BatchOperationType.addTags:
        return '添加标签';
      case BatchOperationType.removeTags:
        return '移除标签';
      default:
        return '更新数据';
    }
  }

  List<Widget> _buildFormFields() {
    switch (widget.type) {
      case BatchOperationType.changeCategory:
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: '分类ID'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入分类ID';
              }
              return null;
            },
            onSaved: (value) {
              _updateData['categoryId'] = value;
            },
          ),
        ];
      case BatchOperationType.changeAccount:
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: '账户ID'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入账户ID';
              }
              return null;
            },
            onSaved: (value) {
              _updateData['accountId'] = value;
            },
          ),
        ];
      case BatchOperationType.addTags:
      case BatchOperationType.removeTags:
        return [
          TextFormField(
            decoration: const InputDecoration(
              labelText: '标签',
              helperText: '多个标签用逗号分隔',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入标签';
              }
              return null;
            },
            onSaved: (value) {
              _updateData['tags'] = value!.split(',').map((e) => e.trim()).toList();
            },
          ),
        ];
      default:
        return [];
    }
  }
} 