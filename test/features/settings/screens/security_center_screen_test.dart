import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/features/settings/screens/security_center_screen.dart';

void main() {
  group('SecurityCenterScreen', () {
    testWidgets('应该正确渲染所有UI组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecurityCenterScreen(),
        ),
      );

      // 验证AppBar和标题
      expect(find.text('安全中心'), findsOneWidget);

      // 验证密码修改部分
      expect(find.text('登录密码'), findsOneWidget);
      expect(find.text('定期修改密码可以提高账号安全性'), findsOneWidget);
      expect(find.text('修改'), findsOneWidget);

      // 验证安全日志部分
      expect(find.text('安全日志'), findsOneWidget);
      expect(find.text('查看近期的安全相关操作记录'), findsOneWidget);
      expect(find.text('查看'), findsOneWidget);

      // 验证设备管理部分
      expect(find.text('登录设备管理'), findsOneWidget);
      expect(find.text('查看和管理已登录的设备'), findsOneWidget);
      expect(find.text('管理'), findsOneWidget);

      // 验证隐私设置部分
      expect(find.text('隐私设置'), findsOneWidget);
      expect(find.text('管理应用的隐私相关设置'), findsOneWidget);

      // 验证数据备份部分
      expect(find.text('数据备份'), findsOneWidget);
      expect(find.text('设置自动备份和加密方式'), findsOneWidget);
    });

    testWidgets('密码修改对话框应该正确工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecurityCenterScreen(),
        ),
      );

      // 点击修改密码按钮
      await tester.tap(find.text('修改'));
      await tester.pumpAndSettle();

      // 验证对话框显示
      expect(find.text('修改密码'), findsOneWidget);
      expect(find.text('当前密码'), findsOneWidget);
      expect(find.text('新密码'), findsOneWidget);
      expect(find.text('确认新密码'), findsOneWidget);

      // 验证表单验证
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(find.text('请输入当前密码'), findsOneWidget);
      expect(find.text('请输入新密码'), findsOneWidget);
      expect(find.text('请确认新密码'), findsOneWidget);

      // 输入无效的密码
      await tester.enterText(
        find.widgetWithText(TextFormField, '新密码'),
        '123',
      );
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(find.text('密码长度不能少于8位'), findsOneWidget);

      // 输入不匹配的确认密码
      await tester.enterText(
        find.widgetWithText(TextFormField, '当前密码'),
        'currentPassword',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '新密码'),
        'newPassword123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '确认新密码'),
        'differentPassword123',
      );
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(find.text('两次输入的密码不一致'), findsOneWidget);

      // 输入有效的密码
      await tester.enterText(
        find.widgetWithText(TextFormField, '确认新密码'),
        'newPassword123',
      );
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();

      // 验证成功提示
      expect(find.text('密码修改成功'), findsOneWidget);
    });

    testWidgets('安全日志对话框应该正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecurityCenterScreen(),
        ),
      );

      // 点击查看安全日志按钮
      await tester.tap(find.text('查看').first);
      await tester.pumpAndSettle();

      // 验证对话框显示
      expect(find.text('安全日志'), findsOneWidget);
      expect(find.text('最近30天的安全操作记录：'), findsOneWidget);
      expect(find.text('• 2024-01-23 14:30 修改登录密码'), findsOneWidget);
      expect(find.text('• 2024-01-22 10:15 开启生物识别'), findsOneWidget);
      expect(find.text('• 2024-01-20 09:45 登录成功'), findsOneWidget);
      expect(find.text('关闭'), findsOneWidget);

      // 点击关闭按钮
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();

      // 验证对话框已关闭
      expect(find.text('最近30天的安全操作记录：'), findsNothing);
    });

    testWidgets('隐私设置和数据备份项应该可以点击', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecurityCenterScreen(),
        ),
      );

      // 验证隐私设置项可以点击
      await tester.tap(find.text('隐私设置'));
      await tester.pumpAndSettle();

      // 验证数据备份项可以点击
      await tester.tap(find.text('数据备份'));
      await tester.pumpAndSettle();
    });
  });
} 