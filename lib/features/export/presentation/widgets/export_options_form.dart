import 'package:flutter/material.dart';
import '../../domain/data_export_import.dart';

/// 导出选项表单
class ExportOptionsForm extends StatefulWidget {
  final Function(ExportOptions) onExport;

  const ExportOptionsForm({
    Key? key,
    required this.onExport,
  }) : super(key: key);

  @override
  _ExportOptionsFormState createState() => _ExportOptionsFormState();
}

class _ExportOptionsFormState extends State<ExportOptionsForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  DateTime _startDate = DateTime.now().subtract(Duration(days: 365));
  DateTime _endDate = DateTime.now();
  ExportFormat _format = ExportFormat.excel;
  bool _includeTransactions = true;
  bool _includeAccounts = true;
  bool _includeCategories = true;
  bool _includeTags = true;
  bool _includeBudgets = true;
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
          _buildDateRangeField(),
          SizedBox(height: 16.0),
          _buildFormatField(),
          SizedBox(height: 16.0),
          _buildDataSelectionField(),
          SizedBox(height: 16.0),
          _buildPasswordField(),
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _handleExport,
            child: Text('导出数据'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('日期范围', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => _selectDate(true),
                icon: Icon(Icons.calendar_today),
                label: Text(_formatDate(_startDate)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('至'),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _selectDate(false),
                icon: Icon(Icons.calendar_today),
                label: Text(_formatDate(_endDate)),
              ),
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
        Text('导出格式', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDataSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('导出数据', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        CheckboxListTile(
          title: Text('交易记录'),
          value: _includeTransactions,
          onChanged: (value) {
            setState(() => _includeTransactions = value ?? false);
          },
        ),
        CheckboxListTile(
          title: Text('账户信息'),
          value: _includeAccounts,
          onChanged: (value) {
            setState(() => _includeAccounts = value ?? false);
          },
        ),
        CheckboxListTile(
          title: Text('分类信息'),
          value: _includeCategories,
          onChanged: (value) {
            setState(() => _includeCategories = value ?? false);
          },
        ),
        CheckboxListTile(
          title: Text('标签信息'),
          value: _includeTags,
          onChanged: (value) {
            setState(() => _includeTags = value ?? false);
          },
        ),
        CheckboxListTile(
          title: Text('预算信息'),
          value: _includeBudgets,
          onChanged: (value) {
            setState(() => _includeBudgets = value ?? false);
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
            Text('加密保护', style: TextStyle(fontWeight: FontWeight.bold)),
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
              if (_usePassword && value!.length < 6) {
                return '密码长度不能少于6位';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = isStart ? DateTime(2000) : _startDate;
    final lastDate = isStart ? _endDate : DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _handleExport() {
    if (!_formKey.currentState!.validate()) return;

    if (!_includeTransactions &&
        !_includeAccounts &&
        !_includeCategories &&
        !_includeTags &&
        !_includeBudgets) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请至少选择一项要导出的数据')),
      );
      return;
    }

    final options = ExportOptions(
      startDate: _startDate,
      endDate: _endDate,
      format: _format,
      password: _usePassword ? _passwordController.text : null,
      includeTransactions: _includeTransactions,
      includeAccounts: _includeAccounts,
      includeCategories: _includeCategories,
      includeTags: _includeTags,
      includeBudgets: _includeBudgets,
    );

    widget.onExport(options);
  }
} 