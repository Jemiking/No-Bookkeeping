import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/transaction.dart';
import '../application/transaction_service.dart';
import '../../account/domain/account.dart';
import '../../account/application/account_service.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final String accountId;

  const TransactionForm({
    Key? key,
    this.transaction,
    required this.accountId,
  }) : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _date;
  String? _categoryId;
  List<String> _tagIds = [];
  String? _toAccountId;
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? TransactionType.income;
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _date = widget.transaction?.date ?? DateTime.now();
    _categoryId = widget.transaction?.categoryId;
    _tagIds = widget.transaction?.tagIds ?? [];
    _toAccountId = widget.transaction?.toAccountId;
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accountService = context.read<AccountService>();
    final accounts = await accountService.getAllAccounts();
    setState(() {
      _accounts = accounts.where((account) => account.id != widget.accountId).toList();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final service = context.read<TransactionService>();
      
      try {
        if (widget.transaction == null) {
          await service.createTransaction(
            accountId: widget.accountId,
            toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
            type: _type,
            amount: double.parse(_amountController.text),
            currency: 'CNY', // 默认使用人民币
            categoryId: _categoryId,
            tagIds: _tagIds,
            date: _date,
            description: _descriptionController.text,
          );
        } else {
          final updatedTransaction = widget.transaction!.copyWith(
            type: _type,
            toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
            amount: double.parse(_amountController.text),
            categoryId: _categoryId,
            tagIds: _tagIds,
            date: _date,
            description: _descriptionController.text,
          );
          await service.updateTransaction(updatedTransaction);
        }
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存失败: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(
                value: TransactionType.income,
                label: Text('收入'),
              ),
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('支出'),
              ),
              ButtonSegment(
                value: TransactionType.transfer,
                label: Text('转账'),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (Set<TransactionType> newSelection) {
              setState(() {
                _type = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_type == TransactionType.transfer) ...[
            // 转出账户（当前账户）
            Text('从账户: ${widget.accountId}'),
            const SizedBox(height: 16),
            // 转入账户选择
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '转入账户',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              value: _toAccountId,
              items: _accounts.map((account) {
                return DropdownMenuItem<String>(
                  value: account.id,
                  child: Text(account.name),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _toAccountId = value;
                });
              },
              validator: (value) {
                if (_type == TransactionType.transfer && value == null) {
                  return '请选择转入账户';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: '金额',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
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
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              '日期: ${_date.year}-${_date.month}-${_date.day}',
            ),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '备注',
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(widget.transaction == null ? '添加' : '保存'),
            ),
          ),
        ],
      ),
    );
  }
} 