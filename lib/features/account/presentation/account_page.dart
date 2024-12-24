import 'package:flutter/material.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';
import '../domain/currency_converter.dart';
import '../domain/balance_calculator.dart';
import '../domain/account_import_export.dart';
import 'account_form.dart';
import 'account_list.dart';
import 'account_group_page.dart';
import 'account_import_export_dialog.dart';

class AccountPage extends StatefulWidget {
  final AccountRepository accountRepository;
  final AccountGroupRepository accountGroupRepository;
  final CurrencyConverter currencyConverter;
  final BalanceCalculator balanceCalculator;
  final AccountImportExport accountImportExport;

  const AccountPage({
    Key? key,
    required this.accountRepository,
    required this.accountGroupRepository,
    required this.currencyConverter,
    required this.balanceCalculator,
    required this.accountImportExport,
  }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<Account> _accounts = [];
  bool _isLoading = true;
  String _selectedCurrency = 'CNY';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accounts = await widget.accountRepository.getAccounts();
      setState(() {
        _accounts = accounts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载账户失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAccountForm([Account? account]) {
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
                account == null ? '创建新账户' : '编辑账户',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AccountForm(
                account: account,
                onSubmit: (account) async {
                  try {
                    if (account.id.isEmpty) {
                      await widget.accountRepository.createAccount(account);
                    } else {
                      await widget.accountRepository.updateAccount(account);
                    }
                    Navigator.pop(context);
                    _loadAccounts();
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

  Future<void> _deleteAccount(String id) async {
    try {
      await widget.accountRepository.deleteAccount(id);
      _loadAccounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  Future<void> _archiveAccount(String id) async {
    try {
      await widget.accountRepository.archiveAccount(id);
      _loadAccounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('归档成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('归档失败: $e')),
      );
    }
  }

  void _showImportExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AccountImportExportDialog(
        accounts: _accounts,
        importExport: widget.accountImportExport,
        onImport: (accounts) async {
          for (final account in accounts) {
            await widget.accountRepository.createAccount(account);
          }
          _loadAccounts();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: _showImportExportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.group_work),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountGroupPage(
                    accountRepository: widget.accountRepository,
                    accountGroupRepository: widget.accountGroupRepository,
                    balanceCalculator: widget.balanceCalculator,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAccountForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<double>(
              stream: widget.balanceCalculator.watchTotalBalance(_selectedCurrency),
              builder: (context, snapshot) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '总资产',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.data?.toStringAsFixed(2) ?? '0.00'} $_selectedCurrency',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _accounts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('还没有账户'),
                            TextButton(
                              onPressed: () => _showAccountForm(),
                              child: const Text('创建账户'),
                            ),
                          ],
                        ),
                      )
                    : AccountList(
                        accounts: _accounts,
                        onEdit: _showAccountForm,
                        onDelete: _deleteAccount,
                        onArchive: _archiveAccount,
                        currencyConverter: widget.currencyConverter,
                        balanceCalculator: widget.balanceCalculator,
                      ),
          ),
        ],
      ),
    );
  }
} 