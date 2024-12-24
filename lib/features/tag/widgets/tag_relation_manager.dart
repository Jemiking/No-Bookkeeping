import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../services/tag_relation_service.dart';

class TagRelationManager extends StatefulWidget {
  final String entityId;
  final String entityType;
  final List<Tag> allTags;
  final List<Tag> selectedTags;
  final TagRelationService relationService;

  const TagRelationManager({
    Key? key,
    required this.entityId,
    required this.entityType,
    required this.allTags,
    required this.selectedTags,
    required this.relationService,
  }) : super(key: key);

  @override
  State<TagRelationManager> createState() => _TagRelationManagerState();
}

class _TagRelationManagerState extends State<TagRelationManager> {
  late List<Tag> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTagList(),
        const SizedBox(height: 16),
        _buildTagSelector(),
      ],
    );
  }

  Widget _buildTagList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedTags.map((tag) {
        return Chip(
          label: Text(tag.name),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () => _removeTag(tag),
        );
      }).toList(),
    );
  }

  Widget _buildTagSelector() {
    final availableTags = widget.allTags
        .where((tag) => !_selectedTags.contains(tag))
        .toList();

    return DropdownButton<Tag>(
      hint: const Text('添加标签'),
      items: availableTags.map((tag) {
        return DropdownMenuItem(
          value: tag,
          child: Text(tag.name),
        );
      }).toList(),
      onChanged: (tag) {
        if (tag != null) {
          _addTag(tag);
        }
      },
    );
  }

  Future<void> _addTag(Tag tag) async {
    try {
      await widget.relationService.addTagRelation(
        tag.id,
        widget.entityId,
        widget.entityType,
      );
      setState(() {
        _selectedTags.add(tag);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加标签失败: $e')),
      );
    }
  }

  Future<void> _removeTag(Tag tag) async {
    try {
      // 这里需要先获取关联ID
      // 实际应用中可能需要修改数据结构或服务接口
      await widget.relationService.removeTagRelation('relationId');
      setState(() {
        _selectedTags.remove(tag);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('移除标签失败: $e')),
      );
    }
  }
}