import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/data_export_import.dart';
import '../providers/data_export_import_provider.dart';
import '../widgets/export_options_form.dart';
import '../widgets/import_options_form.dart';
import '../widgets/backup_list_view.dart';
import '../widgets/progress_dialog.dart';

/// 数据导出导入页面
class DataExportImportPage extends StatelessWidget {
  static const String routeName = '/data-export-import';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('数据导出导入'),
          bottom: TabBar(
            tabs: [
              Tab(text: '导出'),
              Tab(text: '导入'),
              Tab(text: '备份'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ExportTab(),
            _ImportTab(),
            _BackupTab(),
          ],
        ),
      ),
    );
  }
}

/// 导出标签页
class _ExportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '导出选项',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16.0),
                  ExportOptionsForm(
                    onExport: (options) => _handleExport(context, options),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, ExportOptions options) async {
    try {
      final provider = context.read<DataExportImportProvider>();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          title: '导出数据',
          message: '正在导出数据，请稍候...',
          progress: provider.exportProgress,
        ),
      );

      final filePath = await provider.exportData(options);

      Navigator.pop(context); // 关闭进度对话框

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('数据已导出到：$filePath')),
      );
    } catch (e) {
      Navigator.pop(context); // 关闭进度对话框

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('导出失败'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }
}

/// 导入标签页
class _ImportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '导入选项',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16.0),
                  ImportOptionsForm(
                    onImport: (filePath, options) => _handleImport(
                      context,
                      filePath,
                      options,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImport(
    BuildContext context,
    String filePath,
    ImportOptions options,
  ) async {
    try {
      final provider = context.read<DataExportImportProvider>();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          title: '导入数据',
          message: '正在导入数据，请稍候...',
          progress: provider.importProgress,
        ),
      );

      await provider.importData(filePath, options);

      Navigator.pop(context); // 关闭进度对话框

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('数据导入成功')),
      );
    } catch (e) {
      Navigator.pop(context); // 关闭进度对话框

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('导入失败'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }
}

/// 备份标签页
class _BackupTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _handleBackup(context),
            icon: Icon(Icons.backup),
            label: Text('创建备份'),
          ),
        ),
        Expanded(
          child: BackupListView(
            onRestore: (backupPath) => _handleRestore(context, backupPath),
            onDelete: (backupPath) => _handleDelete(context, backupPath),
          ),
        ),
      ],
    );
  }

  Future<void> _handleBackup(BuildContext context) async {
    try {
      final provider = context.read<DataExportImportProvider>();
      
      // 显示备份名称输入对话框
      final backupName = await showDialog<String>(
        context: context,
        builder: (context) => _BackupNameDialog(),
      );

      if (backupName == null || backupName.isEmpty) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          title: '创建备份',
          message: '正在创建备份，请稍候...',
          progress: provider.exportProgress,
        ),
      );

      final backupPath = await provider.backupData(backupName);

      Navigator.pop(context); // 关闭进度对话框

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份已创建：$backupPath')),
      );
    } catch (e) {
      Navigator.pop(context); // 关闭进度对话框

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('备份失败'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context, String backupPath) async {
    try {
      final provider = context.read<DataExportImportProvider>();

      // 显示确认对话框
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('恢复备份'),
          content: Text('确定要恢复此备份吗？当前数据将被覆盖。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('确定'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          title: '恢复备份',
          message: '正在恢复备份，请稍候...',
          progress: provider.importProgress,
        ),
      );

      await provider.restoreData(backupPath);

      Navigator.pop(context); // 关闭进度对话框

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份恢复成功')),
      );
    } catch (e) {
      Navigator.pop(context); // 关闭进度对话框

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('恢复失败'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context, String backupPath) async {
    try {
      final provider = context.read<DataExportImportProvider>();

      // 显示确认对话框
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('删除备份'),
          content: Text('确定要删除此备份吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('确定'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await provider.deleteBackup(backupPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份已删除')),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('删除失败'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }
}

/// 备份名称输入对话框
class _BackupNameDialog extends StatefulWidget {
  @override
  _BackupNameDialogState createState() => _BackupNameDialogState();
}

class _BackupNameDialogState extends State<_BackupNameDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('创建备份'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: '备份名称',
            hintText: '请输入备份名称',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入备份名称';
            }
            if (value.length > 50) {
              return '备份名称不能超过50个字符';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: Text('确���'),
        ),
      ],
    );
  }
} 