import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/models/account.dart';
import 'package:untitled/core/screens/account_overview_screen.dart';

void main() {
  testWidgets('AccountOverviewScreen displays loading indicator initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AccountOverviewScreen(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AccountOverviewScreen displays account groups correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AccountOverviewScreen(),
      ),
    );

    // Wait for the loading to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify account group titles are displayed
    expect(find.text('现金账户'), findsOneWidget);
    expect(find.text('储蓄卡'), findsOneWidget);
    expect(find.text('信用卡'), findsOneWidget);

    // Verify account names are displayed
    expect(find.text('现金'), findsOneWidget);
    expect(find.text('招商银行'), findsOneWidget);
    expect(find.text('工商银行'), findsOneWidget);
    expect(find.text('交通银行信用卡'), findsOneWidget);
  });

  testWidgets('AccountOverviewScreen toggles balance visibility',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AccountOverviewScreen(),
      ),
    );

    // Wait for the loading to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Initially, balances should be visible
    expect(find.text('¥1580.00'), findsOneWidget);
    expect(find.text('¥15800.00'), findsOneWidget);
    expect(find.text('¥8000.00'), findsOneWidget);
    expect(find.text('¥-3580.00'), findsOneWidget);

    // Tap the visibility toggle button
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    // After toggling, balances should be hidden
    expect(find.text('****'), findsNWidgets(6)); // Total + Assets + Liabilities + 3 accounts
  });

  testWidgets('AccountOverviewScreen shows account options on long press',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AccountOverviewScreen(),
      ),
    );

    // Wait for the loading to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Long press on an account
    await tester.longPress(find.text('现金'));
    await tester.pump();

    // Verify bottom sheet options are displayed
    expect(find.text('编辑账户'), findsOneWidget);
    expect(find.text('归档账户'), findsOneWidget);
    expect(find.text('删除账户'), findsOneWidget);
  });

  testWidgets('AccountOverviewScreen shows delete confirmation dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AccountOverviewScreen(),
      ),
    );

    // Wait for the loading to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Long press on an account
    await tester.longPress(find.text('现金'));
    await tester.pump();

    // Tap delete option
    await tester.tap(find.text('删除账户'));
    await tester.pump();

    // Verify delete confirmation dialog is displayed
    expect(find.text('确认删除'), findsOneWidget);
    expect(find.text('确定要删除账户"现金"吗？删除后无法恢复。'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);
  });

  testWidgets('AccountOverviewScreen calculates total assets correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AccountOverviewScreen(),
      ),
    );

    // Wait for the loading to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Total assets should be sum of all positive balances
    expect(find.text('¥21800.00'), findsOneWidget); // 1580 + 15800 + 8000 - 3580
  });
} 