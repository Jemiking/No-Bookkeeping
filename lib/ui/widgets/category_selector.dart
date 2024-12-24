import 'package:flutter/material.dart';
import '../../core/database/models/category.dart';

/// 分类选择器组件
class CategorySelector extends StatelessWidget {
  /// 分类列表
  final List<Category> categories;

  /// 选中的分类
  final Category? selectedCategory;

  /// 分类选择回调
  final ValueChanged<Category> onCategorySelected;

  /// 是否显示图标
  final bool showIcon;

  /// 是否显示子分类
  final bool showSubcategories;

  /// 构造函数
  const CategorySelector({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showIcon = true,
    this.showSubcategories = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16.0),
          _buildCategoryGrid(context),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          '选择分类',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        if (selectedCategory != null)
          TextButton(
            onPressed: () {
              onCategorySelected(selectedCategory!);
            },
            child: const Text('确认'),
          ),
      ],
    );
  }

  /// 构建分类网格
  Widget _buildCategoryGrid(BuildContext context) {
    final parentCategories = categories.where((c) => c.parentId == null).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: parentCategories.length,
      itemBuilder: (context, index) {
        final category = parentCategories[index];
        return _buildCategoryCell(context, category);
      },
    );
  }

  /// 构建分类单元格
  Widget _buildCategoryCell(BuildContext context, Category category) {
    final isSelected = selectedCategory?.id == category.id;
    final hasSubcategories = showSubcategories &&
        categories.any((c) => c.parentId == category.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (hasSubcategories) {
            _showSubcategoriesDialog(context, category);
          } else {
            onCategorySelected(category);
          }
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withOpacity(0.2),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcon && category.icon != null) ...[
                Icon(
                  IconData(
                    int.parse(category.icon!),
                    fontFamily: 'MaterialIcons',
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 4.0),
              ],
              Text(
                category.name,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasSubcategories) ...[
                const SizedBox(height: 4.0),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.0,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 显示子分类对话框
  void _showSubcategoriesDialog(BuildContext context, Category parentCategory) {
    final subcategories = categories
        .where((c) => c.parentId == parentCategory.id)
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    parentCategory.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final subcategory = subcategories[index];
                    return _buildCategoryCell(context, subcategory);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 