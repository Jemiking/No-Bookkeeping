import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/account/screens/account_overview_screen.dart';

void main() {
  testWidgets('AccountOverviewScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountOverviewScreen()));

    // 验证标题和添加按钮
    expect(find.text('账户'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    // 验证总资产卡片
    expect(find.text('总资产'), findsOneWidget);
    expect(find.text('¥25,380.00'), findsOneWidget);
    expect(find.text('总收入'), findsOneWidget);
    expect(find.text('总支出'), findsOneWidget);
    expect(find.text('¥35,800'), findsOneWidget);
    expect(find.text('¥10,420'), findsOneWidget);

    // 验证账户分类标题
    expect(find.text('现金账户'), findsOneWidget);
    expect(find.text('银行卡'), findsOneWidget);
    expect(find.text('信用卡'), findsOneWidget);

    // 验证账户列表
    expect(find.text('现金'), findsOneWidget);
    expect(find.text('¥1580.0'), findsOneWidget);

    expect(find.text('招商银行'), findsOneWidget);
    expect(find.text('¥15800.0'), findsOneWidget);

    expect(find.text('工商银行'), findsOneWidget);
    expect(find.text('¥8000.0'), findsOneWidget);

    expect(find.text('交通银行'), findsOneWidget);
    expect(find.text('¥-3580.0'), findsOneWidget);

    // 测试点击账户
    await tester.tap(find.text('招商银行'));
    await tester.pump();
    // TODO: 验证导航到账户详情页面

    // 测试点击添加按钮
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    // TODO: 验证导航到添加账户页面
  });
} 