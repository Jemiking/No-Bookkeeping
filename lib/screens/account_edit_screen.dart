import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';
import '../services/account_service.dart';

class AccountEditScreen extends StatefulWidget {
  final Account? account;

  const AccountEditScreen({Key? key, this.account}) : super(key: key);

  @override
  _AccountEditScreenState createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedType = '现金账户';
  String _selectedIcon = 'assets/icons/cash.png';

  final List<String> _accountTypes = ['现金账户', '储蓄卡', '信用卡', '投资账户', '其他'];
  final List<String> _accountIcons = [
    'assets/icons/cash.png',
    'assets/icons/debit_card.png',
    'assets/icons/credit_card.png',
    'assets/icons/investment.png',
    'assets/icons/other.png',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _balanceController.text = widget.account!.balance.toString();
      _noteController.text = widget.account!.note ?? '';
      _selectedType = widget.account!.type;
      _selectedIcon = widget.account!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final account = Account(
        id: widget.account?.id,
        name: _nameController.text,
        type: _selectedType,
        icon: _selectedIcon,
        balance: double.parse(_balanceController.text),
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      try {
        final accountService = AccountService();
        if (widget.account == null) {
          await accountService.createAccount(account);
        } else {
          await accountService.updateAccount(account);
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (widget.account == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个账户吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final accountService = AccountService();
        await accountService.deleteAccount(widget.account!.id!);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败：${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? '新建账户' : '编辑账户'),
        actions: [
          if (widget.account != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteAccount,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CustomTextField(
              controller: _nameController,
              label: '账户名称',
              validator: Validators.required,
              maxLength: 20,
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: '账户类型',
                border: OutlineInputBorder(),
              ),
              items: _accountTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _selectedIcon = _accountIcons[_accountTypes.indexOf(value)];
                });
              },
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _balanceController,
              label: '账户余额',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.amount,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _noteController,
              label: '备注',
              maxLines: 3,
              maxLength: 100,
            ),
            const SizedBox(height: 24.0),
            CustomButton(
              onPressed: _saveAccount,
              text: '保存',
            ),
          ],
        ),
      ),
    );
  }
} 