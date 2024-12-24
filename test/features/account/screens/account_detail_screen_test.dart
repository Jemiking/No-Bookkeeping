import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/account/screens/account_detail_screen.dart';
import 'package:money_tracker/features/account/screens/account_overview_screen.dart';

void main() {
  final testAccount = AccountData(
    name: '招商银行',
    balance: 15800.0,
    icon: Icons.credit_card,
    color: Colors.blue,
  );

  testWidgets('AccountDetailScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AccountDetailScreen(account: testAccount),
      ),
    );

    // 验证标题和操作按钮
    expect(find.text('招商银行'), findsOneWidget);
    expect(find.byType(PopupMenuButton), findsOneWidget);

    // 验证账户余额卡片
    expect(find.text('账户余额'), findsOneWidget);
    expect(find.text('¥15800.0'), findsOneWidget);
    expect(find.text('本月收入'), findsOneWidget);
    expect(find.text('本月支出'), findsOneWidget);
    expect(find.text('¥8,000'), findsOneWidget);
    expect(find.text('¥3,580'), findsOneWidget);

    // 验证交易列表
    expect(find.text('近期交易'), findsOneWidget);
    expect(find.text('早餐'), findsOneWidget);
    expect(find.text('地铁'), findsOneWidget);
    expect(find.text('12月工资'), findsOneWidget);
    expect(find.text('餐饮'), findsOneWidget);
    expect(find.text('交通'), findsOneWidget);
    expect(find.text('工资'), findsOneWidget);
    expect(find.text('-¥38.0'), findsOneWidget);
    expect(find.text('-¥7.0'), findsOneWidget);
    expect(find.text('+¥8000.0'), findsOneWidget);

    // 测试删除功能
    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    // 验证删除确认对话框
    expect(find.text('确认删除'), findsOneWidget);
    expect(find.text('确定要删除这个账户吗？删除后无法恢复。'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('删除'), findsNWidgets(2));

    // 测试取消删除
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('确认删除'), findsNothing);

    // 测试编辑功能
    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    // TODO: 验证导航到编辑页面

    // 测试点击交易记录
    await tester.tap(find.text('早餐'));
    await tester.pump();
    // TODO: 验证导航到交易详情页面
  });
} 