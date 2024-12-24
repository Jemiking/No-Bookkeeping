import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/transaction/screens/quick_record_screen.dart';

void main() {
  testWidgets('QuickRecordScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: QuickRecordScreen()));

    // 验证标题和保存按钮
    expect(find.text('记一笔'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);

    // 验证类型切换按钮
    expect(find.text('支出'), findsOneWidget);
    expect(find.text('收入'), findsOneWidget);

    // 验证初始金额
    expect(find.text('¥0'), findsOneWidget);

    // 验证分类选项
    expect(find.text('餐饮'), findsOneWidget);
    expect(find.text('交通'), findsOneWidget);
    expect(find.text('购物'), findsOneWidget);
    expect(find.text('娱乐'), findsOneWidget);
    expect(find.text('其他'), findsOneWidget);

    // 验证数字键盘
    for (var i = 0; i <= 9; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
    expect(find.text('.'), findsOneWidget);
    expect(find.text('⌫'), findsOneWidget);

    // 测试数字输入
    await tester.tap(find.text('1'));
    await tester.pump();
    expect(find.text('¥1'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.pump();
    expect(find.text('¥12'), findsOneWidget);

    await tester.tap(find.text('3'));
    await tester.pump();
    expect(find.text('¥123'), findsOneWidget);

    // 测试删除功能
    await tester.tap(find.text('⌫'));
    await tester.pump();
    expect(find.text('¥12'), findsOneWidget);

    // 测试类型切换
    await tester.tap(find.text('收入'));
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '收入')).style,
      isNotNull,
    );
  });
} 