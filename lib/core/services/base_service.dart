import '../models/base_model.dart';

/// Base service interface
abstract class BaseService<T extends BaseModel> {
  /// Get item by id
  Future<T?> getById(String id);

  /// Get all items
  Future<List<T>> getAll();

  /// Create new item
  Future<String> create(T item);

  /// Update existing item
  Future<bool> update(T item);

  /// Delete item by id
  Future<bool> delete(String id);

  /// Check if item exists
  Future<bool> exists(String id);

  /// Count total items
  Future<int> count();
} 