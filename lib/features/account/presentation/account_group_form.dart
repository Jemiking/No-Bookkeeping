import 'package:flutter/material.dart';
import '../domain/account.dart';
import '../domain/account_group.dart';

class AccountGroupForm extends StatefulWidget {
  final AccountGroup? group;
  final List<Account> availableAccounts;
  final Function(AccountGroup) onSubmit;

  const AccountGroupForm({
    Key? key,
    this.group,
    required this.availableAccounts,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AccountGroupForm> createState() => _AccountGroupFormState();
}

class _AccountGroupFormState extends State<AccountGroupForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<String> _selectedAccountIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.group?.description ?? '',
    );
    _selectedAccountIds = List.from(widget.group?.accountIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final group = AccountGroup(
        id: widget.group?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        accountIds: _selectedAccountIds,
        createdAt: widget.group?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSubmit(group);
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
              labelText: '组名称',
              hintText: '请输入账户组名称',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入组名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '描述',
              hintText: '请输入账户组描述(可选)',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const Text('选择账户'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.availableAccounts.length,
              itemBuilder: (context, index) {
                final account = widget.availableAccounts[index];
                return CheckboxListTile(
                  title: Text(account.name),
                  subtitle: Text(
                    '${_getAccountTypeText(account.type)} • ${account.currency}',
                  ),
                  value: _selectedAccountIds.contains(account.id),
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedAccountIds.add(account.id);
                      } else {
                        _selectedAccountIds.remove(account.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.group == null ? '创建账户组' : '更新账户组'),
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