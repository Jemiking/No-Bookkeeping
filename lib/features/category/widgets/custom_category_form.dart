import 'package:flutter/material.dart';
import '../models/custom_category.dart';

class CustomCategoryForm extends StatefulWidget {
  final CustomCategory? category;
  final Function(CustomCategory) onSave;

  const CustomCategoryForm({
    Key? key,
    this.category,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CustomCategoryForm> createState() => _CustomCategoryFormState();
}

class _CustomCategoryFormState extends State<CustomCategoryForm> {
  late TextEditingController _nameController;
  final Map<String, dynamic> _customFields = {};
  final List<MapEntry<String, TextEditingController>> _fieldControllers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _initCustomFields();
  }

  void _initCustomFields() {
    if (widget.category != null) {
      for (var entry in widget.category!.customFields.entries) {
        final controller = TextEditingController(text: entry.value.toString());
        _fieldControllers.add(MapEntry(entry.key, controller));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _fieldControllers) {
      controller.value.dispose();
    }
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
          ..._buildCustomFieldInputs(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addCustomField,
            child: const Text('添加自定义字段'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSave,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCustomFieldInputs() {
    return _fieldControllers.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: entry.value,
                decoration: InputDecoration(
                  labelText: entry.key,
                  hintText: '请输入${entry.key}',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeCustomField(entry.key),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _addCustomField() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加自定义字段'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: '字段名称',
            hintText: '请输入字段名称',
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _fieldControllers.add(
                  MapEntry(value, TextEditingController()),
                );
              });
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  void _removeCustomField(String fieldName) {
    setState(() {
      final index = _fieldControllers.indexWhere((e) => e.key == fieldName);
      if (index != -1) {
        _fieldControllers[index].value.dispose();
        _fieldControllers.removeAt(index);
      }
    });
  }

  void _handleSave() {
    // 收集自定义字段值
    for (var entry in _fieldControllers) {
      _customFields[entry.key] = entry.value.text;
    }

    final category = CustomCategory(
      id: widget.category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      customFields: _customFields,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(category);
  }
} 