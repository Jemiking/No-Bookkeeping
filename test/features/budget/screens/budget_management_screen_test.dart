import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/features/budget/screens/budget_management_screen.dart';

void main() {
  group('BudgetManagementScreen', () {
    testWidgets('应该正确渲染所有UI组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BudgetManagementScreen(),
        ),
      );

      // 验证AppBar和标题
      expect(find.text('预算管理'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // 验证总预算卡片
      expect(find.text('本月总预算'), findsOneWidget);
      expect(find.text('¥10000.00'), findsOneWidget);
      expect(find.text('已支出: ¥6580.00'), findsOneWidget);
      expect(find.text('剩余: ¥3420.00'), findsOneWidget);
      expect(find.text('预算充足'), findsOneWidget);

      // 验证分类预算列表
      expect(find.text('分类预算'), findsOneWidget);
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
      expect(find.text('购物'), findsOneWidget);
      expect(find.text('娱乐'), findsOneWidget);
      expect(find.text('其他'), findsOneWidget);

      // 验证预算分布图表
      expect(find.text('预算分布'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('应该正确显示总预算信息', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BudgetManagementScreen(),
        ),
      );

      // 验证总预算金额
      expect(find.text('¥10000.00'), findsOneWidget);
      expect(find.text('已支出: ¥6580.00'), findsOneWidget);
      expect(find.text('剩余: ¥3420.00'), findsOneWidget);
      expect(find.text('预算充足'), findsOneWidget);

      // 验证预算使用率
      expect(find.text('预算使用率: 65.8%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(6)); // 1个总预算 + 5个分类预算
    });

    testWidgets('应该正确显示分类预算列表', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BudgetManagementScreen(),
        ),
      );

      // 验证分类预算金额
      expect(find.text('¥2000.00'), findsNWidgets(2)); // 餐饮和购物
      expect(find.text('¥800.00'), findsOneWidget); // 交通
      expect(find.text('¥1000.00'), findsOneWidget); // 娱乐
      expect(find.text('¥500.00'), findsOneWidget); // 其他

      // 验证分类预算支出
      expect(find.text('已支出: ¥1580.00'), findsOneWidget); // 餐饮
      expect(find.text('已支出: ¥500.00'), findsOneWidget); // 交通
      expect(find.text('已支出: ¥1500.00'), findsOneWidget); // 购物
      expect(find.text('已支出: ¥800.00'), findsOneWidget); // 娱乐
      expect(find.text('已支出: ¥200.00'), findsOneWidget); // 其他

      // 验证分类预算剩余
      expect(find.text('剩余: ¥420.00'), findsOneWidget); // 餐饮
      expect(find.text('剩余: ¥300.00'), findsOneWidget); // 交通
      expect(find.text('剩余: ¥500.00'), findsOneWidget); // 购物
      expect(find.text('剩余: ¥200.00'), findsOneWidget); // 娱乐
      expect(find.text('剩余: ¥300.00'), findsOneWidget); // 其他
    });

    testWidgets('应该正确显示预算分布图表', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BudgetManagementScreen(),
        ),
      );

      // 验证图表标题
      expect(find.text('预算分布'), findsOneWidget);

      // 验证图表组件
      expect(find.byType(PieChart), findsOneWidget);

      // 验证图例
      expect(find.text('餐饮'), findsNWidgets(2)); // 列表和图例各一次
      expect(find.text('交通'), findsNWidgets(2));
      expect(find.text('购物'), findsNWidgets(2));
      expect(find.text('娱乐'), findsNWidgets(2));
      expect(find.text('其他'), findsNWidgets(2));
    });

    testWidgets('点击编辑按钮应该准备编辑预算', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BudgetManagementScreen(),
        ),
      );

      // 验证编辑按钮存在
      expect(find.byIcon(Icons.edit), findsNWidgets(6)); // 1个总预算 + 5个分类预算

      // 点击总预算编辑按钮
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // TODO: 添加编辑对话框显示的验证
      // 当实现编辑功能后取消注释以下代码
      // expect(find.byType(AlertDialog), findsOneWidget);
      // expect(find.text('编辑总预算'), findsOneWidget);
    });

    testWidgets('点击添加按钮应该准备添加新预算', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BudgetManagementScreen(),
        ),
      );

      // 验证添加按钮存在
      expect(find.byIcon(Icons.add), findsOneWidget);

      // 点击添加按钮
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // TODO: 添加新预算对话框显示的验证
      // 当实现添加功能后取消注释以下代码
      // expect(find.byType(AlertDialog), findsOneWidget);
      // expect(find.text('添加预算'), findsOneWidget);
    });
  });
} 