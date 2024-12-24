import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/core/widgets/number_keyboard.dart';

void main() {
  group('数字键盘测试', () {
    testWidgets('数字输入测试', (WidgetTester tester) async {
      String? inputNumber;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberKeyboard(
              onNumberInput: (value) => inputNumber = value,
            ),
          ),
        ),
      );

      // 测试数字按键 1-9
      for (int i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pump();
        expect(inputNumber, equals('$i'));
      }

      // 测试数字 0
      await tester.tap(find.text('0'));
      await tester.pump();
      expect(inputNumber, equals('0'));
    });

    testWidgets('小数点测试', (WidgetTester tester) async {
      bool decimalPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberKeyboard(
              onDecimalPoint: () => decimalPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('.'));
      await tester.pump();
      expect(decimalPressed, isTrue);
    });

    testWidgets('删除按钮测试', (WidgetTester tester) async {
      bool deletePressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberKeyboard(
              showDoneButton: false,
              onDelete: () => deletePressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('←'));
      await tester.pump();
      expect(deletePressed, isTrue);
    });

    testWidgets('完成按钮测试', (WidgetTester tester) async {
      bool donePressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberKeyboard(
              onDone: () => donePressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('完成'));
      await tester.pump();
      expect(donePressed, isTrue);
    });

    testWidgets('禁用小数点测试', (WidgetTester tester) async {
      String? inputNumber;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberKeyboard(
              allowDecimal: false,
              onNumberInput: (value) => inputNumber = value,
            ),
          ),
        ),
      );

      expect(find.text('.'), findsNothing);
      expect(find.text('00'), findsOneWidget);

      await tester.tap(find.text('00'));
      await tester.pump();
      expect(inputNumber, equals('00'));
    });

    testWidgets('自定义样式测试', (WidgetTester tester) async {
      const keyHeight = 80.0;
      const keySpacing = 2.0;
      const backgroundColor = Colors.grey;
      const keyColor = Colors.blue;
      const textColor = Colors.white;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberKeyboard(
              keyHeight: keyHeight,
              keySpacing: keySpacing,
              backgroundColor: backgroundColor,
              keyColor: keyColor,
              textColor: textColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.color, equals(backgroundColor));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, equals(keySpacing));

      final text = tester.widget<Text>(find.text('1'));
      expect(text.style?.color, equals(textColor));
    });
  });
} 