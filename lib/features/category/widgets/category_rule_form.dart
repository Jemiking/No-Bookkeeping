import 'package:flutter/material.dart';
import '../models/category_rule.dart';

class CategoryRuleForm extends StatefulWidget {
  final CategoryRule? rule;
  final String categoryId;
  final Function(CategoryRule) onSave;

  const CategoryRuleForm({
    Key? key,
    this.rule,
    required this.categoryId,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CategoryRuleForm> createState() => _CategoryRuleFormState();
}

class _CategoryRuleFormState extends State<CategoryRuleForm> {
  late TextEditingController _nameController;
  late TextEditingController _conditionController;
  final Map<String, dynamic> _parameters = {};
  bool _isEnabled = true;
  int _priority = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.name);
    _conditionController = TextEditingController(text: widget.rule?.condition);
    if (widget.rule != null) {
      _parameters.addAll(widget.rule!.parameters);
      _isEnabled = widget.rule!.isEnabled;
      _priority = widget.rule!.priority;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
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
              labelText: '规则名称',
              hintText: '请输入规则名称',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入规则名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _conditionController,
            decoration: const InputDecoration(
              labelText: '规则条件',
              hintText: '请输入规则条件',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildParametersSection(),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('启用规则'),
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('优先级：'),
              Expanded(
                child: Slider(
                  value: _priority.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _priority.toString(),
                  onChanged: (value) {
                    setState(() {
                      _priority = value.round();
                    });
                  },
                ),
              ),
              Text(_priority.toString()),
            ],
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

  Widget _buildParametersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('参数设置'),
        ..._parameters.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: entry.value.toString(),
                    decoration: InputDecoration(
                      labelText: entry.key,
                      hintText: '请输入${entry.key}',
                    ),
                    onChanged: (value) {
                      _parameters[entry.key] = value;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _parameters.remove(entry.key);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
        TextButton(
          onPressed: _addParameter,
          child: const Text('添加参数'),
        ),
      ],
    );
  }

  void _addParameter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加参数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '参数名称',
                hintText: '请输入参数名称',
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _parameters[value] = '';
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    final rule = CategoryRule(
      id: widget.rule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: widget.categoryId,
      name: _nameController.text,
      condition: _conditionController.text,
      parameters: _parameters,
      isEnabled: _isEnabled,
      priority: _priority,
      createdAt: widget.rule?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(rule);
  }
} 