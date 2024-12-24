import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/screens/login_screen.dart';

void main() {
  late Widget testWidget;

  setUp(() {
    testWidget = const MaterialApp(
      home: LoginScreen(),
      routes: {
        '/home': (context) => Scaffold(
              body: Center(child: Text('Home Screen')),
            ),
      },
    );
  });

  testWidgets('Login screen shows correct initial layout', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证标题和提示文本
    expect(find.text('欢迎使用'), findsOneWidget);
    expect(find.text('请登录您的账号'), findsOneWidget);

    // 验证输入框
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('验证码'), findsOneWidget);

    // 验证按钮
    expect(find.text('获取验证码'), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);

    // 验证其他登录方式
    expect(find.text('其他登录方式'), findsOneWidget);
    expect(find.text('指纹登录'), findsOneWidget);
    expect(find.text('面容登录'), findsOneWidget);
    expect(find.text('扫码登录'), findsOneWidget);
  });

  testWidgets('Phone number validation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 获取手机号输入框
    final phoneField = find.widgetWithText(TextField, '手机号');
    
    // 输入无效手机号
    await tester.enterText(phoneField, '123');
    await tester.pump();
    
    // 验证码按钮应该禁用
    final getCodeButton = find.widgetWithText(ElevatedButton, '获取验证码');
    expect(tester.widget<ElevatedButton>(getCodeButton).enabled, false);

    // 输入有效手机号
    await tester.enterText(phoneField, '13800138000');
    await tester.pump();
    
    // 验证码按钮应该启用
    expect(tester.widget<ElevatedButton>(getCodeButton).enabled, true);
  });

  testWidgets('Verification code validation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 获取验证码输入框
    final codeField = find.widgetWithText(TextField, '验证码');
    
    // 输入无效验证码
    await tester.enterText(codeField, '123');
    await tester.pump();
    
    // 登录按钮应该禁用
    final loginButton = find.widgetWithText(ElevatedButton, '登录');
    expect(tester.widget<ElevatedButton>(loginButton).enabled, false);

    // 输入有效验证码
    await tester.enterText(codeField, '123456');
    await tester.pump();
    
    // 输入有效手机号
    final phoneField = find.widgetWithText(TextField, '手机号');
    await tester.enterText(phoneField, '13800138000');
    await tester.pump();
    
    // 登录按钮应该启用
    expect(tester.widget<ElevatedButton>(loginButton).enabled, true);
  });

  testWidgets('Get verification code button shows countdown', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 输入有效手机号
    final phoneField = find.widgetWithText(TextField, '手机号');
    await tester.enterText(phoneField, '13800138000');
    await tester.pump();

    // 点击获取验证码按钮
    final getCodeButton = find.widgetWithText(ElevatedButton, '获取验证码');
    await tester.tap(getCodeButton);
    await tester.pump();

    // 验证倒计时显示
    expect(find.text('60s'), findsOneWidget);
    
    // 按钮应该禁用
    expect(tester.widget<ElevatedButton>(getCodeButton).enabled, false);
  });

  testWidgets('Login button navigates to home screen', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 输入有效手机号
    final phoneField = find.widgetWithText(TextField, '手机号');
    await tester.enterText(phoneField, '13800138000');

    // 输入有效验证码
    final codeField = find.widgetWithText(TextField, '验证码');
    await tester.enterText(codeField, '123456');
    await tester.pump();

    // 点击登录按钮
    final loginButton = find.widgetWithText(ElevatedButton, '登录');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 验证导航到主页
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('Other login methods are clickable', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证其他登录方式按钮可点击
    final fingerprintButton = find.text('指纹登录');
    final faceButton = find.text('面容登录');
    final qrCodeButton = find.text('扫码登录');

    await tester.tap(fingerprintButton);
    await tester.tap(faceButton);
    await tester.tap(qrCodeButton);
    await tester.pump();
  });

  testWidgets('Login screen handles input errors', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 输入无效手机号
    final phoneField = find.widgetWithText(TextField, '手机号');
    await tester.enterText(phoneField, '123');
    await tester.pump();

    // 输入无效验证码
    final codeField = find.widgetWithText(TextField, '验证码');
    await tester.enterText(codeField, 'abc');
    await tester.pump();

    // 登录按钮应该禁用
    final loginButton = find.widgetWithText(ElevatedButton, '登录');
    expect(tester.widget<ElevatedButton>(loginButton).enabled, false);
  });
} 