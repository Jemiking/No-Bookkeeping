import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/tag/screens/tag_management_screen.dart';

void main() {
  testWidgets('TagManagementScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TagManagementScreen()));

    // 验证标题和操作按钮
    expect(find.text('标签管理'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    // 验证标题文本
    expect(find.text('常用标签'), findsOneWidget);
    expect(find.text('标签消费'), findsOneWidget);

    // 验证初始标签
    expect(find.text('早餐'), findsOneWidget);
    expect(find.text('午餐'), findsOneWidget);
    expect(find.text('晚餐'), findsOneWidget);
    expect(find.text('地铁'), findsOneWidget);
    expect(find.text('公交'), findsOneWidget);
    expect(find.text('打车'), findsOneWidget);

    // 验证使用次数
    expect(find.text('15笔'), findsNWidgets(2)); // 早餐和午餐都是15笔
    expect(find.text('11笔'), findsOneWidget); // 晚餐11笔
    expect(find.text('20笔'), findsOneWidget); // 地铁20笔
    expect(find.text('8笔'), findsOneWidget); // 公交8笔
    expect(find.text('5笔'), findsOneWidget); // 打车5笔

    // 测试进入编辑模式
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // 验证编辑模式下的按钮
    expect(find.byIcon(Icons.done), findsOneWidget);
    expect(find.byIcon(Icons.close), findsWidgets);

    // 测试添加标签
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // 验证添加标签对话框
    expect(find.text('新建标签'), findsOneWidget);
    expect(find.text('标签名称'), findsOneWidget);
    expect(find.text('选择颜色'), findsOneWidget);

    // 填写标签信息
    await tester.enterText(find.byType(TextFormField), '测试标签');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 验证新标签已添加
    expect(find.text('测试标签'), findsOneWidget);

    // 测试编辑标签
    await tester.tap(find.text('测试标签'));
    await tester.pumpAndSettle();

    // 验证编辑标签对话框
    expect(find.text('编辑标签'), findsOneWidget);
    expect(find.text('测试标签'), findsOneWidget);

    // 修改标签名称
    await tester.enterText(find.byType(TextFormField), '修改后的标签');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 验证标签已更新
    expect(find.text('修改后的标签'), findsOneWidget);

    // 测试删除标签
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    // 验证删除确认对话框
    expect(find.text('确认删除'), findsOneWidget);
    expect(find.text('确定要删除标签"修改后的标签"吗？'), findsOneWidget);

    // 确认删除
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    // 验证标签已删除
    expect(find.text('修改后的标签'), findsNothing);
  });
} 