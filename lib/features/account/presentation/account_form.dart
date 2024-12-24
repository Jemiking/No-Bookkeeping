import 'package:flutter/material.dart';
import '../domain/account.dart';

class AccountForm extends StatefulWidget {
  final Account? account;
  final Function(Account) onSubmit;

  const AccountForm({
    Key? key,
    this.account,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _currencyController;
  late TextEditingController _balanceController;
  late TextEditingController _descriptionController;
  late AccountType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _currencyController = TextEditingController(text: widget.account?.currency ?? 'CNY');
    _balanceController = TextEditingController(text: widget.account?.balance.toString() ?? '0.0');
    _descriptionController = TextEditingController(text: widget.account?.description ?? '');
    _selectedType = widget.account?.type ?? AccountType.cash;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final account = Account(
        id: widget.account?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        currency: _currencyController.text,
        balance: double.parse(_balanceController.text),
        description: _descriptionController.text,
        status: widget.account?.status ?? AccountStatus.active,
        createdAt: widget.account?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSubmit(account);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '账户名称',
              hintText: '请输入账户名称',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入账户名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AccountType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: '账户类型',
            ),
            items: AccountType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getAccountTypeText(type)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _currencyController,
            decoration: const InputDecoration(
              labelText: '币种',
              hintText: '请输入币种代码(如: CNY)',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入币种';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _balanceController,
            decoration: const InputDecoration(
              labelText: '初始余额',
              hintText: '请输入初始余额',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入初始余额';
              }
              if (double.tryParse(value) == null) {
                return '请输入有效的数字';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '描述',
              hintText: '请输入账户描述(可选)',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.account == null ? '创建账户' : '更新账户'),
            ),
          ),
        ],
      ),
    );
  }

  String _getAccountTypeText(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '现金';
      case AccountType.bankCard:
        return '银行卡';
      case AccountType.creditCard:
        return '信用卡';
      case AccountType.alipay:
        return '支付宝';
      case AccountType.wechat:
        return '微信';
      case AccountType.other:
        return '其他';
    }
  }
} 