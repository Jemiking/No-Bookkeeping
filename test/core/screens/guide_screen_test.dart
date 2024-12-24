import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences.dart';
import 'package:untitled/core/screens/guide_screen.dart';

void main() {
  late Widget testWidget;

  setUp(() {
    testWidget = const MaterialApp(
      home: GuideScreen(),
      routes: {
        '/login': (context) => Scaffold(
              body: Center(child: Text('Login Screen')),
            ),
      },
    );
  });

  testWidgets('Guide screen shows correct initial page', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证第一页的标题和描述
    expect(find.text('轻松记账'), findsOneWidget);
    expect(find.text('让生活更有规划'), findsOneWidget);
    
    // 验证页面指示器
    expect(find.byType(AnimatedContainer), findsNWidgets(4));
    
    // 验证按钮
    expect(find.text('跳过'), findsOneWidget);
    expect(find.text('下一步'), findsOneWidget);
    expect(find.text('开始使用'), findsNothing);
  });

  testWidgets('Guide screen navigates to next page', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击下一步按钮
    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();

    // 验证第二页的标题和描述
    expect(find.text('智能分析'), findsOneWidget);
    expect(find.text('了解你的消费习惯'), findsOneWidget);
  });

  testWidgets('Guide screen shows finish button on last page', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 滑动到最后一页
    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
    }

    // 验证最后一页的标题和描述
    expect(find.text('安全可靠'), findsOneWidget);
    expect(find.text('数据安全有保障'), findsOneWidget);
    
    // 验证按钮文本变化
    expect(find.text('下一步'), findsNothing);
    expect(find.text('开始使用'), findsOneWidget);
  });

  testWidgets('Skip button navigates to login screen', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击跳过按钮
    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    // 验证导航到登录页面
    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('Finish button on last page navigates to login screen', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 滑动到最后一页
    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
    }

    // 点击开始使用按钮
    await tester.tap(find.text('开始使用'));
    await tester.pumpAndSettle();

    // 验证导航到登录页面
    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('Page indicators update correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 获取所有页面指示器
    final initialIndicators = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    
    // 验证第一个指示器是活动状态
    expect(initialIndicators.elementAt(0).constraints?.maxWidth, 24.0);
    expect(initialIndicators.elementAt(1).constraints?.maxWidth, 8.0);

    // 滑动到第二页
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // 获取更新后的指示器
    final updatedIndicators = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    
    // 验证第二个指示器变为活动状态
    expect(updatedIndicators.elementAt(0).constraints?.maxWidth, 8.0);
    expect(updatedIndicators.elementAt(1).constraints?.maxWidth, 24.0);
  });

  testWidgets('Guide screen has correct layout', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证页面布局
    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(4)); // 标题、描述、跳过按钮、下一步按钮
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });
} 