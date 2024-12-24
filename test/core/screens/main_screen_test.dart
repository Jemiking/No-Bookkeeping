import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/core/screens/main_screen.dart';
import 'package:your_app_name/core/widgets/app_drawer.dart';
import 'package:your_app_name/core/widgets/bottom_nav_bar.dart';

void main() {
  late Widget testWidget;

  setUp(() {
    testWidget = const MaterialApp(
      home: MainScreen(),
    );
  });

  testWidgets('Main screen shows correct initial layout', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证AppBar
    expect(find.text('总览'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none), findsOneWidget);

    // 验证底部导航栏
    expect(find.text('总览'), findsOneWidget);
    expect(find.text('账单'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    // 验证悬浮按钮
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Bottom navigation bar changes pages', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 初始页面是总览
    expect(find.text('总览页面'), findsOneWidget);

    // 点击账单标签
    await tester.tap(find.text('账单'));
    await tester.pumpAndSettle();
    expect(find.text('账单页面'), findsOneWidget);

    // 点击统计标签
    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();
    expect(find.text('统计页面'), findsOneWidget);

    // 点击我的标签
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('我的页面'), findsOneWidget);
  });

  testWidgets('Drawer opens when menu button is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击菜单按钮
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // 验证抽屉是否打开
    expect(find.byType(Drawer), findsOneWidget);
  });

  testWidgets('FAB shows bottom sheet when pressed', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击悬浮按钮
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 验证底部弹出框是否显示
    expect(find.text('记账页面'), findsOneWidget);
  });

  testWidgets('Bottom nav bar shows correct icons', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证底部导航栏图标
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    expect(find.byIcon(Icons.pie_chart), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('App bar title changes with page', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 初始标题是总览
    expect(find.widgetWithText(AppBar, '总览'), findsOneWidget);

    // 点击账单标签
    await tester.tap(find.text('账单'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '账单'), findsOneWidget);

    // 点击统计标签
    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '统计'), findsOneWidget);

    // 点击我的标签
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '我的'), findsOneWidget);
  });

  testWidgets('Bottom nav bar highlights selected item', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 获取底部导航栏
    final navBar = find.byType(CustomBottomNavBar);

    // 点击不同的标签并验证高亮状态
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text(['总览', '账单', '统计', '我的'][i]));
      await tester.pumpAndSettle();

      final navBarWidget = tester.widget<CustomBottomNavBar>(navBar);
      expect(navBarWidget.currentIndex, i);
    }
  });

  testWidgets('Main screen layout is responsive', (WidgetTester tester) async {
    // 设置屏幕尺寸
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(testWidget);

    // 验证主要组件的布局
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(IndexedStack), findsOneWidget);
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // 恢复屏幕尺寸
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });
} 