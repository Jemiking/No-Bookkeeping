import 'package:flutter/material.dart';
import '../../core/database/models/tag.dart';

/// 标签选择器组件
class TagSelector extends StatelessWidget {
  /// 标签列表
  final List<Tag> tags;

  /// 选中的标签列表
  final List<Tag> selectedTags;

  /// 标签选择回调
  final ValueChanged<List<Tag>> onTagsSelected;

  /// 是否显示图标
  final bool showIcon;

  /// 是否允许多选
  final bool allowMultiple;

  /// 最大选择数量
  final int? maxSelections;

  /// 构造函数
  const TagSelector({
    Key? key,
    required this.tags,
    required this.selectedTags,
    required this.onTagsSelected,
    this.showIcon = true,
    this.allowMultiple = true,
    this.maxSelections,
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
          if (selectedTags.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            _buildSelectedTags(context),
          ],
          const SizedBox(height: 16.0),
          _buildTagGrid(context),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          '选择标签',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        if (selectedTags.isNotEmpty)
          TextButton(
            onPressed: () {
              onTagsSelected(selectedTags);
            },
            child: const Text('确认'),
          ),
      ],
    );
  }

  /// 构建已选标签
  Widget _buildSelectedTags(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: selectedTags.map((tag) {
        return Chip(
          label: Text(tag.name),
          onDeleted: () {
            final newSelectedTags = List<Tag>.from(selectedTags)
              ..remove(tag);
            onTagsSelected(newSelectedTags);
          },
          deleteIcon: const Icon(
            Icons.close,
            size: 16.0,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          deleteIconColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  /// 构建标签网格
  Widget _buildTagGrid(BuildContext context) {
    final filteredTags = tags
        .where((tag) => !selectedTags.contains(tag))
        .toList();

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: filteredTags.map((tag) {
        return _buildTagCell(context, tag);
      }).toList(),
    );
  }

  /// 构建标签单元格
  Widget _buildTagCell(BuildContext context, Tag tag) {
    final isSelected = selectedTags.contains(tag);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSelected) {
            final newSelectedTags = List<Tag>.from(selectedTags)
              ..remove(tag);
            onTagsSelected(newSelectedTags);
          } else {
            if (!allowMultiple) {
              onTagsSelected([tag]);
            } else {
              if (maxSelections != null &&
                  selectedTags.length >= maxSelections!) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('最多只能选择 $maxSelections 个标签'),
                  ),
                );
                return;
              }
              final newSelectedTags = List<Tag>.from(selectedTags)
                ..add(tag);
              onTagsSelected(newSelectedTags);
            }
          }
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 6.0,
          ),
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
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon && tag.icon != null) ...[
                Icon(
                  IconData(
                    int.parse(tag.icon!),
                    fontFamily: 'MaterialIcons',
                  ),
                  size: 16.0,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 4.0),
              ],
              Text(
                tag.name,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 