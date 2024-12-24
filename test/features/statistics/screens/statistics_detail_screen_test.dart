import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/features/statistics/screens/statistics_detail_screen.dart';

void main() {
  group('StatisticsDetailScreen', () {
    testWidgets('应该正确渲染所有UI组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsDetailScreen(),
        ),
      );

      // 验证AppBar和标题
      expect(find.text('统计详情'), findsOneWidget);

      // 验证Tab标签
      expect(find.text('收支明细'), findsOneWidget);
      expect(find.text('分类统计'), findsOneWidget);
      expect(find.text('趋势分析'), findsOneWidget);

      // 验证时间段选择器
      expect(find.text('本月'), findsOneWidget);
      expect(find.text('三个月'), findsOneWidget);
      expect(find.text('六个月'), findsOneWidget);
      expect(find.text('一年'), findsOneWidget);

      // 验证收支明细列表中的数据
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
      expect(find.text('工资'), findsOneWidget);
      expect(find.text('购物'), findsOneWidget);
      expect(find.text('娱乐'), findsOneWidget);
    });

    testWidgets('点击时间段选择器应该更新选中状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsDetailScreen(),
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

    testWidgets('点击Tab应该切换显示内容', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsDetailScreen(),
        ),
      );

      // 初始显示收支明细
      expect(find.text('午餐'), findsOneWidget);
      expect(find.text('分类排行'), findsNothing);
      expect(find.text('每日趋势'), findsNothing);

      // 点击分类统计Tab
      await tester.tap(find.text('分类统计'));
      await tester.pumpAndSettle();

      // 验证显示分类统计内容
      expect(find.text('午餐'), findsNothing);
      expect(find.text('分类排行'), findsOneWidget);
      expect(find.text('每日趋势'), findsNothing);

      // 点击趋势分析Tab
      await tester.tap(find.text('趋势分析'));
      await tester.pumpAndSettle();

      // 验证显示趋势分析内容
      expect(find.text('午餐'), findsNothing);
      expect(find.text('分类排行'), findsNothing);
      expect(find.text('每日趋势'), findsOneWidget);
    });

    testWidgets('应该正确显示收支明细列表', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsDetailScreen(),
        ),
      );

      // 验证收支明细列表项
      expect(find.text('午餐'), findsOneWidget);
      expect(find.text('地铁'), findsOneWidget);
      expect(find.text('3月工资'), findsOneWidget);
      expect(find.text('日用品'), findsOneWidget);
      expect(find.text('电影票'), findsOneWidget);

      // 验证金额显示
      expect(find.text('-¥30.00'), findsOneWidget);
      expect(find.text('-¥5.00'), findsOneWidget);
      expect(find.text('+¥8000.00'), findsOneWidget);
      expect(find.text('-¥200.00'), findsOneWidget);
      expect(find.text('-¥80.00'), findsOneWidget);
    });

    testWidgets('应该正确显示分类统计', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsDetailScreen(),
        ),
      );

      // 切换到分类统计Tab
      await tester.tap(find.text('分类统计'));
      await tester.pumpAndSettle();

      // 验证分类统计数据
      expect(find.text('分类排行'), findsOneWidget);
      expect(find.text('52笔 · ¥1580.00'), findsOneWidget);
      expect(find.text('45笔 · ¥500.00'), findsOneWidget);
      expect(find.text('20笔 · ¥1500.00'), findsOneWidget);
      expect(find.text('15笔 · ¥800.00'), findsOneWidget);
      expect(find.text('8笔 · ¥200.00'), findsOneWidget);
    });

    testWidgets('应该正确显示趋势分析图表', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsDetailScreen(),
        ),
      );

      // 切换到趋势分析Tab
      await tester.tap(find.text('趋势分析'));
      await tester.pumpAndSettle();

      // 验证趋势分析内容
      expect(find.text('每日趋势'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('收入'), findsOneWidget);
      expect(find.text('支出'), findsOneWidget);
    });
  });
} 