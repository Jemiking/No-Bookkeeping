class CategoryTreeNode {
  final String id;
  final String name;
  final List<CategoryTreeNode> children;
  final int level;
  final String path;

  CategoryTreeNode({
    required this.id,
    required this.name,
    this.children = const [],
    required this.level,
    required this.path,
  });

  CategoryTreeNode addChild(CategoryTreeNode child) {
    return CategoryTreeNode(
      id: id,
      name: name,
      children: [...children, child],
      level: level,
      path: path,
    );
  }

  bool hasChild(String childId) {
    return children.any((child) => child.id == childId || child.hasChild(childId));
  }

  CategoryTreeNode? findNode(String nodeId) {
    if (id == nodeId) return this;
    for (var child in children) {
      final found = child.findNode(nodeId);
      if (found != null) return found;
    }
    return null;
  }
} 