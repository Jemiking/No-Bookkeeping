import '../models/category.dart';
import '../models/category_tree.dart';

class CategoryTreeService {
  // 构建分类树
  CategoryTreeNode buildCategoryTree(List<Category> categories) {
    // 创建根节点
    final root = CategoryTreeNode(
      id: 'root',
      name: 'Root',
      level: 0,
      path: '/root',
    );

    // 按父子关系组织分类
    final Map<String?, List<Category>> categoryMap = {};
    for (var category in categories) {
      final parentId = category.parentId;
      categoryMap[parentId] = [...(categoryMap[parentId] ?? []), category];
    }

    // 递归构建树
    _buildTreeRecursive(root, null, categoryMap, 1, '/root');

    return root;
  }

  // 递归构建树
  void _buildTreeRecursive(
    CategoryTreeNode parent,
    String? parentId,
    Map<String?, List<Category>> categoryMap,
    int level,
    String path,
  ) {
    final children = categoryMap[parentId] ?? [];
    for (var category in children) {
      final node = CategoryTreeNode(
        id: category.id,
        name: category.name,
        level: level,
        path: '$path/${category.id}',
      );
      parent.children.add(node);
      _buildTreeRecursive(node, category.id, categoryMap, level + 1, node.path);
    }
  }

  // 验证分类层级关系
  bool validateHierarchy(String? parentId, String childId, CategoryTreeNode root) {
    // 检查是否形成循环
    if (parentId == childId) return false;
    if (parentId == null) return true;

    final parentNode = root.findNode(parentId);
    if (parentNode == null) return false;

    // 检查是否会形成循环引用
    return !parentNode.hasChild(childId);
  }

  // 获取分类的完整路径
  List<Category> getCategoryPath(String categoryId, List<Category> allCategories) {
    final List<Category> path = [];
    String? currentId = categoryId;

    while (currentId != null) {
      final category = allCategories.firstWhere(
        (c) => c.id == currentId,
        orElse: () => throw Exception('Category not found'),
      );
      path.insert(0, category);
      currentId = category.parentId;
    }

    return path;
  }

  // 获取子分类
  List<Category> getChildCategories(String categoryId, List<Category> allCategories) {
    return allCategories.where((c) => c.parentId == categoryId).toList();
  }

  // 获取所有后代分类
  List<Category> getDescendantCategories(String categoryId, List<Category> allCategories) {
    final List<Category> descendants = [];
    final queue = getChildCategories(categoryId, allCategories);

    while (queue.isNotEmpty) {
      final category = queue.removeAt(0);
      descendants.add(category);
      queue.addAll(getChildCategories(category.id, allCategories));
    }

    return descendants;
  }
} 