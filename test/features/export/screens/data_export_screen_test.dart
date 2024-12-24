import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/features/export/screens/data_export_screen.dart';

void main() {
  group('DataExportScreen', () {
    testWidgets('应该正确渲染所有UI组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DataExportScreen(),
        ),
      );

      // 验证AppBar和标题
      expect(find.text('数据导出'), findsOneWidget);

      // 验证导出格式选择器
      expect(find.text('导出格式'), findsOneWidget);
      expect(find.text('Excel'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('导出为Excel格式，支持详细的数据分析'), findsOneWidget);

      // 验证时间范围选择器
      expect(find.text('时间范围'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsNWidgets(2));
      expect(find.text('最近一周'), findsOneWidget);
      expect(find.text('最近一月'), findsOneWidget);
      expect(find.text('最近三月'), findsOneWidget);
      expect(find.text('最近一年'), findsOneWidget);

      // 验证数据类型选择器
      expect(find.text('数据类型'), findsOneWidget);
      expect(find.text('账单记录'), findsOneWidget);
      expect(find.text('账户信息'), findsOneWidget);
      expect(find.text('预算数据'), findsOneWidget);
      expect(find.text('分类数据'), findsOneWidget);
      expect(find.text('标签数据'), findsOneWidget);
      expect(find.text('取消全选'), findsOneWidget);

      // 验证导出按钮
      expect(find.text('开始导出'), findsOneWidget);
    });

    testWidgets('点击导出格式选项应该更新选中状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DataExportScreen(),
        ),
      );

      // 初始状态应该选中Excel
      expect(find.text('导出为Excel格式，支持详细的数据分析'), findsOneWidget);

      // 点击CSV选项
      await tester.tap(find.text('CSV'));
      await tester.pumpAndSettle();

      // 验证提示文本已更新
      expect(find.text('导出为CSV格式，便于数据迁移和处理'), findsOneWidget);

      // 点击PDF选项
      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();

      // 验证提示文本已更新
      expect(find.text('导出为PDF格式，适合打印和存档'), findsOneWidget);
    });

    testWidgets('点击快速时间选择按钮应该更新日期范围', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DataExportScreen(),
        ),
      );

      final now = DateTime.now();
      final initialEndDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // 点击"最近一周"按钮
      await tester.tap(find.text('最近一周'));
      await tester.pumpAndSettle();

      // 验证结束日期是今天
      expect(find.text(initialEndDate), findsOneWidget);

      // 验证开始日期是7天前
      final weekAgo = now.subtract(const Duration(days: 7));
      final weekAgoStr = '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';
      expect(find.text(weekAgoStr), findsOneWidget);
    });

    testWidgets('点击全选/取消全选按钮应该更新所有数据类型的选中状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DataExportScreen(),
        ),
      );

      // 初始状态应该全部选中
      expect(find.text('取消全选'), findsOneWidget);

      // 点击取消全选
      await tester.tap(find.text('取消全选'));
      await tester.pumpAndSettle();

      // 验证按钮文本变为"全选"
      expect(find.text('全选'), findsOneWidget);

      // 点击全选
      await tester.tap(find.text('全选'));
      await tester.pumpAndSettle();

      // 验证按钮文本变回"取消全选"
      expect(find.text('取消全选'), findsOneWidget);
    });

    testWidgets('没有选择数据类型时导出按钮应该禁用', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DataExportScreen(),
        ),
      );

      // 点击取消全选
      await tester.tap(find.text('取消全选'));
      await tester.pumpAndSettle();

      // 验证导出按钮被禁用
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '开始导出'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('点击导出按钮应该显示导出进度', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DataExportScreen(),
        ),
      );

      // 点击导出按钮
      await tester.tap(find.text('开始导出'));
      await tester.pump();

      // 验证显示导出进度
      expect(find.text('导出中...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 等待导出完成
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 验证显示成功提示
      expect(find.text('导出成功！'), findsOneWidget);
    });
  });
} 