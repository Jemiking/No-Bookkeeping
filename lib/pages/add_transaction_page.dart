import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calendar/models/calendar_state.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isExpense = true;
  DateTime? _selectedDate;
  
  // 预定义的类别
  final List<String> _expenseCategories = [
    '餐饮', '交通', '购物', '娱乐', '居住', '医疗',
    '教育', '通讯', '服装', '其他'
  ];
  
  final List<String> _incomeCategories = [
    '工资', '奖金', '投资', '兼职', '其他'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里初始化选中日期
    _selectedDate ??= context.read<CalendarState>().selectedDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('zh'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final categories = _isExpense ? _expenseCategories : _incomeCategories;
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '选择类别',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        _categoryController.text = categories[index];
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B5B95).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: const TextStyle(
                              color: Color(0xFF6B5B95),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final amount = double.parse(_amountController.text);
        final finalAmount = _isExpense ? -amount : amount;
        
        await context.read<CalendarState>().addTransaction(
          finalAmount,
          _categoryController.text,
          note: _noteController.text,
          date: _selectedDate,
        );
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('添加交易失败，请重试')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 确保 _selectedDate 已初始化
    _selectedDate ??= context.read<CalendarState>().selectedDate;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加交易'),
        backgroundColor: const Color(0xFF6B5B95),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 收支类型选择
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('支出'),
                    value: true,
                    groupValue: _isExpense,
                    onChanged: (value) {
                      setState(() {
                        _isExpense = value!;
                        _categoryController.clear(); // 切换类型时清空已选类别
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('收入'),
                    value: false,
                    groupValue: _isExpense,
                    onChanged: (value) {
                      setState(() {
                        _isExpense = value!;
                        _categoryController.clear(); // 切换类型时清空已选类别
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 日期选择
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '日期',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate?.year}年${_selectedDate?.month}月${_selectedDate?.day}日',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 金额输入
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '金额',
                prefixText: '￥',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入金额';
                }
                if (double.tryParse(value) == null) {
                  return '请输入有效的金额';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 类别选择
            InkWell(
              onTap: _showCategoryPicker,
              child: IgnorePointer(
                child: TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: '类别',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请选择类别';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 备注输入
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '备注',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            // 提交按钮
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5B95),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
} 