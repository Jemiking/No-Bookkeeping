import 'package:flutter/material.dart';

/// 分类数据模型
class CategoryData {
  final String id;
  final String name;
  final IconData icon;
  final Color? color;
  final List<CategoryData>? subCategories;

  const CategoryData({
    required this.id,
    required this.name,
    required this.icon,
    this.color,
    this.subCategories,
  });
}

/// 分类选择器组件
class CategorySelector extends StatefulWidget {
  /// 分类列表
  final List<CategoryData> categories;
  
  /// 选中的分类ID
  final String? selectedId;
  
  /// 分类选择回调
  final ValueChanged<CategoryData>? onSelected;
  
  /// 是否显示子分类
  final bool showSubCategories;
  
  /// 是否支持多选
  final bool multiSelect;
  
  /// 多选时的选中列表
  final List<String>? selectedIds;
  
  /// 多选回调
  final ValueChanged<List<CategoryData>>? onMultiSelected;
  
  /// 图标大小
  final double iconSize;
  
  /// 项目高度
  final double itemHeight;
  
  /// 网格列数
  final int gridColumns;
  
  /// 是否显示搜索框
  final bool showSearch;

  const CategorySelector({
    super.key,
    required this.categories,
    this.selectedId,
    this.onSelected,
    this.showSubCategories = true,
    this.multiSelect = false,
    this.selectedIds,
    this.onMultiSelected,
    this.iconSize = 32,
    this.itemHeight = 80,
    this.gridColumns = 4,
    this.showSearch = true,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? _currentParentId;
  List<String> _selectedIds = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.selectedIds ?? [];
    if (widget.selectedId != null) {
      _selectedIds = [widget.selectedId!];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        if (widget.showSearch) _buildSearchBar(theme),
        Expanded(
          child: _currentParentId == null
              ? _buildMainCategories(theme)
              : _buildSubCategories(theme),
        ),
      ],
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索分类',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// 构建主分类列表
  Widget _buildMainCategories(ThemeData theme) {
    final filteredCategories = _searchQuery.isEmpty
        ? widget.categories
        : widget.categories.where((category) {
            return category.name.contains(_searchQuery);
          }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridColumns,
        childAspectRatio: widget.itemHeight / (widget.itemHeight + 20),
      ),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        final isSelected = _selectedIds.contains(category.id);
        
        return _buildCategoryItem(
          theme,
          category,
          isSelected,
          () {
            if (widget.showSubCategories && category.subCategories != null) {
              setState(() {
                _currentParentId = category.id;
              });
            } else {
              _handleSelection(category);
            }
          },
        );
      },
    );
  }

  /// 构建子分类列表
  Widget _buildSubCategories(ThemeData theme) {
    final parentCategory = widget.categories.firstWhere(
      (category) => category.id == _currentParentId,
    );
    final subCategories = parentCategory.subCategories ?? [];

    final filteredSubCategories = _searchQuery.isEmpty
        ? subCategories
        : subCategories.where((category) {
            return category.name.contains(_searchQuery);
          }).toList();

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: Text(parentCategory.name),
          onTap: () {
            setState(() {
              _currentParentId = null;
            });
          },
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.gridColumns,
              childAspectRatio: widget.itemHeight / (widget.itemHeight + 20),
            ),
            itemCount: filteredSubCategories.length,
            itemBuilder: (context, index) {
              final category = filteredSubCategories[index];
              final isSelected = _selectedIds.contains(category.id);
              
              return _buildCategoryItem(
                theme,
                category,
                isSelected,
                () => _handleSelection(category),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建分类项目
  Widget _buildCategoryItem(
    ThemeData theme,
    CategoryData category,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : null,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                ),
              ),
              child: Icon(
                category.icon,
                size: widget.iconSize,
                color: isSelected
                    ? theme.colorScheme.primary
                    : category.color ?? theme.iconTheme.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? theme.colorScheme.primary : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 处理选择事件
  void _handleSelection(CategoryData category) {
    if (widget.multiSelect) {
      setState(() {
        if (_selectedIds.contains(category.id)) {
          _selectedIds.remove(category.id);
        } else {
          _selectedIds.add(category.id);
        }
      });
      
      final selectedCategories = widget.categories
          .expand((c) => [...[c], ...(c.subCategories ?? [])])
          .where((c) => _selectedIds.contains(c.id))
          .toList();
      
      widget.onMultiSelected?.call(selectedCategories);
    } else {
      setState(() {
        _selectedIds = [category.id];
      });
      widget.onSelected?.call(category);
    }
  }

  /// 显示分类选择器对话框
  static Future<CategoryData?> show({
    required BuildContext context,
    required List<CategoryData> categories,
    String? selectedId,
    bool showSubCategories = true,
    bool multiSelect = false,
    List<String>? selectedIds,
    double? iconSize,
    double? itemHeight,
    int? gridColumns,
    bool? showSearch,
  }) {
    return showModalBottomSheet<CategoryData>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选择分类',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CategorySelector(
                categories: categories,
                selectedId: selectedId,
                showSubCategories: showSubCategories,
                multiSelect: multiSelect,
                selectedIds: selectedIds,
                iconSize: iconSize ?? 32,
                itemHeight: itemHeight ?? 80,
                gridColumns: gridColumns ?? 4,
                showSearch: showSearch ?? true,
                onSelected: (category) {
                  Navigator.of(context).pop(category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 