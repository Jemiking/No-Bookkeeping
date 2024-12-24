import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/features/settings/screens/personal_info_screen.dart';

void main() {
  group('PersonalInfoScreen', () {
    testWidgets('应该正确渲染所有UI组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalInfoScreen(),
        ),
      );

      // 验证AppBar和标题
      expect(find.text('个人信息'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);

      // 验证头像部分
      expect(find.text('点击更换头像'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);

      // 验证表单字段
      expect(find.text('昵称'), findsOneWidget);
      expect(find.text('请输入昵称'), findsOneWidget);
      expect(find.text('邮箱'), findsOneWidget);
      expect(find.text('请输入邮箱'), findsOneWidget);
      expect(find.text('手机号码'), findsOneWidget);
      expect(find.text('请输入手机号码（选填）'), findsOneWidget);

      // 验证注销账号按钮
      expect(find.text('注销账号'), findsOneWidget);
    });

    testWidgets('表单验证应该正确工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalInfoScreen(),
        ),
      );

      // 清空所有字段
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.enterText(find.byType(TextFormField).at(2), '');

      // 点击保存按钮
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 验证错误提示
      expect(find.text('昵称不能为空'), findsOneWidget);
      expect(find.text('邮箱不能为空'), findsOneWidget);

      // 输入无效的邮箱
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(find.text('请输入有效的邮箱地址'), findsOneWidget);

      // 输入无效的手机号码
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(find.text('请输入有效的手机号码'), findsOneWidget);

      // 输入有效数据
      await tester.enterText(find.byType(TextFormField).at(0), '测试用户');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), '13800138000');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 验证成功提示
      expect(find.text('个人信息已更新'), findsOneWidget);
    });

    testWidgets('注销账号对话框应该正确显示和工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalInfoScreen(),
        ),
      );

      // 点击注销账号按钮
      await tester.tap(find.text('注销账号'));
      await tester.pumpAndSettle();

      // 验证对话框显示
      expect(find.text('注销账号'), findsOneWidget);
      expect(
        find.text('确定要注销账号吗？此操作不可恢复，您的所有数据将被永久删除。'),
        findsOneWidget,
      );
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('确定注销'), findsOneWidget);

      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 验证对话框已关闭
      expect(
        find.text('确定要注销账号吗？此操作不可恢复，您的所有数据将被永久删除。'),
        findsNothing,
      );
    });
  });
} 