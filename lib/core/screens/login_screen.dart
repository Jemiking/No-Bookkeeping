import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme_manager.dart';
import '../user/user_manager.dart';
import '../widgets/number_keyboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isGettingCode = false;
  int _countdown = 60;
  bool _isPhoneValid = false;
  bool _isCodeValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _validatePhone(String value) {
    setState(() {
      _isPhoneValid = value.length == 11 && RegExp(r'^1[3-9]\d{9}$').hasMatch(value);
    });
  }

  void _validateCode(String value) {
    setState(() {
      _isCodeValid = value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value);
    });
  }

  Future<void> _getVerificationCode() async {
    if (!_isPhoneValid || _isGettingCode) return;

    setState(() {
      _isGettingCode = true;
      _countdown = 60;
    });

    // TODO: 实现获取验证码的逻辑

    // 倒计时
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      
      setState(() {
        _countdown--;
      });
      
      if (_countdown <= 0) {
        setState(() {
          _isGettingCode = false;
        });
        return false;
      }
      return true;
    });
  }

  Future<void> _login() async {
    if (!_isPhoneValid || !_isCodeValid) return;

    try {
      // TODO: 实现登录逻辑
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40.0),
              Text(
                '欢迎使用',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '请登录您的账号',
                style: TextStyle(
                  fontSize: 16.0,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 40.0),
              // 手机号输入
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  labelText: '手机号',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  counterText: '',
                ),
                onChanged: _validatePhone,
              ),
              const SizedBox(height: 20.0),
              // 验证码输入
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: '验证码',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        counterText: '',
                      ),
                      onChanged: _validateCode,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  SizedBox(
                    width: 120.0,
                    child: ElevatedButton(
                      onPressed: _isPhoneValid && !_isGettingCode
                          ? _getVerificationCode
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        _isGettingCode ? '${_countdown}s' : '获取验证码',
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // 登录按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPhoneValid && _isCodeValid ? _login : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    '登录',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // 其他登录方式
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '其他登录方式',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLoginMethodButton(
                    icon: Icons.fingerprint,
                    label: '指纹登录',
                    onTap: () {
                      // TODO: 实现指纹登录
                    },
                  ),
                  _buildLoginMethodButton(
                    icon: Icons.face,
                    label: '面容登录',
                    onTap: () {
                      // TODO: 实现面容登录
                    },
                  ),
                  _buildLoginMethodButton(
                    icon: Icons.qr_code,
                    label: '扫码登录',
                    onTap: () {
                      // TODO: 实现扫码登录
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginMethodButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32.0,
            color: theme.primaryColor,
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
} 