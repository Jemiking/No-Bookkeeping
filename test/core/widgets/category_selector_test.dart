import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/core/widgets/category_selector.dart';

void main() {
  final testCategories = [
    CategoryData(
      id: '1',
      name: '餐饮',
      icon: Icons.restaurant,
      subCategories: [
        CategoryData(
          id: '1-1',
          name: '早餐',
          icon: Icons.breakfast_dining,
        ),
        CategoryData(
          id: '1-2',
          name: '午餐',
          icon: Icons.lunch_dining,
        ),
      ],
    ),
    CategoryData(
      id: '2',
      name: '交通',
      icon: Icons.directions_car,
      subCategories: [
        CategoryData(
          id: '2-1',
          name: '公交',
          icon: Icons.directions_bus,
        ),
        CategoryData(
          id: '2-2',
          name: '地铁',
          icon: Icons.subway,
        ),
      ],
    ),
  ];

  group('分类选择器测试', () {
    testWidgets('基本显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              categories: testCategories,
            ),
          ),
        ),
      );

      // 验证主分类显示
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);

      // 验证搜索框显示
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('分类选择测试', (WidgetTester tester) async {
      CategoryData? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              categories: testCategories,
              onSelected: (category) => selectedCategory = category,
            ),
          ),
        ),
      );

      // 点击分类
      await tester.tap(find.text('餐饮'));
      await tester.pump();

      // 验证子分类显示
      expect(find.text('早餐'), findsOneWidget);
      expect(find.text('午餐'), findsOneWidget);

      // 点击子分类
      await tester.tap(find.text('早餐'));
      await tester.pump();

      // 验证选择结果
      expect(selectedCategory?.id, equals('1-1'));
      expect(selectedCategory?.name, equals('早餐'));
    });

    testWidgets('搜索功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              categories: testCategories,
            ),
          ),
        ),
      );

      // 输入搜索关键字
      await tester.enterText(find.byType(TextField), '餐');
      await tester.pump();

      // 验证搜索结果
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsNothing);
    });

    testWidgets('多选功能测试', (WidgetTester tester) async {
      final selectedCategories = <CategoryData>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              categories: testCategories,
              multiSelect: true,
              onMultiSelected: (categories) => selectedCategories
                ..clear()
                ..addAll(categories),
            ),
          ),
        ),
      );

      // 点击多个分类
      await tester.tap(find.text('餐饮'));
      await tester.pump();
      await tester.tap(find.text('早餐'));
      await tester.pump();
      await tester.tap(find.text('午餐'));
      await tester.pump();

      // 验证多选结果
      expect(selectedCategories.length, equals(3));
      expect(
        selectedCategories.map((e) => e.name),
        containsAll(['餐饮', '早餐', '午餐']),
      );
    });

    testWidgets('对话框显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CategorySelector.show(
                  context: context,
                  categories: testCategories,
                );
              },
              child: const Text('选择分类'),
            ),
          ),
        ),
      );

      // 点击按钮显示对话框
      await tester.tap(find.text('选择分类'));
      await tester.pumpAndSettle();

      // 验证对话框显示
      expect(find.text('选择分类'), findsNWidgets(2));
      expect(find.byIcon(Icons.close), findsOneWidget);

      // 点击关闭按钮
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 验证对话框关闭
      expect(find.byType(CategorySelector), findsNothing);
    });

    testWidgets('自定义样式测试', (WidgetTester tester) async {
      const iconSize = 48.0;
      const itemHeight = 100.0;
      const gridColumns = 3;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              categories: testCategories,
              iconSize: iconSize,
              itemHeight: itemHeight,
              gridColumns: gridColumns,
            ),
          ),
        ),
      );

      // 验证图标大小
      final icon = tester.widget<Icon>(find.byIcon(Icons.restaurant));
      expect(icon.size, equals(iconSize));

      // 验证网格列数
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(gridColumns));
    });

    testWidgets('返回按钮测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              categories: testCategories,
            ),
          ),
        ),
      );

      // 进入子分类
      await tester.tap(find.text('餐饮'));
      await tester.pump();

      // 验证子分类显示
      expect(find.text('早餐'), findsOneWidget);
      expect(find.text('午餐'), findsOneWidget);

      // 点击返回按钮
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // 验证返回主分类
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
    });
  });
} 