import 'package:flutter/material.dart';

class QuickRecordScreen extends StatefulWidget {
  const QuickRecordScreen({super.key});

  @override
  State<QuickRecordScreen> createState() => _QuickRecordScreenState();
}

class _QuickRecordScreenState extends State<QuickRecordScreen> {
  bool _isExpense = true;
  String _amount = '0';
  String _selectedCategory = '餐饮';
  DateTime _selectedDate = DateTime.now();

  void _updateAmount(String value) {
    if (_amount == '0') {
      setState(() => _amount = value);
    } else {
      setState(() => _amount += value);
    }
  }

  void _deleteLastDigit() {
    if (_amount.length > 1) {
      setState(() => _amount = _amount.substring(0, _amount.length - 1));
    } else {
      setState(() => _amount = '0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记一笔'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 保存记录
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 类型切换
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeButton(true, '支出'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeButton(false, '收入'),
                ),
              ],
            ),
          ),
          // 金额显示
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            child: Text(
              '¥$_amount',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 分类选择
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryItem('餐饮', Icons.restaurant),
                _buildCategoryItem('交通', Icons.directions_car),
                _buildCategoryItem('购物', Icons.shopping_bag),
                _buildCategoryItem('娱乐', Icons.sports_esports),
                _buildCategoryItem('其他', Icons.more_horiz),
              ],
            ),
          ),
          const Spacer(),
          // 数字键盘
          Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                _buildKeyboardRow(['1', '2', '3']),
                _buildKeyboardRow(['4', '5', '6']),
                _buildKeyboardRow(['7', '8', '9']),
                _buildKeyboardRow(['.', '0', '⌫']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(bool isExpense, String label) {
    final isSelected = _isExpense == isExpense;
    return ElevatedButton(
      onPressed: () => setState(() => _isExpense = isExpense),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      children: keys.map((key) => _buildKeyboardKey(key)).toList(),
    );
  }

  Widget _buildKeyboardKey(String key) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextButton(
          onPressed: () {
            if (key == '⌫') {
              _deleteLastDigit();
            } else if (key == '.' && !_amount.contains('.')) {
              _updateAmount(key);
            } else if (key != '.') {
              _updateAmount(key);
            }
          },
          child: Text(
            key,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
} 