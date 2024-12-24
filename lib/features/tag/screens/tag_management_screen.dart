import 'package:flutter/material.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  bool _isEditing = false;

  // 模拟数据
  final List<TagData> _tags = [
    TagData(
      id: '1',
      name: '早餐',
      color: Colors.orange,
      usageCount: 15,
    ),
    TagData(
      id: '2',
      name: '午餐',
      color: Colors.blue,
      usageCount: 15,
    ),
    TagData(
      id: '3',
      name: '晚餐',
      color: Colors.pink,
      usageCount: 11,
    ),
    TagData(
      id: '4',
      name: '地铁',
      color: Colors.green,
      usageCount: 20,
    ),
    TagData(
      id: '5',
      name: '公交',
      color: Colors.purple,
      usageCount: 8,
    ),
    TagData(
      id: '6',
      name: '打车',
      color: Colors.teal,
      usageCount: 5,
    ),
  ];

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) => TagDialog(
        onSave: (tag) {
          setState(() {
            _tags.add(tag);
          });
        },
      ),
    );
  }

  void _editTag(TagData tag) {
    showDialog(
      context: context,
      builder: (context) => TagDialog(
        tag: tag,
        onSave: (updatedTag) {
          setState(() {
            final index = _tags.indexWhere((t) => t.id == tag.id);
            if (index != -1) {
              _tags[index] = updatedTag;
            }
          });
        },
      ),
    );
  }

  void _deleteTag(TagData tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除标签"${tag.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tags.removeWhere((t) => t.id == tag.id);
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
        title: const Text('标签管理'),
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '常用标签',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _buildTagGrid(),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '标签消费',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _buildTagUsageList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTag,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTagGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _tags.length,
      itemBuilder: (context, index) {
        final tag = _tags[index];
        return _buildTagChip(tag);
      },
    );
  }

  Widget _buildTagChip(TagData tag) {
    return InkWell(
      onTap: _isEditing ? () => _editTag(tag) : null,
      child: Container(
        decoration: BoxDecoration(
          color: tag.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: tag.color.withOpacity(0.5),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                tag.name,
                style: TextStyle(color: tag.color),
              ),
            ),
            if (_isEditing)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.red,
                  onPressed: () => _deleteTag(tag),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagUsageList() {
    final sortedTags = List<TagData>.from(_tags)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedTags.length,
      itemBuilder: (context, index) {
        final tag = sortedTags[index];
        return _buildTagUsageItem(tag);
      },
    );
  }

  Widget _buildTagUsageItem(TagData tag) {
    final maxUsage = _tags.map((t) => t.usageCount).reduce(max);
    final progress = tag.usageCount / maxUsage;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tag.name),
              Text('${tag.usageCount}笔'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(tag.color),
          ),
        ],
      ),
    );
  }
}

class TagData {
  final String id;
  final String name;
  final Color color;
  final int usageCount;

  TagData({
    required this.id,
    required this.name,
    required this.color,
    required this.usageCount,
  });

  TagData copyWith({
    String? id,
    String? name,
    Color? color,
    int? usageCount,
  }) {
    return TagData(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}

class TagDialog extends StatefulWidget {
  final TagData? tag;
  final Function(TagData) onSave;

  const TagDialog({
    super.key,
    this.tag,
    required this.onSave,
  });

  @override
  State<TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late Color _selectedColor;

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
    if (widget.tag != null) {
      _nameController.text = widget.tag!.name;
      _selectedColor = widget.tag!.color;
    } else {
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
      title: Text(widget.tag == null ? '新建标签' : '编辑标签'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '标签名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入标签名称';
                }
                return null;
              },
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final tag = TagData(
                id: widget.tag?.id ?? DateTime.now().toString(),
                name: _nameController.text,
                color: _selectedColor,
                usageCount: widget.tag?.usageCount ?? 0,
              );
              widget.onSave(tag);
              Navigator.pop(context);
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
} 