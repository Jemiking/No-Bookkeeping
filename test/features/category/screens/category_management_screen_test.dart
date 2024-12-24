import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/category/screens/category_management_screen.dart';

void main() {
  testWidgets('CategoryManagementScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CategoryManagementScreen()));

    // 验证标题和操作按钮
    expect(find.text('分类管理'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    // 验证标签页
    expect(find.text('支出'), findsOneWidget);
    expect(find.text('收入'), findsOneWidget);

    // 验证支出分类列表
    expect(find.text('餐饮'), findsOneWidget);
    expect(find.text('交通'), findsOneWidget);
    expect(find.text('购物'), findsOneWidget);

    // 切换到收入分类
    await tester.tap(find.text('收入'));
    await tester.pumpAndSettle();

    // 验证收入分类列表
    expect(find.text('工资'), findsOneWidget);
    expect(find.text('奖金'), findsOneWidget);
    expect(find.text('理财'), findsOneWidget);

    // 测试进入编辑模式
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // 验证编辑模式下的按钮
    expect(find.byIcon(Icons.done), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsWidgets);
    expect(find.byIcon(Icons.edit), findsWidgets);

    // 测试添加分类
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // 验证添加分类对话框
    expect(find.text('新建分类'), findsOneWidget);
    expect(find.text('分类名称'), findsOneWidget);
    expect(find.text('选择图标'), findsOneWidget);
    expect(find.text('选择颜色'), findsOneWidget);

    // 填写分类信息
    await tester.enterText(find.byType(TextFormField), '测试分类');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 验证新分类已添加
    expect(find.text('测试分类'), findsOneWidget);

    // 测试编辑分类
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    // 验证编辑分类对话框
    expect(find.text('编辑分类'), findsOneWidget);
    expect(find.text('测试分类'), findsOneWidget);

    // 修改分类名称
    await tester.enterText(find.byType(TextFormField), '修改后的分类');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 验证分类已更新
    expect(find.text('修改后的分类'), findsOneWidget);

    // 测试删除分类
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    // 验证删除确认对话框
    expect(find.text('确认删除'), findsOneWidget);
    expect(find.text('确定要删除分类"修改后的分类"吗？'), findsOneWidget);

    // 确认删除
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    // 验证分类已删除
    expect(find.text('修改后的分类'), findsNothing);

    // 测试分类排序
    final firstCategory = find.text('餐饮');
    final secondCategory = find.text('交通');
    
    // 记录初始位置
    final firstPosition = tester.getCenter(firstCategory);
    final secondPosition = tester.getCenter(secondCategory);

    // 执行拖动
    await tester.drag(firstCategory, Offset(0, secondPosition.dy - firstPosition.dy));
    await tester.pumpAndSettle();

    // 验证顺序已改变
    expect(tester.getCenter(firstCategory).dy, greaterThan(tester.getCenter(secondCategory).dy));
  });
} 