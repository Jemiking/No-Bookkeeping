import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // 验证标题
    expect(find.text('登录'), findsOneWidget);

    // 验证输入框
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('手机号码'), findsOneWidget);
    expect(find.text('验证码'), findsOneWidget);

    // 验证按钮
    expect(find.text('获取验证码'), findsOneWidget);
    expect(find.text('登录 / 注册'), findsOneWidget);

    // 验证其他登录方式
    expect(find.text('- 其他登录方式 -'), findsOneWidget);
    expect(find.text('微信'), findsOneWidget);
    expect(find.text('QQ'), findsOneWidget);

    // 测试获取验证码按钮点击
    await tester.tap(find.text('获取验证码'));
    await tester.pump();
    expect(find.text('60s'), findsOneWidget);
  });
} 