import 'package:flutter/material.dart';
import '../../../core/database/models/account.dart';
import '../../../core/services/account_service.dart';

/// 账户编辑页面
class AccountEditScreen extends StatefulWidget {
  /// 账户ID（为null时表示创建新账户）
  final int? accountId;

  /// 构造函数
  const AccountEditScreen({
    Key? key,
    this.accountId,
  }) : super(key: key);

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final AccountService _accountService = AccountService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _selectedType = AccountType.cash;
  String? _selectedIcon;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.accountId != null) {
      _loadAccount();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// 加载账户信息
  Future<void> _loadAccount() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final account = await _accountService.getAccount(widget.accountId!);
      if (account == null) {
        setState(() {
          _error = '账户不存在';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _nameController.text = account.name;
        _noteController.text = account.note ?? '';
        _balanceController.text = account.balance.toString();
        _selectedType = account.type;
        _selectedIcon = account.icon;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载账户失败：$e';
        _isLoading = false;
      });
    }
  }

  /// 保存账户
  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final account = Account(
        id: widget.accountId,
        name: _nameController.text,
        type: _selectedType,
        balance: double.parse(_balanceController.text),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        icon: _selectedIcon,
      );

      if (widget.accountId == null) {
        await _accountService.createAccount(account);
      } else {
        await _accountService.updateAccount(account);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = '保存账户失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accountId == null ? '创建账户' : '编辑账户'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAccount,
            child: const Text('保存'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_isLoading && widget.accountId != null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: widget.accountId == null ? null : _loadAccount,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIconSelector(),
            const SizedBox(height: 16.0),
            _buildNameField(),
            const SizedBox(height: 16.0),
            _buildTypeSelector(),
            const SizedBox(height: 16.0),
            _buildBalanceField(),
            const SizedBox(height: 16.0),
            _buildNoteField(),
          ],
        ),
      ),
    );
  }

  /// 构建图标选择器
  Widget _buildIconSelector() {
    final icons = [
      Icons.account_balance_wallet,
      Icons.credit_card,
      Icons.savings,
      Icons.account_balance,
      Icons.attach_money,
      Icons.payment,
      Icons.currency_exchange,
      Icons.monetization_on,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '图标',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: icons.map((icon) {
            final iconCode = icon.codePoint.toString();
            final isSelected = _selectedIcon == iconCode;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedIcon = iconCode;
                });
              },
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建名称输入框
  Widget _buildNameField() {
    return TextFormField(
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
    );
  }

  /// 构建类型选择器
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '账户类型',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: AccountType.values.map((type) {
            return ChoiceChip(
              label: Text(type.toString()),
              selected: _selectedType == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建余额���入框
  Widget _buildBalanceField() {
    return TextFormField(
      controller: _balanceController,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: const InputDecoration(
        labelText: '初始余额',
        hintText: '请输入初始余额',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入初始余额';
        }
        if (double.tryParse(value) == null) {
          return '请输入有效的金额';
        }
        return null;
      },
    );
  }

  /// 构建备注输入框
  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: '备注',
        hintText: '请输入备注（选填）',
      ),
    );
  }
} 