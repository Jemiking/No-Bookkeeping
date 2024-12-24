import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:your_app_name/core/widgets/date_picker.dart';

void main() {
  group('日期选择器测试', () {
    testWidgets('基本显示测试', (WidgetTester tester) async {
      final now = DateTime.now();
      DateTime? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePicker(
              initialDate: now,
              onDateSelected: (date) => selectedDate = date,
            ),
          ),
        ),
      );

      // 验证标题显示
      expect(find.text('选择日期'), findsOneWidget);

      // 验证当前日期显示
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      expect(find.text(dateStr), findsOneWidget);

      // 验证按钮显示
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);
    });

    testWidgets('日期选择测试', (WidgetTester tester) async {
      final now = DateTime.now();
      DateTime? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePicker(
              initialDate: now,
              onDateSelected: (date) => selectedDate = date,
            ),
          ),
        ),
      );

      // 点击日期
      await tester.tap(find.text(now.day.toString()).first);
      await tester.pump();

      // 点击确定按钮
      await tester.tap(find.text('确定'));
      await tester.pump();

      // 验证选择的日期
      expect(selectedDate?.year, equals(now.year));
      expect(selectedDate?.month, equals(now.month));
      expect(selectedDate?.day, equals(now.day));
    });

    testWidgets('时间选择测试', (WidgetTester tester) async {
      final now = DateTime.now();
      DateTime? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePicker(
              initialDate: now,
              showTimePicker: true,
              onDateSelected: (date) => selectedDate = date,
            ),
          ),
        ),
      );

      // 验证时间输入框显示
      expect(find.byType(TextField), findsNWidgets(2));

      // 输入小时
      await tester.enterText(
        find.byType(TextField).first,
        '10',
      );
      await tester.pump();

      // 输入分钟
      await tester.enterText(
        find.byType(TextField).last,
        '30',
      );
      await tester.pump();

      // 点击确定按钮
      await tester.tap(find.text('确定'));
      await tester.pump();

      // 验证选择的时间
      expect(selectedDate?.hour, equals(10));
      expect(selectedDate?.minute, equals(30));
    });

    testWidgets('日期格式测试', (WidgetTester tester) async {
      final now = DateTime.now();
      const customFormat = 'MM/dd/yyyy';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePicker(
              initialDate: now,
              dateFormat: customFormat,
            ),
          ),
        ),
      );

      // 验证自定义日期格式
      final dateStr = DateFormat(customFormat).format(now);
      expect(find.text(dateStr), findsOneWidget);
    });

    testWidgets('日期范围测试', (WidgetTester tester) async {
      final now = DateTime.now();
      final firstDate = now.subtract(const Duration(days: 7));
      final lastDate = now.add(const Duration(days: 7));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePicker(
              initialDate: now,
              firstDate: firstDate,
              lastDate: lastDate,
            ),
          ),
        ),
      );

      // 验证日期范围
      final calendar = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      expect(calendar.firstDate, equals(firstDate));
      expect(calendar.lastDate, equals(lastDate));
    });

    testWidgets('自定义文本测试', (WidgetTester tester) async {
      const customTitle = '选择活动日期';
      const customConfirm = '完成';
      const customCancel = '返回';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePicker(
              title: customTitle,
              confirmText: customConfirm,
              cancelText: customCancel,
            ),
          ),
        ),
      );

      // 验证自定义文本
      expect(find.text(customTitle), findsOneWidget);
      expect(find.text(customConfirm), findsOneWidget);
      expect(find.text(customCancel), findsOneWidget);
    });

    testWidgets('对话框显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DatePicker.show(context: context),
              child: const Text('显示日期选择器'),
            ),
          ),
        ),
      );

      // 点击按钮显示日期选择器
      await tester.tap(find.text('显示日期选择器'));
      await tester.pumpAndSettle();

      // 验证日期选择器显示
      expect(find.byType(DatePicker), findsOneWidget);

      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 验证日期选择器关闭
      expect(find.byType(DatePicker), findsNothing);
    });
  });
} 