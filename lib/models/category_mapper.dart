import 'category.dart';
import 'database_models.dart';

class CategoryMapper {
  static Category fromEntity(CategoryEntity entity) {
    try {
      return Category(
        id: entity.id?.toString(),
        name: entity.name,
        type: entity.type,
        createdAt: entity.createdAt != null ? _parseDate(entity.createdAt!) : null,
        updatedAt: entity.updatedAt != null ? _parseDate(entity.updatedAt!) : null,
      );
    } catch (e) {
      throw CategoryMapperException('Failed to map entity to category: $e');
    }
  }

  static CategoryEntity toEntity(Category category) {
    try {
      return CategoryEntity(
        id: category.id != null ? _parseInt(category.id!) : null,
        name: category.name,
        type: category.type,
        createdAt: category.createdAt.toIso8601String(),
        updatedAt: category.updatedAt.toIso8601String(),
      );
    } catch (e) {
      throw CategoryMapperException('Failed to map category to entity: $e');
    }
  }

  static List<Category> fromEntityList(List<CategoryEntity> entities) {
    try {
      return entities.map((entity) => fromEntity(entity)).toList();
    } catch (e) {
      throw CategoryMapperException('Failed to map entity list to categories: $e');
    }
  }

  static List<CategoryEntity> toEntityList(List<Category> categories) {
    try {
      return categories.map((category) => toEntity(category)).toList();
    } catch (e) {
      throw CategoryMapperException('Failed to map categories to entity list: $e');
    }
  }

  static DateTime _parseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      throw CategoryMapperException('Invalid date format: $date');
    }
  }

  static int _parseInt(String value) {
    try {
      return int.parse(value);
    } catch (e) {
      throw CategoryMapperException('Invalid integer format: $value');
    }
  }
}

class CategoryMapperException implements Exception {
  final String message;
  CategoryMapperException(this.message);
  
  @override
  String toString() => message;
} 