import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/features/statistics/screens/statistics_overview_screen.dart';

void main() {
  group('StatisticsOverviewScreen', () {
    testWidgets('应该正确渲染所有UI组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsOverviewScreen(),
        ),
      );

      // 验证AppBar
      expect(find.text('统计'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);

      // 验证时间段选择器
      expect(find.text('本月'), findsOneWidget);
      expect(find.text('三个月'), findsOneWidget);
      expect(find.text('六个月'), findsOneWidget);
      expect(find.text('一年'), findsOneWidget);

      // 验证收支概览卡片
      expect(find.text('收入'), findsOneWidget);
      expect(find.text('支出'), findsOneWidget);
      expect(find.text('结余'), findsOneWidget);
      expect(find.text('¥8,000'), findsOneWidget);
      expect(find.text('¥3,580'), findsOneWidget);
      expect(find.text('¥4,420'), findsOneWidget);

      // 验证支出构成
      expect(find.text('支出构成'), findsOneWidget);
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
      expect(find.text('购物'), findsOneWidget);
      expect(find.text('娱乐'), findsOneWidget);
      expect(find.text('其他'), findsOneWidget);

      // 验证月度趋势
      expect(find.text('月度趋势'), findsOneWidget);
    });

    testWidgets('点击时间段选择器应该更新选中状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsOverviewScreen(),
        ),
      );

      // 初始状态下应该选中"本月"
      final initialChip = find.widgetWithText(ChoiceChip, '本月');
      expect(
        tester.widget<ChoiceChip>(initialChip).selected,
        isTrue,
      );

      // 点击"三个月"选项
      await tester.tap(find.widgetWithText(ChoiceChip, '三个月'));
      await tester.pumpAndSettle();

      // 验证"三个月"被选中，"本月"未选中
      final threeMonthChip = find.widgetWithText(ChoiceChip, '三个月');
      expect(
        tester.widget<ChoiceChip>(threeMonthChip).selected,
        isTrue,
      );
      expect(
        tester.widget<ChoiceChip>(initialChip).selected,
        isFalse,
      );
    });

    testWidgets('点击日历图标应该显示日期选择器', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsOverviewScreen(),
        ),
      );

      // 点击日历图标
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // TODO: 添加日期选择器显示的验证
      // 当实现日期选择器功能后取消注释以下代码
      // expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('点击筛选图标应该显示筛选选项', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsOverviewScreen(),
        ),
      );

      // 点击筛选图标
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // TODO: 添加筛选选项显示的验证
      // 当实现筛选功能后取消注释以下代码
      // expect(find.byType(FilterDialog), findsOneWidget);
    });

    testWidgets('应该正确显示图表组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsOverviewScreen(),
        ),
      );

      // 验证饼图存在
      expect(find.byType(PieChart), findsOneWidget);

      // 验证折线图存在
      expect(find.byType(LineChart), findsOneWidget);

      // 验证图表图例
      expect(find.text('收入'), findsNWidgets(2)); // 一次在概览卡片中，一次在图例中
      expect(find.text('支出'), findsNWidgets(2)); // 一次在概览卡片中，一次在图例中
    });
  });
} 