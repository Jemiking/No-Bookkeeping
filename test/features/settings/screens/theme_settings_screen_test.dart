import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/features/settings/screens/theme_settings_screen.dart';

void main() {
  group('ThemeSettingsScreen', () {
    testWidgets('应该正确渲染所有UI组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSettingsScreen(),
        ),
      );

      // 验证AppBar和标题
      expect(find.text('主题设置'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // 验证深色模式开关
      expect(find.text('深色模式'), findsOneWidget);
      expect(find.text('切换应用的明暗主题'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // 验证主题色选择
      expect(find.text('主题色'), findsOneWidget);
      expect(find.text('选择应用的主题色'), findsOneWidget);

      // 验证预设主题
      expect(find.text('预设主题'), findsOneWidget);
      expect(find.text('默认主题'), findsOneWidget);
      expect(find.text('清新绿意'), findsOneWidget);
      expect(find.text('深邃蓝调'), findsOneWidget);
      expect(find.text('温暖橙光'), findsOneWidget);
      expect(find.text('优雅紫韵'), findsOneWidget);

      // 验证字体设置
      expect(find.text('字体大小'), findsOneWidget);
      expect(find.text('字体样式'), findsOneWidget);
      expect(find.text('选择应用的字体'), findsOneWidget);

      // 验证自定义主题
      expect(find.text('自定义主题'), findsOneWidget);
      expect(find.text('创建和管理自定义主题'), findsOneWidget);

      // 验证主题导出
      expect(find.text('导出主题'), findsOneWidget);
      expect(find.text('分享当前主题设置'), findsOneWidget);
    });

    testWidgets('深色模式开关应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSettingsScreen(),
        ),
      );

      final switchFinder = find.byType(Switch);
      expect(tester.widget<Switch>(switchFinder).value, false);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(switchFinder).value, true);
    });

    testWidgets('主题色选择器应该正常显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSettingsScreen(),
        ),
      );

      await tester.tap(find.text('主题色'));
      await tester.pumpAndSettle();

      expect(find.text('选择主题色'), findsOneWidget);
      expect(find.byType(InkWell), findsNWidgets(8)); // 8个预设颜色
    });

    testWidgets('字体大小调整应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSettingsScreen(),
        ),
      );

      await tester.tap(find.text('字体大小'));
      await tester.pumpAndSettle();

      expect(find.text('调整字体大小'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('预览文本'), findsOneWidget);
    });

    testWidgets('重置设置应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSettingsScreen(),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(find.text('重置主题设置'), findsOneWidget);
      expect(find.text('确定要将所有主题设置恢复为默认值吗？'), findsOneWidget);

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(find.text('已重置主题设置'), findsOneWidget);
    });

    testWidgets('预设主题选择应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSettingsScreen(),
        ),
      );

      final defaultThemeChip = find.widgetWithText(ChoiceChip, '默认主题');
      expect(tester.widget<ChoiceChip>(defaultThemeChip).selected, true);

      await tester.tap(find.widgetWithText(ChoiceChip, '清新绿意'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '清新绿意')).selected,
        true,
      );
      expect(
        tester.widget<ChoiceChip>(defaultThemeChip).selected,
        false,
      );
    });
  });
}