import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/splash/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // 验证Logo是否存在
    expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);

    // 验证应用名称是否正确显示
    expect(find.text('Money Tracker'), findsOneWidget);

    // 验证标语是否正确显示
    expect(find.text('Simple & Clean'), findsOneWidget);
  });
} 