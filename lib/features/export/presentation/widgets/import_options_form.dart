import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/data_export_import.dart';

/// 导入选项表单
class ImportOptionsForm extends StatefulWidget {
  final Function(String, ImportOptions) onImport;

  const ImportOptionsForm({
    Key? key,
    required this.onImport,
  }) : super(key: key);

  @override
  _ImportOptionsFormState createState() => _ImportOptionsFormState();
}

class _ImportOptionsFormState extends State<ImportOptionsForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  String? _selectedFile;
  ExportFormat _format = ExportFormat.excel;
  bool _overwriteExisting = false;
  bool _usePassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFileSelectionField(),
          SizedBox(height: 16.0),
          _buildFormatField(),
          SizedBox(height: 16.0),
          _buildOptionsField(),
          SizedBox(height: 16.0),
          _buildPasswordField(),
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _selectedFile != null ? _handleImport : null,
            child: Text('导入数据'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择文件', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: '请选择要导入的文件',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _selectedFile),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择要导入的文件';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16.0),
            ElevatedButton.icon(
              onPressed: _selectFile,
              icon: Icon(Icons.file_upload),
              label: Text('浏览'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('文件格式', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        DropdownButtonFormField<ExportFormat>(
          value: _format,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          items: [
            DropdownMenuItem(
              value: ExportFormat.excel,
              child: Text('Excel'),
            ),
            DropdownMenuItem(
              value: ExportFormat.csv,
              child: Text('CSV'),
            ),
            DropdownMenuItem(
              value: ExportFormat.json,
              child: Text('JSON'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _format = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildOptionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('导入选项', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        SwitchListTile(
          title: Text('覆盖已存在的数据'),
          subtitle: Text('如果数据已存在，是否覆盖'),
          value: _overwriteExisting,
          onChanged: (value) {
            setState(() => _overwriteExisting = value);
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('文件已加密', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 16.0),
            Switch(
              value: _usePassword,
              onChanged: (value) {
                setState(() => _usePassword = value);
                if (!value) {
                  _passwordController.clear();
                }
              },
            ),
          ],
        ),
        if (_usePassword) ...[
          SizedBox(height: 8.0),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (_usePassword && (value == null || value.isEmpty)) {
                return '请输入密码';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Future<void> _selectFile() async {
    try {
      String? extension;
      switch (_format) {
        case ExportFormat.excel:
          extension = 'xlsx';
          break;
        case ExportFormat.csv:
          extension = 'csv';
          break;
        case ExportFormat.json:
          extension = 'json';
          break;
        default:
          extension = '*';
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [extension],
      );

      if (result != null) {
        setState(() => _selectedFile = result.files.single.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择文件失败：$e')),
      );
    }
  }

  void _handleImport() {
    if (!_formKey.currentState!.validate()) return;

    final options = ImportOptions(
      format: _format,
      overwriteExisting: _overwriteExisting,
      password: _usePassword ? _passwordController.text : null,
    );

    widget.onImport(_selectedFile!, options);
  }
} 