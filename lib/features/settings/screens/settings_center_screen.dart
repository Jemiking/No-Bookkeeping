import 'package:flutter/material.dart';

class SettingsCenterScreen extends StatefulWidget {
  const SettingsCenterScreen({super.key});

  @override
  State<SettingsCenterScreen> createState() => _SettingsCenterScreenState();
}

class _SettingsCenterScreenState extends State<SettingsCenterScreen> {
  // 通知设置
  bool _enableNotification = true;
  bool _enableBudgetAlert = true;
  bool _enableBillReminder = true;

  // 安全设置
  bool _enableBiometric = true;
  bool _enableAutoLock = true;

  // 主题设置
  String _selectedTheme = '跟随系统';
  final List<String> _themes = ['跟随系统', '浅色模式', '深色模式'];

  // 货币设置
  String _selectedCurrency = 'CNY';
  final List<String> _currencies = ['CNY', 'USD', 'EUR', 'GBP', 'JPY'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildUserInfoSection(),
          const Divider(),
          _buildNotificationSection(),
          const Divider(),
          _buildSecuritySection(),
          const Divider(),
          _buildThemeSection(),
          const Divider(),
          _buildGeneralSection(),
          const Divider(),
          _buildAboutSection(),
          const SizedBox(height: 32),
          _buildLogoutButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return ListTile(
      leading: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/avatar_placeholder.png'),
      ),
      title: const Text('用户名'),
      subtitle: const Text('user@example.com'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: 导航到个人信息页面
      },
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '通知设置',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('启用通知'),
          subtitle: const Text('接收应用的推送通知'),
          value: _enableNotification,
          onChanged: (value) {
            setState(() => _enableNotification = value);
          },
        ),
        SwitchListTile(
          title: const Text('预算提醒'),
          subtitle: const Text('当预算使用超过阈值时提醒'),
          value: _enableBudgetAlert && _enableNotification,
          onChanged: _enableNotification
              ? (value) {
                  setState(() => _enableBudgetAlert = value);
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('账单提醒'),
          subtitle: const Text('定期账单到期提醒'),
          value: _enableBillReminder && _enableNotification,
          onChanged: _enableNotification
              ? (value) {
                  setState(() => _enableBillReminder = value);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '安全设置',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          title: const Text('修改密码'),
          leading: const Icon(Icons.lock_outline),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 导航到修改密码页面
          },
        ),
        SwitchListTile(
          title: const Text('生物识别'),
          subtitle: const Text('使用指纹或面部识别解锁应用'),
          secondary: const Icon(Icons.fingerprint),
          value: _enableBiometric,
          onChanged: (value) {
            setState(() => _enableBiometric = value);
          },
        ),
        SwitchListTile(
          title: const Text('自动锁定'),
          subtitle: const Text('离开应用时自动锁定'),
          secondary: const Icon(Icons.screen_lock_portrait),
          value: _enableAutoLock,
          onChanged: (value) {
            setState(() => _enableAutoLock = value);
          },
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '主题设置',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          title: const Text('主题模式'),
          subtitle: Text(_selectedTheme),
          leading: const Icon(Icons.palette_outlined),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: const Text('选择主题模式'),
                  children: _themes.map((theme) {
                    return SimpleDialogOption(
                      onPressed: () {
                        setState(() => _selectedTheme = theme);
                        Navigator.pop(context);
                      },
                      child: Text(theme),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
        ListTile(
          title: const Text('自定义主题'),
          subtitle: const Text('个性化应用外观'),
          leading: const Icon(Icons.color_lens_outlined),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 导航到自定义主题页面
          },
        ),
      ],
    );
  }

  Widget _buildGeneralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '通用设置',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          title: const Text('货币单位'),
          subtitle: Text(_selectedCurrency),
          leading: const Icon(Icons.attach_money),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: const Text('选择货币单位'),
                  children: _currencies.map((currency) {
                    return SimpleDialogOption(
                      onPressed: () {
                        setState(() => _selectedCurrency = currency);
                        Navigator.pop(context);
                      },
                      child: Text(currency),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
        ListTile(
          title: const Text('数据备份'),
          subtitle: const Text('备份和恢复数据'),
          leading: const Icon(Icons.backup_outlined),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 导航到数据备份页面
          },
        ),
        ListTile(
          title: const Text('清除缓存'),
          subtitle: const Text('清除应用缓存数据'),
          leading: const Icon(Icons.cleaning_services_outlined),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('清除缓存'),
                  content: const Text('确定要清除应用缓存数据吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: 实现清除缓存逻辑
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('缓存已清除')),
                        );
                      },
                      child: const Text('确定'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '关于',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          title: const Text('检查更新'),
          subtitle: const Text('当前版本：1.0.0'),
          leading: const Icon(Icons.system_update_outlined),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 实现检查更新逻辑
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已是最新版本')),
            );
          },
        ),
        ListTile(
          title: const Text('用户协议'),
          leading: const Icon(Icons.description_outlined),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 导航到用户协议页面
          },
        ),
        ListTile(
          title: const Text('隐私政策'),
          leading: const Icon(Icons.privacy_tip_outlined),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 导航到隐私政策页面
          },
        ),
        ListTile(
          title: const Text('关于我们'),
          leading: const Icon(Icons.info_outline),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 导航到关于我们页面
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('退出登录'),
                content: const Text('确定要退出登录吗？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 实现退出登录逻辑
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '确定',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('退出登录'),
      ),
    );
  }
} 