import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
      });
      if (_isBiometricAvailable) {
        // TODO: 从本地存储中读取生物识别启用状态
        setState(() {
          _isBiometricEnabled = false;
        });
      }
    } catch (e) {
      debugPrint('检查生物识别可用性时出错: $e');
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      try {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: '请验证生物识别以启用此功能',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        if (didAuthenticate) {
          setState(() {
            _isBiometricEnabled = true;
          });
          // TODO: 保存生物识别启用状态到本地存储
        }
      } catch (e) {
        debugPrint('生物识别认证失败: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('生物识别认证失败，请重试')),
        );
      }
    } else {
      setState(() {
        _isBiometricEnabled = false;
      });
      // TODO: 更新本地存储中的生物识别状态
    }
  }

  void _showChangePasswordDialog() {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('修改密码'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: '当前密码',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入当前密码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: '新密码',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入新密码';
                    }
                    if (value.length < 8) {
                      return '密码长度不能少于8位';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: '确认新密码',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请确认新密码';
                    }
                    if (value != _newPasswordController.text) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // TODO: 实现密码修改逻辑
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('密码修改成功')),
                  );
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  void _showSecurityLog() {
    // TODO: 实现查看安全日志的功能
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('安全日志'),
          content: const SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('最近30天的安全操作记录：'),
                SizedBox(height: 8),
                Text('• 2024-01-23 14:30 修改登录密码'),
                Text('• 2024-01-22 10:15 开启生物识别'),
                Text('• 2024-01-20 09:45 登录成功'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('安全中心'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.password_outlined),
                  title: const Text('登录密码'),
                  subtitle: const Text('定期修改密码可以提高账号安全性'),
                  trailing: TextButton(
                    onPressed: _showChangePasswordDialog,
                    child: const Text('修改'),
                  ),
                ),
                if (_isBiometricAvailable) ...[
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('生物识别'),
                    subtitle: const Text('使用指纹或面容快速登录'),
                    value: _isBiometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text('安全日志'),
                  subtitle: const Text('查看近期的安全相关操作记录'),
                  trailing: TextButton(
                    onPressed: _showSecurityLog,
                    child: const Text('查看'),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.devices_outlined),
                  title: const Text('登录设备管理'),
                  subtitle: const Text('查看和管理已登录的设备'),
                  trailing: TextButton(
                    onPressed: () {
                      // TODO: 实现设备管理功能
                    },
                    child: const Text('管理'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('隐私设置'),
                  subtitle: const Text('管理应用的隐私相关设置'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 实现隐私设置功能
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('数据备份'),
                  subtitle: const Text('设置自动备份和加密方式'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 实现数据备份设置功能
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 