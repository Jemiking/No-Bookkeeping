import 'package:flutter/material.dart';

/// 账户数据模型
class AccountSelectorData {
  final String id;
  final String name;
  final String type;
  final String currency;
  final double balance;
  final IconData? icon;
  final Color? color;

  const AccountSelectorData({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
    this.icon,
    this.color,
  });
}

/// 账户选择器组件
class AccountSelector extends StatefulWidget {
  /// 账户列表
  final List<AccountSelectorData> accounts;
  
  /// 选中的账户ID
  final String? selectedId;
  
  /// 账户选择回调
  final ValueChanged<AccountSelectorData>? onSelected;
  
  /// 是否支持多选
  final bool multiSelect;
  
  /// 多选时的选中列表
  final List<String>? selectedIds;
  
  /// 多选回调
  final ValueChanged<List<AccountSelectorData>>? onMultiSelected;
  
  /// 是否显示余额
  final bool showBalance;
  
  /// 是否显示搜索框
  final bool showSearch;
  
  /// 是否按类型分组
  final bool groupByType;

  const AccountSelector({
    super.key,
    required this.accounts,
    this.selectedId,
    this.onSelected,
    this.multiSelect = false,
    this.selectedIds,
    this.onMultiSelected,
    this.showBalance = true,
    this.showSearch = true,
    this.groupByType = true,
  });

  @override
  State<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends State<AccountSelector> {
  List<String> _selectedIds = [];
  String _searchQuery = '';
  Map<String, List<AccountSelectorData>> _groupedAccounts = {};

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.selectedIds ?? [];
    if (widget.selectedId != null) {
      _selectedIds = [widget.selectedId!];
    }
    _groupAccounts();
  }

  void _groupAccounts() {
    if (widget.groupByType) {
      _groupedAccounts = {};
      for (var account in widget.accounts) {
        if (!_groupedAccounts.containsKey(account.type)) {
          _groupedAccounts[account.type] = [];
        }
        if (_searchQuery.isEmpty ||
            account.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          _groupedAccounts[account.type]!.add(account);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        if (widget.showSearch) _buildSearchBar(theme),
        Expanded(
          child: widget.groupByType
              ? _buildGroupedList(theme)
              : _buildSimpleList(theme),
        ),
      ],
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索账户',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _groupAccounts();
          });
        },
      ),
    );
  }

  /// 构建分组列表
  Widget _buildGroupedList(ThemeData theme) {
    return ListView.builder(
      itemCount: _groupedAccounts.length,
      itemBuilder: (context, index) {
        final type = _groupedAccounts.keys.elementAt(index);
        final accounts = _groupedAccounts[type]!;
        
        if (accounts.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                type,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...accounts.map((account) => _buildAccountItem(account, theme)).toList(),
          ],
        );
      },
    );
  }

  /// 构建简单列表
  Widget _buildSimpleList(ThemeData theme) {
    final filteredAccounts = widget.accounts.where((account) {
      return _searchQuery.isEmpty ||
          account.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredAccounts.length,
      itemBuilder: (context, index) {
        return _buildAccountItem(filteredAccounts[index], theme);
      },
    );
  }

  /// 构建账户项
  Widget _buildAccountItem(AccountSelectorData account, ThemeData theme) {
    final isSelected = _selectedIds.contains(account.id);
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: account.color?.withOpacity(0.1) ?? theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(
          account.icon ?? Icons.account_balance_wallet,
          color: account.color ?? theme.colorScheme.primary,
        ),
      ),
      title: Text(account.name),
      subtitle: Text(account.type),
      trailing: widget.showBalance
          ? Text(
              '${account.currency} ${account.balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: account.balance >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      selected: isSelected,
      onTap: () => _handleSelection(account),
    );
  }

  /// 处理选择事件
  void _handleSelection(AccountSelectorData account) {
    if (widget.multiSelect) {
      setState(() {
        if (_selectedIds.contains(account.id)) {
          _selectedIds.remove(account.id);
        } else {
          _selectedIds.add(account.id);
        }
      });
      
      final selectedAccounts = widget.accounts
          .where((a) => _selectedIds.contains(a.id))
          .toList();
      
      widget.onMultiSelected?.call(selectedAccounts);
    } else {
      setState(() {
        _selectedIds = [account.id];
      });
      widget.onSelected?.call(account);
    }
  }

  /// 显示账户选择器对话框
  static Future<AccountSelectorData?> show({
    required BuildContext context,
    required List<AccountSelectorData> accounts,
    String? selectedId,
    bool multiSelect = false,
    List<String>? selectedIds,
    bool showBalance = true,
    bool showSearch = true,
    bool groupByType = true,
  }) {
    return showModalBottomSheet<AccountSelectorData>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选择账户',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AccountSelector(
                accounts: accounts,
                selectedId: selectedId,
                multiSelect: multiSelect,
                selectedIds: selectedIds,
                showBalance: showBalance,
                showSearch: showSearch,
                groupByType: groupByType,
                onSelected: (account) => Navigator.of(context).pop(account),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 