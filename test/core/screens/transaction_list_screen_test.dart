import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/screens/transaction_list_screen.dart';
import 'package:intl/intl.dart';

void main() {
  late Widget testWidget;

  setUp(() {
    testWidget = const MaterialApp(
      home: TransactionListScreen(),
    );
  });

  testWidgets('Transaction list screen shows correct initial layout', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证AppBar
    expect(find.text(DateFormat('yyyy年MM月').format(DateTime.now())), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    expect(find.byIcon(Icons.filter_list), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);

    // 验证月度统计
    expect(find.text('收入'), findsOneWidget);
    expect(find.text('支出'), findsOneWidget);
    expect(find.text('结余'), findsOneWidget);
    expect(find.text('¥8,000.00'), findsOneWidget);
    expect(find.text('¥3,580.00'), findsOneWidget);
    expect(find.text('¥4,420.00'), findsOneWidget);

    // 验证交易列表
    expect(find.text('今天'), findsOneWidget);
    expect(find.text('早餐'), findsOneWidget);
    expect(find.text('地铁'), findsOneWidget);
    expect(find.text('工资'), findsOneWidget);
  });

  testWidgets('Month picker shows and works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击月份选择器
    await tester.tap(find.text(DateFormat('yyyy年MM月').format(DateTime.now())));
    await tester.pumpAndSettle();

    // 验证月份选择器显示
    expect(find.text('选择月份'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确定'), findsOneWidget);

    // 选择一个月份
    final previousMonth = DateTime.now().subtract(const Duration(days: 30));
    final previousMonthText = DateFormat('yyyy年MM月').format(previousMonth);
    await tester.tap(find.text(previousMonthText));
    await tester.pumpAndSettle();

    // 验证选择结果
    expect(find.text(previousMonthText), findsOneWidget);
  });

  testWidgets('Filter dialog shows and works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击筛选按钮
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    // 验证筛选对话框显示
    expect(find.text('筛选'), findsOneWidget);
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('收入'), findsOneWidget);
    expect(find.text('支出'), findsOneWidget);

    // 选择一个筛选选项
    await tester.tap(find.text('收入'));
    await tester.pumpAndSettle();

    // 验证筛选对话框关闭
    expect(find.text('筛选'), findsNothing);
  });

  testWidgets('Transaction items show correct information', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证交易项显示
    expect(find.text('早餐'), findsOneWidget);
    expect(find.text('餐饮 · 招商银行'), findsOneWidget);
    expect(find.text('-38.00'), findsOneWidget);
    expect(find.text('08:30'), findsOneWidget);

    expect(find.text('地铁'), findsOneWidget);
    expect(find.text('交通 · 交通卡'), findsOneWidget);
    expect(find.text('-7.00'), findsOneWidget);
    expect(find.text('09:15'), findsOneWidget);

    expect(find.text('工资'), findsOneWidget);
    expect(find.text('工资 · 招商银行'), findsOneWidget);
    expect(find.text('+8000.00'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
  });

  testWidgets('Transaction items are tappable', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击交易项
    await tester.tap(find.text('早餐'));
    await tester.pumpAndSettle();

    // TODO: 验证导航到详情页面
  });

  testWidgets('Search button is clickable', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击搜索按钮
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // TODO: 验证搜索功能
  });

  testWidgets('Screen is responsive', (WidgetTester tester) async {
    // 设置屏幕尺寸
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(testWidget);

    // 验证主要组件的布局
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);

    // 恢复屏幕尺寸
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('Transaction list supports scrolling', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证列表可滚动
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
  });

  testWidgets('Month picker supports scrolling', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 打开月份选择器
    await tester.tap(find.text(DateFormat('yyyy年MM月').format(DateTime.now())));
    await tester.pumpAndSettle();

    // 验证月份列表可滚动
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
  });
} 