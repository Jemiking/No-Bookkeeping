import 'package:money_tracker/models/domain/category.dart';
import 'package:money_tracker/models/mappers/category_mapper.dart';
import 'package:money_tracker/services/database_service.dart';

class CategoryService {
  final DatabaseService _db;

  CategoryService(this._db);

  Future<List<Category>> getAllCategories() async {
    final entities = await _db.getAllCategories();
    return CategoryMapper.fromEntityList(entities);
  }

  Future<Category?> getCategory(String id) async {
    try {
      final entity = await _db.getCategory(int.parse(id));
      return entity != null ? CategoryMapper.fromEntity(entity) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> createCategory(Category category) async {
    await _db.insertCategory(CategoryMapper.toEntity(category));
  }

  Future<void> updateCategory(Category category) async {
    await _db.updateCategory(CategoryMapper.toEntity(category));
  }

  Future<void> deleteCategory(String id) async {
    await _db.deleteCategory(int.parse(id));
  }
} 