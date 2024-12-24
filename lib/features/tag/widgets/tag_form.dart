import 'package:flutter/material.dart';
import '../models/tag.dart';

class TagForm extends StatefulWidget {
  final Tag? tag;
  final Function(Tag) onSave;

  const TagForm({
    Key? key,
    this.tag,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TagForm> createState() => _TagFormState();
}

class _TagFormState extends State<TagForm> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _color;
  String? _icon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name);
    _descriptionController = TextEditingController(text: widget.tag?.description);
    _color = widget.tag?.color;
    _icon = widget.tag?.icon;
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
              labelText: '标签名称',
              hintText: '请输入标签名称',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入标签名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '标签描述',
              hintText: '请输入标签描述',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // TODO: 添加颜色选择器
          // TODO: 添加图标选择器
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
    final tag = Tag(
      id: widget.tag?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      color: _color,
      icon: _icon,
      description: _descriptionController.text,
      createdAt: widget.tag?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(tag);
  }
} 