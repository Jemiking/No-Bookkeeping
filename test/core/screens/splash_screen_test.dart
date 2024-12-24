import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/core/screens/splash_screen.dart';
import 'package:your_app_name/core/services/app_initializer.dart';

void main() {
  group('启动屏幕测试', () {
    late Widget nextScreen;

    setUp(() {
      nextScreen = const Scaffold(
        body: Center(
          child: Text('下一个页面'),
        ),
      );
    });

    testWidgets('基本显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            nextScreen: nextScreen,
          ),
        ),
      );

      // 验证基本元素显示
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Your App Name'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('正在加载...'), findsOneWidget);
    });

    testWidgets('动画测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            nextScreen: nextScreen,
          ),
        ),
      );

      // 验证初始状态
      var fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition).first,
      );
      expect(fadeTransition.opacity.value, 0.0);

      // 等待动画开始
      await tester.pump(const Duration(milliseconds: 100));
      fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition).first,
      );
      expect(fadeTransition.opacity.value, greaterThan(0.0));

      // 等待动画完成
      await tester.pump(const Duration(milliseconds: 1500));
      fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition).first,
      );
      expect(fadeTransition.opacity.value, 1.0);
    });

    testWidgets('导航测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            nextScreen: nextScreen,
            minimumDuration: const Duration(milliseconds: 100),
          ),
        ),
      );

      // 等待最小持续时间
      await tester.pump(const Duration(milliseconds: 100));

      // 等待页面转换动画
      await tester.pumpAndSettle();

      // 验证导航到下一个页面
      expect(find.text('下一个页面'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('错误处理测试', (WidgetTester tester) async {
      // 模拟初始化错误
      AppInitializer.instance.initialize = () async {
        throw Exception('初始化错误');
      };

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            nextScreen: nextScreen,
          ),
        ),
      );

      // 等待错误发生
      await tester.pump(const Duration(seconds: 2));

      // 验证错误处理
      // TODO: 添加错误UI测试，当错误处理UI完成后取消注释
      // expect(find.text('初始化失败'), findsOneWidget);
      // expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('最小持续时间测试', (WidgetTester tester) async {
      const minimumDuration = Duration(seconds: 3);
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            nextScreen: nextScreen,
            minimumDuration: minimumDuration,
          ),
        ),
      );

      // 验证在最小持续时间之前不会导航
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('下一个页面'), findsNothing);

      // 等待最小持续时间后验证导航
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('下一个页面'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('主题适配测试', (WidgetTester tester) async {
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      // 测试亮色主题
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: SplashScreen(
            nextScreen: nextScreen,
          ),
        ),
      );

      var scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(lightTheme.colorScheme.background));

      // 测试暗色主题
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: SplashScreen(
            nextScreen: nextScreen,
          ),
        ),
      );

      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(darkTheme.colorScheme.background));
    });

    testWidgets('布局响应式测试', (WidgetTester tester) async {
      // 设置不同的屏幕尺寸
      const Size smallScreen = Size(320, 480);
      const Size largeScreen = Size(1024, 768);

      // 测试小屏幕
      await tester.binding.setSurfaceSize(smallScreen);
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            nextScreen: nextScreen,
          ),
        ),
      );

      var image = tester.widget<Image>(find.byType(Image));
      expect(image.width, equals(120));
      expect(image.height, equals(120));

      // 测试大屏幕
      await tester.binding.setSurfaceSize(largeScreen);
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            nextScreen: nextScreen,
          ),
        ),
      );

      image = tester.widget<Image>(find.byType(Image));
      expect(image.width, equals(120));
      expect(image.height, equals(120));

      // 恢复默认尺寸
      await tester.binding.setSurfaceSize(null);
    });
  });
} 