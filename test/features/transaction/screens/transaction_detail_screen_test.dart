import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/transaction/screens/transaction_detail_screen.dart';
import 'package:money_tracker/features/transaction/screens/transaction_list_screen.dart';

void main() {
  final testTransaction = TransactionData(
    id: '1',
    type: TransactionType.expense,
    amount: 38.0,
    category: '餐饮',
    date: DateTime(2024, 1, 23, 8, 30),
    description: '早餐',
    account: '招商银行',
  );

  testWidgets('TransactionDetailScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TransactionDetailScreen(transaction: testTransaction),
      ),
    );

    // 验证标题和操作按钮
    expect(find.text('账单详情'), findsOneWidget);
    expect(find.byType(PopupMenuButton), findsOneWidget);

    // 验证金额显示
    expect(find.text('-¥38.0'), findsOneWidget);
    expect(find.text('支出'), findsOneWidget);

    // 验证详细信息
    expect(find.text('分类'), findsOneWidget);
    expect(find.text('餐饮'), findsOneWidget);
    expect(find.text('账户'), findsOneWidget);
    expect(find.text('招商银行'), findsOneWidget);
    expect(find.text('时间'), findsOneWidget);
    expect(find.text('2024年1月23日 8:30'), findsOneWidget);
    expect(find.text('备注'), findsOneWidget);
    expect(find.text('早餐'), findsOneWidget);

    // 验证附件区域
    expect(find.text('附件'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);

    // 测试删除功能
    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    // 验证删除确认对话框
    expect(find.text('确认删除'), findsOneWidget);
    expect(find.text('确定要删除这条记录吗？'), findsOneWidget);
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
  });
} 