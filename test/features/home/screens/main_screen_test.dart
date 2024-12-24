import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/home/screens/main_screen.dart';

void main() {
  testWidgets('MainScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainScreen()));

    // 验证底部导航栏项目
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('账户'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);

    // 验证浮动按钮
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // 测试页面切换
    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();
    expect(find.text('统计'), findsNWidgets(2)); // 一个在底部导航栏，一个在页面内容

    await tester.tap(find.text('账户'));
    await tester.pumpAndSettle();
    expect(find.text('账户'), findsNWidgets(2));

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsNWidgets(2));

    await tester.tap(find.text('首页'));
    await tester.pumpAndSettle();
    expect(find.text('首页'), findsNWidgets(2));
  });
} 