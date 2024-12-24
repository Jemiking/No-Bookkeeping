import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/settings/pages/about_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AboutPage Widget Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const MaterialApp(
        home: AboutPage(),
      );
    });

    testWidgets('renders AboutPage correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // 验证页面标题
      expect(find.text('关于'), findsOneWidget);

      // 验证应用介绍文本
      expect(
        find.text('这是一款现代化的个人记账软件，致力于提供简单易用、功能强大的记账解决方案。'),
        findsOneWidget,
      );

      // 验证主要功能卡片
      expect(find.text('主要功能'), findsOneWidget);
      expect(find.text('多账户管理'), findsOneWidget);
      expect(find.text('分类与标签'), findsOneWidget);
      expect(find.text('数据统计'), findsOneWidget);
      expect(find.text('数据安全'), findsOneWidget);

      // 验证开发者信息卡片
      expect(find.text('开发者信息'), findsOneWidget);
      expect(find.text('联系我们'), findsOneWidget);
      expect(find.text('官方网站'), findsOneWidget);
      expect(find.text('开源地址'), findsOneWidget);

      // 验证版权信息
      expect(
        find.text('© 2024 Money Tracker. All rights reserved.'),
        findsOneWidget,
      );
    });

    testWidgets('displays default app info when PackageInfo is not available',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      expect(find.text('Money Tracker'), findsOneWidget);
      expect(find.text('Version 1.0.0 (1)'), findsOneWidget);
    });

    testWidgets('displays correct app info when PackageInfo is available',
        (WidgetTester tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '2.0.0',
        buildNumber: '42',
        buildSignature: '',
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Version 2.0.0 (42)'), findsOneWidget);
    });

    testWidgets('tapping contact info launches URL',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // 验证邮件链接
      expect(find.text('support@moneytracker.com'), findsOneWidget);

      // 验证网站链接
      expect(find.text('www.moneytracker.com'), findsOneWidget);

      // 验证GitHub链接
      expect(find.text('GitHub'), findsOneWidget);
    });
  });
} 