import 'package:flutter/material.dart';
import '../models/category_tree.dart';

class CategoryTreeView extends StatelessWidget {
  final CategoryTreeNode root;
  final Function(String) onCategorySelected;
  final String? selectedCategoryId;

  const CategoryTreeView({
    Key? key,
    required this.root,
    required this.onCategorySelected,
    this.selectedCategoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildTreeView(root),
    );
  }

  Widget _buildTreeView(CategoryTreeNode node) {
    if (node.id == 'root') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: node.children.map((child) => _buildTreeView(child)).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onCategorySelected(node.id),
          child: Container(
            padding: EdgeInsets.only(left: 16.0 * node.level),
            height: 48.0,
            child: Row(
              children: [
                if (node.children.isNotEmpty)
                  Icon(
                    Icons.arrow_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                const SizedBox(width: 8),
                Text(
                  node.name,
                  style: TextStyle(
                    color: selectedCategoryId == node.id
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    fontWeight: selectedCategoryId == node.id
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...node.children.map((child) => _buildTreeView(child)).toList(),
      ],
    );
  }
} 