import 'package:flutter/material.dart';
import 'package:your_app_name/core/theme/app_theme.dart';
import 'package:your_app_name/core/utils/assets.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: '账本管理',
                  onTap: () {
                    // TODO: 实现账本管理功能
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.category,
                  title: '分类管理',
                  onTap: () {
                    // TODO: 实现分类管理功能
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance,
                  title: '账户管理',
                  onTap: () {
                    // TODO: 实现账户管理功能
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.backup,
                  title: '数据备份',
                  onTap: () {
                    // TODO: 实现数据备份功能
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.sync,
                  title: '数据同步',
                  onTap: () {
                    // TODO: 实现数据同步功能
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: '设置',
                  onTap: () {
                    // TODO: 实现设置功能
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: '帮助与反馈',
                  onTap: () {
                    // TODO: 实现帮助与反馈功能
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: '关于',
                  onTap: () {
                    // TODO: 实现关于页面
                  },
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return DrawerHeader(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.onPrimary,
            child: Image.asset(
              Assets.userAvatar,
              width: 56,
              height: 56,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '用户名',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'user@example.com',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showTrailing = true,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: showTrailing
          ? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '版本 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 实现退出登录功能
              },
              child: const Text('退出登录'),
            ),
          ],
        ),
      ),
    );
  }
} 