import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/transaction/screens/transaction_list_screen.dart';

void main() {
  testWidgets('TransactionListScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TransactionListScreen()));

    // 验证标题和操作按钮
    expect(find.text('账单'), findsOneWidget);
    expect(find.byIcon(Icons.filter_list), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);

    // 验证统计信息
    expect(find.text('收入'), findsOneWidget);
    expect(find.text('支出'), findsOneWidget);
    expect(find.text('结余'), findsOneWidget);
    expect(find.text('¥8,000'), findsOneWidget);
    expect(find.text('¥3,580'), findsOneWidget);
    expect(find.text('¥4,420'), findsOneWidget);

    // 验证日期分组
    expect(find.text('今天'), findsOneWidget);
    expect(find.text('昨天'), findsOneWidget);

    // 验证交易记录
    expect(find.text('早餐'), findsOneWidget);
    expect(find.text('地铁'), findsOneWidget);
    expect(find.text('12月工资'), findsOneWidget);
    expect(find.text('招商银行'), findsOneWidget);
    expect(find.text('交通卡'), findsOneWidget);
    expect(find.text('工商银行'), findsOneWidget);
    expect(find.text('-¥38'), findsOneWidget);
    expect(find.text('-¥7'), findsOneWidget);
    expect(find.text('+¥8000'), findsOneWidget);

    // 测试点击交易记录
    await tester.tap(find.text('早餐'));
    await tester.pump();
    // TODO: 验证导航到详情页面

    // 测试点击筛选按钮
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pump();
    // TODO: 验证筛选选项显示

    // 测试点击搜索按钮
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    // TODO: 验证搜索界面显示
  });
} 