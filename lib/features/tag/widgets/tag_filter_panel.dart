import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../services/tag_filter_service.dart';

class TagFilterPanel extends StatefulWidget {
  final List<Tag> availableTags;
  final Function(List<String>) onFilter;
  final TagFilterService filterService;

  const TagFilterPanel({
    Key? key,
    required this.availableTags,
    required this.onFilter,
    required this.filterService,
  }) : super(key: key);

  @override
  State<TagFilterPanel> createState() => _TagFilterPanelState();
}

class _TagFilterPanelState extends State<TagFilterPanel> {
  final List<String> _selectedTagIds = [];
  FilterMode _filterMode = FilterMode.and;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterModeSelector(),
        const SizedBox(height: 16),
        _buildTagSelector(),
        const SizedBox(height: 16),
        _buildSelectedTags(),
        const SizedBox(height: 16),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildFilterModeSelector() {
    return SegmentedButton<FilterMode>(
      segments: const [
        ButtonSegment(
          value: FilterMode.and,
          label: Text('包含所有'),
        ),
        ButtonSegment(
          value: FilterMode.or,
          label: Text('包含任一'),
        ),
      ],
      selected: {_filterMode},
      onSelectionChanged: (Set<FilterMode> modes) {
        setState(() {
          _filterMode = modes.first;
        });
      },
    );
  }

  Widget _buildTagSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.availableTags.map((tag) {
        final isSelected = _selectedTagIds.contains(tag.id);
        return FilterChip(
          label: Text(tag.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTagIds.add(tag.id);
              } else {
                _selectedTagIds.remove(tag.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSelectedTags() {
    if (_selectedTagIds.isEmpty) {
      return const Text('未选择任何标签');
    }

    final selectedTags = widget.availableTags
        .where((tag) => _selectedTagIds.contains(tag.id))
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedTags.map((tag) {
        return Chip(
          label: Text(tag.name),
          onDeleted: () {
            setState(() {
              _selectedTagIds.remove(tag.id);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildFilterButton() {
    return ElevatedButton(
      onPressed: _selectedTagIds.isEmpty ? null : _handleFilter,
      child: const Text('应用筛选'),
    );
  }

  void _handleFilter() {
    widget.onFilter(_selectedTagIds);
  }
} 