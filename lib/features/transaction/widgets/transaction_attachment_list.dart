import 'package:flutter/material.dart';
import '../models/transaction_attachment.dart';
import '../services/transaction_attachment_service.dart';

class TransactionAttachmentList extends StatelessWidget {
  final String transactionId;
  final List<TransactionAttachment> attachments;
  final TransactionAttachmentService attachmentService;

  const TransactionAttachmentList({
    Key? key,
    required this.transactionId,
    required this.attachments,
    required this.attachmentService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAddAttachmentButton(context),
        Expanded(
          child: ListView.builder(
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              return ListTile(
                leading: _getFileTypeIcon(attachment.fileType),
                title: Text(attachment.fileName),
                subtitle: Text(_formatFileSize(attachment.fileSize)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => _downloadAttachment(context, attachment),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteAttachment(context, attachment),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddAttachmentButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.attach_file),
        label: const Text('添加附件'),
        onPressed: () => _addAttachment(context),
      ),
    );
  }

  Icon _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Icon(Icons.image);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _addAttachment(BuildContext context) async {
    // 实现添加附件的UI逻辑
  }

  Future<void> _downloadAttachment(
    BuildContext context,
    TransactionAttachment attachment,
  ) async {
    try {
      await attachmentService.downloadAttachment(attachment.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('下载成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('下载失败')),
      );
    }
  }

  Future<void> _deleteAttachment(
    BuildContext context,
    TransactionAttachment attachment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除附件"${attachment.fileName}"吗？'),
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
      final success = await attachmentService.deleteAttachment(attachment.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    }
  }
} 