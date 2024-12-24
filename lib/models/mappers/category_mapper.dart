import '../domain/category.dart';
import '../entities/category.dart';

/// 分类模型映射器
class CategoryMapper {
  /// 将实体模型转换为业务模型
  static Category fromEntity(CategoryEntity entity) {
    return Category(
      id: entity.id?.toString(),
      name: entity.name,
      type: entity.type,
      createdAt: entity.createdAt != null 
          ? DateTime.parse(entity.createdAt!)
          : null,
      updatedAt: entity.updatedAt != null
          ? DateTime.parse(entity.updatedAt!)
          : null,
    );
  }

  /// 将业务模型转换为实体模型
  static CategoryEntity toEntity(Category model) {
    return CategoryEntity(
      id: model.id != null ? int.parse(model.id!) : null,
      name: model.name,
      type: model.type,
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt.toIso8601String(),
    );
  }

  /// 将实体模型列表转换为业务模型列表
  static List<Category> fromEntityList(List<CategoryEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }

  /// 将业务模型列表转换为实体模型列表
  static List<CategoryEntity> toEntityList(List<Category> models) {
    return models.map((model) => toEntity(model)).toList();
  }
} 