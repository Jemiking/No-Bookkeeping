import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/core/widgets/chart_view.dart';

void main() {
  group('图表组件测试', () {
    testWidgets('折线图基本显示测试', (WidgetTester tester) async {
      final series = [
        ChartSeries(
          name: '收入',
          data: [
            ChartPoint(x: 0, y: 100),
            ChartPoint(x: 1, y: 200),
            ChartPoint(x: 2, y: 150),
          ],
          color: Colors.blue,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartView(
              type: ChartType.line,
              series: series,
              title: '收入趋势',
              xAxisTitle: '时间',
              yAxisTitle: '金额',
            ),
          ),
        ),
      );

      // 验证标题显示
      expect(find.text('收入趋势'), findsOneWidget);
      expect(find.text('时间'), findsOneWidget);
      expect(find.text('金额'), findsOneWidget);

      // 验证图例显示
      expect(find.text('收入'), findsOneWidget);
    });

    testWidgets('柱状图基本显示测试', (WidgetTester tester) async {
      final series = [
        ChartSeries(
          name: '支出',
          data: [
            ChartPoint(x: 0, y: 50),
            ChartPoint(x: 1, y: 80),
            ChartPoint(x: 2, y: 30),
          ],
          color: Colors.red,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartView(
              type: ChartType.bar,
              series: series,
              title: '支出分布',
              xAxisTitle: '类别',
              yAxisTitle: '金额',
            ),
          ),
        ),
      );

      // 验证标题显示
      expect(find.text('支出分布'), findsOneWidget);
      expect(find.text('类别'), findsOneWidget);
      expect(find.text('金额'), findsOneWidget);

      // 验证图例显示
      expect(find.text('支出'), findsOneWidget);
    });

    testWidgets('饼图基本显示测试', (WidgetTester tester) async {
      final series = [
        ChartSeries(
          name: '分类占比',
          data: [
            ChartPoint(x: 0, y: 30, label: '餐饮'),
            ChartPoint(x: 1, y: 20, label: '交通'),
            ChartPoint(x: 2, y: 50, label: '购物'),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartView(
              type: ChartType.pie,
              series: series,
              title: '支出分类',
            ),
          ),
        ),
      );

      // 验证标题显示
      expect(find.text('支出分类'), findsOneWidget);

      // 验证图例显示
      expect(find.text('分类占比'), findsOneWidget);
    });

    testWidgets('散点图基本显示测试', (WidgetTester tester) async {
      final series = [
        ChartSeries(
          name: '消费分布',
          data: [
            ChartPoint(x: 1, y: 100),
            ChartPoint(x: 2, y: 150),
            ChartPoint(x: 3, y: 80),
          ],
          color: Colors.green,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartView(
              type: ChartType.scatter,
              series: series,
              title: '消费分布图',
              xAxisTitle: '日期',
              yAxisTitle: '金额',
            ),
          ),
        ),
      );

      // 验证标题显示
      expect(find.text('消费分布图'), findsOneWidget);
      expect(find.text('日期'), findsOneWidget);
      expect(find.text('金额'), findsOneWidget);

      // 验证��例显示
      expect(find.text('消费分布'), findsOneWidget);
    });

    testWidgets('雷达图基本显示测试', (WidgetTester tester) async {
      final series = [
        ChartSeries(
          name: '消费特征',
          data: [
            ChartPoint(x: 0, y: 80, label: '餐饮'),
            ChartPoint(x: 1, y: 60, label: '交通'),
            ChartPoint(x: 2, y: 90, label: '购物'),
            ChartPoint(x: 3, y: 70, label: '娱乐'),
            ChartPoint(x: 4, y: 50, label: '医疗'),
          ],
          color: Colors.purple,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartView(
              type: ChartType.radar,
              series: series,
              title: '消费特征分析',
            ),
          ),
        ),
      );

      // 验证标题显示
      expect(find.text('消费特征分析'), findsOneWidget);

      // 验证图例显示
      expect(find.text('消费特征'), findsOneWidget);
    });

    testWidgets('图表组件配置测试', (WidgetTester tester) async {
      final series = [
        ChartSeries(
          name: '测试数据',
          data: [
            ChartPoint(x: 0, y: 100),
            ChartPoint(x: 1, y: 200),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartView(
              type: ChartType.line,
              series: series,
              showLegend: false,
              showGrid: false,
              showTooltip: false,
              height: 400,
              padding: const EdgeInsets.all(24),
              backgroundColor: Colors.grey[100],
              gridColor: Colors.grey[300],
              textStyle: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );

      // 验证图例不显示
      expect(find.text('测试数据'), findsNothing);

      // 验证容器高度
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, 400);

      // 验证内边距
      expect(container.padding, const EdgeInsets.all(24));

      // 验证背景色
      expect(
        (container.decoration as BoxDecoration?)?.color,
        Colors.grey[100],
      );
    });

    testWidgets('图表交互测试', (WidgetTester tester) async {
      final series = [
        ChartSeries(
          name: '测试数据',
          data: [
            ChartPoint(x: 0, y: 100),
            ChartPoint(x: 1, y: 200),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartView(
              type: ChartType.line,
              series: series,
              showTooltip: true,
              enableZoom: true,
            ),
          ),
        ),
      );

      // 模拟点击事件
      await tester.tap(find.byType(LineChart));
      await tester.pump();

      // 模拟缩放事件
      await tester.scale(
        center: tester.getCenter(find.byType(LineChart)),
        scale: 2.0,
      );
      await tester.pump();
    });
  });
} 