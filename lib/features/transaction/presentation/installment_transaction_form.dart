import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/installment_transaction.dart';
import '../application/installment_transaction_service.dart';

class InstallmentTransactionForm extends StatefulWidget {
  final InstallmentTransaction? transaction;
  final String accountId;

  const InstallmentTransactionForm({
    Key? key,
    this.transaction,
    required this.accountId,
  }) : super(key: key);

  @override
  State<InstallmentTransactionForm> createState() => _InstallmentTransactionFormState();
}

class _InstallmentTransactionFormState extends State<InstallmentTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _totalAmountController;
  late TextEditingController _installmentsController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  String? _categoryId;
  List<String> _tagIds = [];
  late double _installmentAmount;

  @override
  void initState() {
    super.initState();
    _totalAmountController = TextEditingController(
      text: widget.transaction?.totalAmount.toString() ?? '',
    );
    _installmentsController = TextEditingController(
      text: widget.transaction?.totalInstallments.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _startDate = widget.transaction?.startDate ?? DateTime.now();
    _categoryId = widget.transaction?.categoryId;
    _tagIds = widget.transaction?.tagIds ?? [];
    _installmentAmount = widget.transaction?.installmentAmount ?? 0;

    // 监听金额和期数的变化，实时计算每期金额
    _totalAmountController.addListener(_calculateInstallmentAmount);
    _installmentsController.addListener(_calculateInstallmentAmount);
  }

  void _calculateInstallmentAmount() {
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
    final installments = int.tryParse(_installmentsController.text) ?? 1;
    if (totalAmount > 0 && installments > 0) {
      setState(() {
        _installmentAmount = (totalAmount / installments).roundToDouble();
      });
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _installmentsController.dispose();
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
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final service = context.read<InstallmentTransactionService>();
      
      try {
        if (widget.transaction == null) {
          await service.createInstallmentTransaction(
            accountId: widget.accountId,
            totalAmount: double.parse(_totalAmountController.text),
            currency: 'CNY', // 默认使用人民币
            totalInstallments: int.parse(_installmentsController.text),
            startDate: _startDate,
            description: _descriptionController.text,
            categoryId: _categoryId,
            tagIds: _tagIds,
          );
        } else {
          // 分期付款创建后不允许修改金额和期数
          final updatedTransaction = widget.transaction!.copyWith(
            description: _descriptionController.text,
            categoryId: _categoryId,
            tagIds: _tagIds,
            startDate: _startDate,
          );
          await service.updateInstallmentTransaction(updatedTransaction);
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
    final isEditing = widget.transaction != null;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _totalAmountController,
            decoration: const InputDecoration(
              labelText: '总金额',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            enabled: !isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入总金额';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return '请输入有效的金额';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _installmentsController,
            decoration: const InputDecoration(
              labelText: '分期期数',
              prefixIcon: Icon(Icons.calendar_view_month),
            ),
            keyboardType: TextInputType.number,
            enabled: !isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入分期期数';
              }
              final count = int.tryParse(value);
              if (count == null || count <= 0) {
                return '请输入有效的期数';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (_installmentAmount > 0) ...[
            Text(
              '每期金额: $_installmentAmount CNY',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              '开始日期: ${_startDate.year}-${_startDate.month}-${_startDate.day}',
            ),
            onTap: () => _selectStartDate(context),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '备注',
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入备注';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(isEditing ? '保存' : '创建分期付款'),
            ),
          ),
        ],
      ),
    );
  }
} 