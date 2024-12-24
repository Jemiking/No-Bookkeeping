import 'package:flutter/material.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;

  // 模拟数据
  final List<CategoryData> _expenseCategories = [
    CategoryData(
      id: '1',
      name: '餐饮',
      icon: Icons.restaurant,
      color: Colors.orange,
      order: 0,
    ),
    CategoryData(
      id: '2',
      name: '交通',
      icon: Icons.directions_car,
      color: Colors.blue,
      order: 1,
    ),
    CategoryData(
      id: '3',
      name: '购物',
      icon: Icons.shopping_bag,
      color: Colors.pink,
      order: 2,
    ),
  ];

  final List<CategoryData> _incomeCategories = [
    CategoryData(
      id: '4',
      name: '工资',
      icon: Icons.work,
      color: Colors.green,
      order: 0,
    ),
    CategoryData(
      id: '5',
      name: '奖金',
      icon: Icons.card_giftcard,
      color: Colors.purple,
      order: 1,
    ),
    CategoryData(
      id: '6',
      name: '理财',
      icon: Icons.account_balance,
      color: Colors.teal,
      order: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addCategory() {
    // TODO: 实现添加分类功能
    showDialog(
      context: context,
      builder: (context) => CategoryDialog(
        onSave: (category) {
          setState(() {
            if (_tabController.index == 0) {
              _expenseCategories.add(category);
            } else {
              _incomeCategories.add(category);
            }
          });
        },
      ),
    );
  }

  void _editCategory(CategoryData category) {
    showDialog(
      context: context,
      builder: (context) => CategoryDialog(
        category: category,
        onSave: (updatedCategory) {
          setState(() {
            final categories =
                _tabController.index == 0 ? _expenseCategories : _incomeCategories;
            final index = categories.indexWhere((c) => c.id == category.id);
            if (index != -1) {
              categories[index] = updatedCategory;
            }
          });
        },
      ),
    );
  }

  void _deleteCategory(CategoryData category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除分类"${category.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (_tabController.index == 0) {
                  _expenseCategories.removeWhere((c) => c.id == category.id);
                } else {
                  _incomeCategories.removeWhere((c) => c.id == category.id);
                }
              });
              Navigator.pop(context);
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '支出'),
            Tab(text: '收入'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(_expenseCategories),
          _buildCategoryList(_incomeCategories),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryData> categories) {
    return ReorderableListView(
      padding: const EdgeInsets.all(16),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = categories.removeAt(oldIndex);
          categories.insert(newIndex, item);
          // 更新排序
          for (var i = 0; i < categories.length; i++) {
            categories[i] = categories[i].copyWith(order: i);
          }
        });
      },
      children: categories.map((category) {
        return _buildCategoryItem(category);
      }).toList(),
    );
  }

  Widget _buildCategoryItem(CategoryData category) {
    return Card(
      key: ValueKey(category.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withOpacity(0.1),
          child: Icon(
            category.icon,
            color: category.color,
          ),
        ),
        title: Text(category.name),
        trailing: _isEditing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editCategory(category),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteCategory(category),
                  ),
                ],
              )
            : const Icon(Icons.drag_handle),
      ),
    );
  }
}

class CategoryData {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int order;

  CategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.order,
  });

  CategoryData copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    int? order,
  }) {
    return CategoryData(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
    );
  }
}

class CategoryDialog extends StatefulWidget {
  final CategoryData? category;
  final Function(CategoryData) onSave;

  const CategoryDialog({
    super.key,
    this.category,
    required this.onSave,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late IconData _selectedIcon;
  late Color _selectedColor;

  final List<IconData> _icons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.work,
    Icons.card_giftcard,
    Icons.account_balance,
    Icons.sports_esports,
    Icons.medical_services,
    Icons.house,
    Icons.school,
  ];

  final List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    } else {
      _selectedIcon = _icons[0];
      _selectedColor = _colors[0];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? '新建分类' : '编辑分类'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入分类名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('选择图标'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.map((icon) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(icon),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('选择颜色'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((color) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final category = CategoryData(
                id: widget.category?.id ?? DateTime.now().toString(),
                name: _nameController.text,
                icon: _selectedIcon,
                color: _selectedColor,
                order: widget.category?.order ?? 0,
              );
              widget.onSave(category);
              Navigator.pop(context);
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
} 