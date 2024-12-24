import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryForm extends StatefulWidget {
  final Category? category;
  final Function(Category) onSave;

  const CategoryForm({
    Key? key,
    this.category,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _parentId;
  String? _icon;
  String? _color;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController = TextEditingController(text: widget.category?.description);
    _parentId = widget.category?.parentId;
    _icon = widget.category?.icon;
    _color = widget.category?.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '分类名称',
              hintText: '请输入分类名称',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入分类名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '分类描述',
              hintText: '请输入分类描述',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // TODO: 添加父分类选择器
          // TODO: 添加图标选择器
          // TODO: 添加颜色选择器
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSave,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    final category = Category(
      id: widget.category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      parentId: _parentId,
      icon: _icon,
      color: _color,
      description: _descriptionController.text,
      isSystem: widget.category?.isSystem ?? false,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(category);
  }
} 