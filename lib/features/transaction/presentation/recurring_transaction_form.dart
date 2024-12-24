import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/recurring_transaction.dart';
import '../domain/transaction.dart';
import '../application/recurring_transaction_service.dart';
import '../../account/domain/account.dart';
import '../../account/application/account_service.dart';

class RecurringTransactionForm extends StatefulWidget {
  final RecurringTransaction? transaction;
  final String accountId;

  const RecurringTransactionForm({
    Key? key,
    this.transaction,
    required this.accountId,
  }) : super(key: key);

  @override
  State<RecurringTransactionForm> createState() => _RecurringTransactionFormState();
}

class _RecurringTransactionFormState extends State<RecurringTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  DateTime? _endDate;
  late RecurringPeriod _period;
  String? _categoryId;
  List<String> _tagIds = [];
  String? _toAccountId;
  List<Account> _accounts = [];
  int? _repeatCount;

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
    _startDate = widget.transaction?.startDate ?? DateTime.now();
    _endDate = widget.transaction?.endDate;
    _period = widget.transaction?.period ?? RecurringPeriod.monthly;
    _categoryId = widget.transaction?.categoryId;
    _tagIds = widget.transaction?.tagIds ?? [];
    _toAccountId = widget.transaction?.toAccountId;
    _repeatCount = widget.transaction?.repeatCount;
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final service = context.read<RecurringTransactionService>();
      
      try {
        if (widget.transaction == null) {
          await service.createRecurringTransaction(
            accountId: widget.accountId,
            toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
            type: _type,
            amount: double.parse(_amountController.text),
            currency: 'CNY', // 默认使用人民币
            categoryId: _categoryId,
            tagIds: _tagIds,
            description: _descriptionController.text,
            period: _period,
            startDate: _startDate,
            endDate: _endDate,
            repeatCount: _repeatCount,
          );
        } else {
          final updatedTransaction = widget.transaction!.copyWith(
            type: _type,
            toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
            amount: double.parse(_amountController.text),
            categoryId: _categoryId,
            tagIds: _tagIds,
            description: _descriptionController.text,
            period: _period,
            startDate: _startDate,
            endDate: _endDate,
            repeatCount: _repeatCount,
          );
          await service.updateRecurringTransaction(updatedTransaction);
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
            Text('从账户: ${widget.accountId}'),
            const SizedBox(height: 16),
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
          DropdownButtonFormField<RecurringPeriod>(
            decoration: const InputDecoration(
              labelText: '重复周期',
              prefixIcon: Icon(Icons.repeat),
            ),
            value: _period,
            items: RecurringPeriod.values.map((period) {
              return DropdownMenuItem<RecurringPeriod>(
                value: period,
                child: Text({
                  RecurringPeriod.daily: '每天',
                  RecurringPeriod.weekly: '每周',
                  RecurringPeriod.monthly: '每月',
                  RecurringPeriod.yearly: '每年',
                }[period]!),
              );
            }).toList(),
            onChanged: (RecurringPeriod? value) {
              if (value != null) {
                setState(() {
                  _period = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              '开始日期: ${_startDate.year}-${_startDate.month}-${_startDate.day}',
            ),
            onTap: () => _selectStartDate(context),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.event_busy),
            title: _endDate == null
                ? const Text('结束日期: 永不')
                : Text('结束日期: ${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'),
            trailing: _endDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _endDate = null;
                      });
                    },
                  )
                : null,
            onTap: () => _selectEndDate(context),
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