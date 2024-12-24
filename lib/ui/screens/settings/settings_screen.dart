import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/account_service.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/tag_service.dart';
import '../../../core/services/budget_service.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  /// 构造函数
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AccountService _accountService = AccountService();
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final TagService _tagService = TagService();
  final BudgetService _budgetService = BudgetService();

  bool _isLoading = false;
  String? _error;

  // 设置项
  bool _enableBiometric = false;
  bool _enableAutoBackup = false;
  bool _enableNotification = false;
  String _currency = 'CNY';
  String _theme = 'system';
  String _language = 'zh_CN';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _enableBiometric = prefs.getBool('enable_biometric') ?? false;
        _enableAutoBackup = prefs.getBool('enable_auto_backup') ?? false;
        _enableNotification = prefs.getBool('enable_notification') ?? false;
        _currency = prefs.getString('currency') ?? 'CNY';
        _theme = prefs.getString('theme') ?? 'system';
        _language = prefs.getString('language') ?? 'zh_CN';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载设置失败：$e';
        _isLoading = false;
      });
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('enable_biometric', _enableBiometric);
      await prefs.setBool('enable_auto_backup', _enableAutoBackup);
      await prefs.setBool('enable_notification', _enableNotification);
      await prefs.setString('currency', _currency);
      await prefs.setString('theme', _theme);
      await prefs.setString('language', _language);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('设置已保存'),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '保存设置失败：$e';
        _isLoading = false;
      });
    }
  }

  /// 导出数据
  Future<void> _exportData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: 实现数据导出功能

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '导出数据失败：$e';
        _isLoading = false;
      });
    }
  }

  /// 导入数据
  Future<void> _importData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: 实现数据导入功能

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '导入数据失败：$e';
        _isLoading = false;
      });
    }
  }

  /// 清除数据
  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清除数据'),
          content: const Text('确定要清除所有数据吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                '清除',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: 实现数据清除功能

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据已清除'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = '清��数据失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _buildBody(),
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_isLoading) {
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
              onPressed: _loadSettings,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        _buildBasicSettingsSection(),
        const Divider(),
        _buildDataManagementSection(),
        const Divider(),
        _buildThemeSettingsSection(),
        const Divider(),
        _buildAboutSection(),
      ],
    );
  }

  /// 构建基本设置部分
  Widget _buildBasicSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '基本设置',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SwitchListTile(
          title: const Text('生物识别'),
          subtitle: const Text('使用指纹或面部识别解锁应用'),
          value: _enableBiometric,
          onChanged: (value) {
            setState(() {
              _enableBiometric = value;
            });
            _saveSettings();
          },
        ),
        SwitchListTile(
          title: const Text('自动备份'),
          subtitle: const Text('定期自动备份数据'),
          value: _enableAutoBackup,
          onChanged: (value) {
            setState(() {
              _enableAutoBackup = value;
            });
            _saveSettings();
          },
        ),
        SwitchListTile(
          title: const Text('通知提醒'),
          subtitle: const Text('开启预算和定期交易提醒'),
          value: _enableNotification,
          onChanged: (value) {
            setState(() {
              _enableNotification = value;
            });
            _saveSettings();
          },
        ),
        ListTile(
          title: const Text('默认货币'),
          subtitle: Text(_currency),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 显示货币选择对话框
          },
        ),
        ListTile(
          title: const Text('语言'),
          subtitle: Text(_language == 'zh_CN' ? '简体中文' : 'English'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 显示语言选择对话框
          },
        ),
      ],
    );
  }

  /// 构建数据管理部分
  Widget _buildDataManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '数据管理',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('导出数据'),
          subtitle: const Text('将数据导出到文件'),
          onTap: _exportData,
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('导入数据'),
          subtitle: const Text('从文件导入数据'),
          onTap: _importData,
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('清除数据'),
          subtitle: const Text('删除所有数据'),
          onTap: _clearData,
        ),
      ],
    );
  }

  /// 构建主题设置部分
  Widget _buildThemeSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '主题设置',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        RadioListTile<String>(
          title: const Text('跟随系统'),
          value: 'system',
          groupValue: _theme,
          onChanged: (value) {
            setState(() {
              _theme = value!;
            });
            _saveSettings();
          },
        ),
        RadioListTile<String>(
          title: const Text('浅色'),
          value: 'light',
          groupValue: _theme,
          onChanged: (value) {
            setState(() {
              _theme = value!;
            });
            _saveSettings();
          },
        ),
        RadioListTile<String>(
          title: const Text('深色'),
          value: 'dark',
          groupValue: _theme,
          onChanged: (value) {
            setState(() {
              _theme = value!;
            });
            _saveSettings();
          },
        ),
      ],
    );
  }

  /// 构建关于部分
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '关于',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('版本信息'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('用户协议'),
          onTap: () {
            // TODO: 显示用户协议
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('隐私政策'),
          onTap: () {
            // TODO: 显示隐私政策
          },
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('反馈建议'),
          onTap: () {
            // TODO: 显示反馈页面
          },
        ),
      ],
    );
  }
} 