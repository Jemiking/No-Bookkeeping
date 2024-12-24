import 'package:flutter/material.dart';
import '../widgets/number_keyboard.dart';
import '../widgets/category_selector.dart';
import '../theme/theme_manager.dart';

class QuickRecordScreen extends StatefulWidget {
  const QuickRecordScreen({Key? key}) : super(key: key);

  @override
  State<QuickRecordScreen> createState() => _QuickRecordScreenState();
}

class _QuickRecordScreenState extends State<QuickRecordScreen> {
  String _amount = '0';
  bool _isExpense = true;
  String _selectedCategoryId = '';
  String _selectedCategoryName = '';
  String _note = '';

  void _onNumberPressed(String value) {
    setState(() {
      if (_amount == '0' && value != '.') {
        _amount = value;
      } else if (value == '.' && _amount.contains('.')) {
        return;
      } else if (_amount.contains('.') && _amount.split('.')[1].length >= 2) {
        return;
      } else {
        _amount += value;
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      _amount = '0';
    });
  }

  void _onTypeChanged(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      _selectedCategoryId = '';
      _selectedCategoryName = '';
    });
  }

  void _onCategorySelected(String id, String name) {
    setState(() {
      _selectedCategoryId = id;
      _selectedCategoryName = name;
    });
  }

  Future<void> _onSave() async {
    if (_amount == '0' || _selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入金额和选择分类')),
      );
      return;
    }

    try {
      // TODO: 实现保存记录的逻辑
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('记一笔'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 金额输入区域
          Container(
            padding: const EdgeInsets.all(24.0),
            color: theme.primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¥ ',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      _amount,
                      style: TextStyle(
                        fontSize: 48.0,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTypeButton(
                      label: '支出',
                      isSelected: _isExpense,
                      onTap: () => _onTypeChanged(true),
                    ),
                    const SizedBox(width: 16.0),
                    _buildTypeButton(
                      label: '收入',
                      isSelected: !_isExpense,
                      onTap: () => _onTypeChanged(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 分类选择区域
          Expanded(
            child: CategorySelector(
              isExpense: _isExpense,
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: _onCategorySelected,
            ),
          ),
          // 备注输入区域
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '添加备注',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: (value) => _note = value,
            ),
          ),
          // 数字键盘
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: NumberKeyboard(
                onNumberPressed: _onNumberPressed,
                onBackspacePressed: _onBackspacePressed,
                onClearPressed: _onClearPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: theme.primaryColor,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 