import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isGettingCode = false;
  int _countdown = 60;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _getVerificationCode() {
    // TODO: 实现获取验证码逻辑
    setState(() {
      _isGettingCode = true;
    });
    // 模拟倒计时
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _countdown = 59;
      });
    });
  }

  void _login() {
    // TODO: 实现登录逻辑
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 关闭按钮
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 40),
              // 标题
              const Text(
                '登录',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // 手机号输入框
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '手机号码',
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // 验证码输入框
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '验证码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: TextButton(
                    onPressed: _isGettingCode ? null : _getVerificationCode,
                    child: Text(
                      _isGettingCode ? '${_countdown}s' : '获取验证码',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 登录按钮
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  '登录 / 注册',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const Spacer(),
              // 其他登录方式
              const Center(
                child: Text(
                  '- 其他登录方式 -',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              // 第三方登录按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialLoginButton(Icons.wechat, '微信'),
                  const SizedBox(width: 40),
                  _buildSocialLoginButton(Icons.phone_android, 'QQ'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            // TODO: 实现第三方登录
          },
          iconSize: 32,
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
} 