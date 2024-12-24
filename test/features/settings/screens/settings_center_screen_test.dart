import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/features/settings/screens/settings_center_screen.dart';

void main() {
  group('SettingsCenterScreen', () {
    testWidgets('应该正确渲染所有UI组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsCenterScreen(),
        ),
      );

      // 验证AppBar和标题
      expect(find.text('设置'), findsOneWidget);

      // 验证用户信息区域
      expect(find.text('用户名'), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);

      // 验证通知设置区域
      expect(find.text('通知设置'), findsOneWidget);
      expect(find.text('启用通知'), findsOneWidget);
      expect(find.text('预算提醒'), findsOneWidget);
      expect(find.text('账单提醒'), findsOneWidget);

      // 验证安全设置区域
      expect(find.text('安全设置'), findsOneWidget);
      expect(find.text('修改密码'), findsOneWidget);
      expect(find.text('生物识别'), findsOneWidget);
      expect(find.text('自动锁定'), findsOneWidget);

      // 验证主题设置区域
      expect(find.text('主题设置'), findsOneWidget);
      expect(find.text('主题模式'), findsOneWidget);
      expect(find.text('自定义主题'), findsOneWidget);

      // 验证通用设置区域
      expect(find.text('通用设置'), findsOneWidget);
      expect(find.text('货币单位'), findsOneWidget);
      expect(find.text('数据备份'), findsOneWidget);
      expect(find.text('清除缓存'), findsOneWidget);

      // 验证关于区域
      expect(find.text('关于'), findsOneWidget);
      expect(find.text('检查更新'), findsOneWidget);
      expect(find.text('用户协议'), findsOneWidget);
      expect(find.text('隐私政策'), findsOneWidget);
      expect(find.text('关于我们'), findsOneWidget);

      // 验证退出登录按钮
      expect(find.text('退出登录'), findsOneWidget);
    });

    testWidgets('通知开关应该正确工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsCenterScreen(),
        ),
      );

      // 初始状态下所有通知开关应该是开启的
      expect(
        tester.widget<SwitchListTile>(
          find.ancestor(
            of: find.text('启用通知'),
            matching: find.byType(SwitchListTile),
          ),
        ).value,
        isTrue,
      );
      expect(
        tester.widget<SwitchListTile>(
          find.ancestor(
            of: find.text('预算提醒'),
            matching: find.byType(SwitchListTile),
          ),
        ).value,
        isTrue,
      );
      expect(
        tester.widget<SwitchListTile>(
          find.ancestor(
            of: find.text('账单提醒'),
            matching: find.byType(SwitchListTile),
          ),
        ).value,
        isTrue,
      );

      // 关闭总通知开关
      await tester.tap(
        find.ancestor(
          of: find.text('启用通知'),
          matching: find.byType(SwitchListTile),
        ),
      );
      await tester.pumpAndSettle();

      // 验证所有通知开关都被禁用
      expect(
        tester.widget<SwitchListTile>(
          find.ancestor(
            of: find.text('启用通知'),
            matching: find.byType(SwitchListTile),
          ),
        ).value,
        isFalse,
      );
      expect(
        tester.widget<SwitchListTile>(
          find.ancestor(
            of: find.text('预算提醒'),
            matching: find.byType(SwitchListTile),
          ),
        ).onChanged,
        isNull,
      );
      expect(
        tester.widget<SwitchListTile>(
          find.ancestor(
            of: find.text('账单提醒'),
            matching: find.byType(SwitchListTile),
          ),
        ).onChanged,
        isNull,
      );
    });

    testWidgets('主题选择对话框应该正确显示和工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsCenterScreen(),
        ),
      );

      // 点击主题模式选项
      await tester.tap(
        find.ancestor(
          of: find.text('主题模式'),
          matching: find.byType(ListTile),
        ),
      );
      await tester.pumpAndSettle();

      // 验证对话框显示
      expect(find.text('选择主题模式'), findsOneWidget);
      expect(find.text('跟随系统'), findsOneWidget);
      expect(find.text('浅色模式'), findsOneWidget);
      expect(find.text('深色模式'), findsOneWidget);

      // 选择深色模式
      await tester.tap(find.text('深色模式'));
      await tester.pumpAndSettle();

      // 验证选择已更新
      expect(
        find.ancestor(
          of: find.text('深色模式'),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );
    });

    testWidgets('货币单位选择对话框应该正确显示和工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsCenterScreen(),
        ),
      );

      // 点击货币单位选项
      await tester.tap(
        find.ancestor(
          of: find.text('货币单位'),
          matching: find.byType(ListTile),
        ),
      );
      await tester.pumpAndSettle();

      // 验证对话框显示
      expect(find.text('选择货币单位'), findsOneWidget);
      expect(find.text('CNY'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('GBP'), findsOneWidget);
      expect(find.text('JPY'), findsOneWidget);

      // 选择USD
      await tester.tap(find.text('USD'));
      await tester.pumpAndSettle();

      // 验证选择已更新
      expect(
        find.ancestor(
          of: find.text('USD'),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );
    });

    testWidgets('清除缓存对话框应该正确显示和工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsCenterScreen(),
        ),
      );

      // 点击清除缓存选项
      await tester.tap(
        find.ancestor(
          of: find.text('清除缓存'),
          matching: find.byType(ListTile),
        ),
      );
      await tester.pumpAndSettle();

      // 验证对话框显示
      expect(find.text('清除缓存'), findsOneWidget);
      expect(find.text('确定要清除应用缓存数据吗？'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);

      // 点击确定按钮
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      // 验证提示消息显示
      expect(find.text('缓存已清除'), findsOneWidget);
    });

    testWidgets('退出登录对话框应该正确显示和工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsCenterScreen(),
        ),
      );

      // 点击退出登录按钮
      await tester.tap(find.text('退出登录'));
      await tester.pumpAndSettle();

      // 验证对话框显示
      expect(find.text('退出登录'), findsOneWidget);
      expect(find.text('确定要退出登录吗？'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('确定'),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );

      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 验证对话框已关闭
      expect(find.text('确定要退出登录吗？'), findsNothing);
    });
  });
} 