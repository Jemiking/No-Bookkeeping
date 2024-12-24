import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/guide/screens/guide_screen.dart';

void main() {
  testWidgets('GuideScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: GuideScreen()));

    // 验证第一页内容
    expect(find.text('轻松记账'), findsOneWidget);
    expect(find.text('让生活更有规划'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);

    // 验证下一步按钮
    expect(find.text('下一步'), findsOneWidget);

    // 滑动到第二页
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // 验证第二页内容
    expect(find.text('智能分析'), findsOneWidget);
    expect(find.text('了解你的消费习惯'), findsOneWidget);
    expect(find.byIcon(Icons.analytics), findsOneWidget);

    // 滑动到第三页
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // 验证第三页内容和开始使用按钮
    expect(find.text('安全可靠'), findsOneWidget);
    expect(find.text('数据安全有保障'), findsOneWidget);
    expect(find.byIcon(Icons.security), findsOneWidget);
    expect(find.text('开始使用'), findsOneWidget);
  });
} 