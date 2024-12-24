import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_merge_split_service.dart';

class CategoryMergeSplitPanel extends StatefulWidget {
  final List<Category> categories;
  final CategoryMergeSplitService mergeSplitService;

  const CategoryMergeSplitPanel({
    Key? key,
    required this.categories,
    required this.mergeSplitService,
  }) : super(key: key);

  @override
  State<CategoryMergeSplitPanel> createState() => _CategoryMergeSplitPanelState();
}

class _CategoryMergeSplitPanelState extends State<CategoryMergeSplitPanel> {
  final List<String> _selectedCategories = [];
  String? _targetCategoryId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMergeSection(),
        const Divider(),
        _buildSplitSection(),
      ],
    );
  }

  Widget _buildMergeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('合并分类', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildCategorySelectionList(),
        const SizedBox(height: 16),
        _buildTargetCategoryDropdown(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _canMerge() ? _handleMerge : null,
          child: const Text('合并所选分类'),
        ),
      ],
    );
  }

  Widget _buildSplitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('拆分分类', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSourceCategoryDropdown(),
        const SizedBox(height: 16),
        _buildNewCategoriesInput(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _canSplit() ? _handleSplit : null,
          child: const Text('拆分分类'),
        ),
      ],
    );
  }

  Widget _buildCategorySelectionList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        return CheckboxListTile(
          title: Text(category.name),
          value: _selectedCategories.contains(category.id),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedCategories.add(category.id);
              } else {
                _selectedCategories.remove(category.id);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildTargetCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _targetCategoryId,
      decoration: const InputDecoration(
        labelText: '目标分类',
        hintText: '请选择合并到的目标分类',
      ),
      items: widget.categories
          .where((c) => !_selectedCategories.contains(c.id))
          .map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _targetCategoryId = value;
        });
      },
    );
  }

  Widget _buildSourceCategoryDropdown() {
    // 实现源分类选择下拉框
    return Container();
  }

  Widget _buildNewCategoriesInput() {
    // 实现新分类输入界面
    return Container();
  }

  bool _canMerge() {
    return _selectedCategories.length >= 2 && _targetCategoryId != null;
  }

  bool _canSplit() {
    // 实现拆分验证逻辑
    return false;
  }

  Future<void> _handleMerge() async {
    try {
      await widget.mergeSplitService.mergeCategories(
        _targetCategoryId!,
        _selectedCategories,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('分类合并成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分类合并失败: $e')),
      );
    }
  }

  Future<void> _handleSplit() async {
    // 实现拆分处理逻辑
  }
} 