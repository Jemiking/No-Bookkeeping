import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/screens/quick_record_screen.dart';
import 'package:untitled/core/widgets/number_keyboard.dart';
import 'package:untitled/core/widgets/category_selector.dart';

void main() {
  late Widget testWidget;

  setUp(() {
    testWidget = const MaterialApp(
      home: QuickRecordScreen(),
    );
  });

  testWidgets('Quick record screen shows correct initial layout', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 验证AppBar
    expect(find.text('记一笔'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);

    // 验证金额显示
    expect(find.text('¥ '), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // 验证类型切换按钮
    expect(find.text('支出'), findsOneWidget);
    expect(find.text('收入'), findsOneWidget);

    // 验证组件存在
    expect(find.byType(CategorySelector), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(NumberKeyboard), findsOneWidget);
  });

  testWidgets('Amount input works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击数字按钮
    await tester.tap(find.text('1'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.pump();
    expect(find.text('12'), findsOneWidget);

    await tester.tap(find.text('.'));
    await tester.pump();
    expect(find.text('12.'), findsOneWidget);

    await tester.tap(find.text('3'));
    await tester.pump();
    expect(find.text('12.3'), findsOneWidget);

    // 测试小数点后最多两位
    await tester.tap(find.text('4'));
    await tester.pump();
    expect(find.text('12.34'), findsOneWidget);

    await tester.tap(find.text('5'));
    await tester.pump();
    expect(find.text('12.34'), findsOneWidget);
  });

  testWidgets('Backspace and clear work correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 输入数字
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(find.text('123'), findsOneWidget);

    // 测试退格键
    await tester.tap(find.byIcon(Icons.backspace));
    await tester.pump();
    expect(find.text('12'), findsOneWidget);

    // 测试清除按钮
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Type switching works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 初始状态是支出
    final expenseButton = find.text('支出');
    final incomeButton = find.text('收入');

    // 验证初始状态
    expect(tester.widget<Container>(find.ancestor(
      of: find.text('支出'),
      matching: find.byType(Container),
    )).decoration, isA<BoxDecoration>().having(
      (d) => d.color,
      'color',
      isNotNull,
    ));

    // 切换到收入
    await tester.tap(incomeButton);
    await tester.pump();

    // 验证切换后状态
    expect(tester.widget<Container>(find.ancestor(
      of: find.text('收入'),
      matching: find.byType(Container),
    )).decoration, isA<BoxDecoration>().having(
      (d) => d.color,
      'color',
      isNotNull,
    ));
  });

  testWidgets('Save button shows error when amount is 0', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 点击保存按钮
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 验证错误提示
    expect(find.text('请输入金额和选择分类'), findsOneWidget);
  });

  testWidgets('Note input works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // 找到备注输入框
    final noteField = find.byType(TextField);

    // 输入备注
    await tester.enterText(noteField, '测试备注');
    await tester.pump();

    // 验证输入内容
    expect(find.text('测试备注'), findsOneWidget);
  });

  testWidgets('Close button dismisses screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuickRecordScreen()),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    // 打开快速记账页面
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // 点击关闭按钮
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // 验证页面已关闭
    expect(find.byType(QuickRecordScreen), findsNothing);
  });

  testWidgets('Screen is responsive', (WidgetTester tester) async {
    // 设置屏幕尺寸
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(testWidget);

    // 验证主要组件的布局
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(CategorySelector), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(NumberKeyboard), findsOneWidget);

    // 恢复屏幕尺寸
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });
} 