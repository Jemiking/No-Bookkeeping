import 'package:flutter/material.dart';
import '../domain/account.dart';
import '../domain/account_group.dart';
import '../domain/account_group_repository.dart';
import '../domain/account_repository.dart';
import '../domain/balance_calculator.dart';
import 'account_group_form.dart';
import 'account_group_list.dart';

class AccountGroupPage extends StatefulWidget {
  final AccountRepository accountRepository;
  final AccountGroupRepository accountGroupRepository;
  final BalanceCalculator balanceCalculator;

  const AccountGroupPage({
    Key? key,
    required this.accountRepository,
    required this.accountGroupRepository,
    required this.balanceCalculator,
  }) : super(key: key);

  @override
  State<AccountGroupPage> createState() => _AccountGroupPageState();
}

class _AccountGroupPageState extends State<AccountGroupPage> {
  List<AccountGroup> _groups = [];
  List<Account> _accounts = [];
  Map<String, Account> _accountMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accounts = await widget.accountRepository.getAccounts();
      final groups = await widget.accountGroupRepository.getAccountGroups();
      
      setState(() {
        _accounts = accounts;
        _accountMap = {for (var a in accounts) a.id: a};
        _groups = groups;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载数据失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showGroupForm([AccountGroup? group]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                group == null ? '创建账户组' : '编辑账户组',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AccountGroupForm(
                group: group,
                availableAccounts: _accounts,
                onSubmit: (group) async {
                  try {
                    if (group.id.isEmpty) {
                      await widget.accountGroupRepository.createAccountGroup(group);
                    } else {
                      await widget.accountGroupRepository.updateAccountGroup(group);
                    }
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存成功')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('保存失败: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteGroup(String id) async {
    try {
      await widget.accountGroupRepository.deleteAccountGroup(id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户组管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showGroupForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('还没有账户组'),
                      TextButton(
                        onPressed: () => _showGroupForm(),
                        child: const Text('创建账户组'),
                      ),
                    ],
                  ),
                )
              : AccountGroupList(
                  groups: _groups,
                  accountMap: _accountMap,
                  onEdit: _showGroupForm,
                  onDelete: _deleteGroup,
                  balanceCalculator: widget.balanceCalculator,
                ),
    );
  }
} 