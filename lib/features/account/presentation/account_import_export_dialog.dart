import 'package:flutter/material.dart';
import '../domain/account.dart';
import '../domain/account_import_export.dart';

class AccountImportExportDialog extends StatefulWidget {
  final List<Account> accounts;
  final AccountImportExport importExport;
  final Function(List<Account>) onImport;

  const AccountImportExportDialog({
    Key? key,
    required this.accounts,
    required this.importExport,
    required this.onImport,
  }) : super(key: key);

  @override
  State<AccountImportExportDialog> createState() => _AccountImportExportDialogState();
}

class _AccountImportExportDialogState extends State<AccountImportExportDialog> {
  bool _isLoading = false;
  String? _error;
  String? _importData;

  Future<void> _exportToJson() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jsonString = await widget.importExport.exportToJson(widget.accounts);
      // TODO: Save file using platform-specific file picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导出JSON成功')),
      );
    } catch (e) {
      setState(() {
        _error = '导出JSON失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportToCsv() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final csvString = await widget.importExport.exportToCsv(widget.accounts);
      // TODO: Save file using platform-specific file picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导出CSV成功')),
      );
    } catch (e) {
      setState(() {
        _error = '导出CSV失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importFromJson() async {
    if (_importData == null || _importData!.isEmpty) {
      setState(() {
        _error = '请输入要导入的JSON数据';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final accounts = await widget.importExport.importFromJson(_importData!);
      widget.onImport(accounts);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导入JSON成功')),
      );
    } catch (e) {
      setState(() {
        _error = '导入JSON失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importFromCsv() async {
    if (_importData == null || _importData!.isEmpty) {
      setState(() {
        _error = '请输入要导入的CSV数据';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final accounts = await widget.importExport.importFromCsv(_importData!);
      widget.onImport(accounts);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导入CSV成功')),
      );
    } catch (e) {
      setState(() {
        _error = '导入CSV失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('账户导入导出'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('导出'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _exportToJson,
                  child: const Text('导出JSON'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _exportToCsv,
                  child: const Text('导出CSV'),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('导入'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '请粘贴要导入的JSON或CSV数据',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
              onChanged: (value) {
                setState(() {
                  _importData = value;
                  _error = null;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _importFromJson,
                  child: const Text('导入JSON'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _importFromCsv,
                  child: const Text('导入CSV'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
} 