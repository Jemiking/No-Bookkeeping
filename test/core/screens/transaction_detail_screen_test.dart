import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/screens/transaction_detail_screen.dart';
import 'package:intl/intl.dart';

void main() {
  late Widget testWidget;

  setUp(() {
    testWidget = const MaterialApp(
      home: TransactionDetailScreen(transactionId: '1'),
    );
  });

  testWidgets('Transaction detail screen shows loading state', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证加载状态
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Transaction detail screen shows correct layout after loading', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // 验证AppBar
    expect(find.text('账单详情'), findsOneWidget);
    expect(find.byIcon(Icons.share), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);

    // 验证金额显示
    expect(find.text('-38.00'), findsOneWidget);
    expect(find.text('支出'), findsOneWidget);

    // 验证详细信息
    expect(find.text('分类'), findsOneWidget);
    expect(find.text('餐饮'), findsOneWidget);
    expect(find.text('账户'), findsOneWidget);
    expect(find.text('招商银行'), findsOneWidget);
    expect(find.text('时间'), findsOneWidget);
    expect(find.text('位置'), findsOneWidget);
    expect(find.text('广州市天河区'), findsOneWidget);
    expect(find.text('备注'), findsOneWidget);
    expect(find.text('肠粉+豆浆'), findsOneWidget);

    // 验证标签
    expect(find.text('标签'), findsOneWidget);
    expect(find.text('早餐'), findsOneWidget);
    expect(find.text('工作日'), findsOneWidget);

    // 验证附件
    expect(find.text('附件'), findsOneWidget);
    expect(find.byIcon(Icons.insert_drive_file), findsNWidgets(2));
  });

  testWidgets('Delete button shows confirmation dialog', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // 点击删除按钮
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // 验证确认对话框
    expect(find.text('确认删除'), findsOneWidget);
    expect(find.text('删除后无法恢复，确定要删除吗？'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);
  });

  testWidgets('Share button shows options sheet', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // 点击分享按钮
    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    // 验证分享选项
    expect(find.text('生成图片'), findsOneWidget);
    expect(find.text('导出Excel'), findsOneWidget);
    expect(find.text('分享到其他应用'), findsOneWidget);
  });

  testWidgets('Transaction detail screen is scrollable', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // 验证可滚动
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
  });

  testWidgets('Attachments are tappable', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // 点击附件
    await tester.tap(find.byIcon(Icons.insert_drive_file).first);
    await tester.pumpAndSettle();

    // TODO: 验证附件查看功能
  });

  testWidgets('Edit button is clickable', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // 点击编辑按钮
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // TODO: 验证导航到编辑页面
  });

  testWidgets('Share options are clickable', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // 点击分享按钮
    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    // 点击分享选项
    await tester.tap(find.text('生成图片'));
    await tester.pumpAndSettle();

    // 再次打开分享选项
    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    // 点击导出选项
    await tester.tap(find.text('导出Excel'));
    await tester.pumpAndSettle();

    // 再次打开分享选项
    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    // 点击分享到其他应用选项
    await tester.tap(find.text('分享到其他应用'));
    await tester.pumpAndSettle();
  });

  testWidgets('Screen is responsive', (WidgetTester tester) async {
    // 设置屏幕尺寸
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // 验证主要组件的布局
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(Column), findsWidgets);

    // 恢复屏幕尺寸
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });
} 