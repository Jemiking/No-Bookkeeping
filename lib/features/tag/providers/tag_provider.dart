import 'package:flutter/foundation.dart';
import '../models/tag.dart';
import '../services/tag_service.dart';

class TagProvider extends ChangeNotifier {
  final TagService _service;
  
  List<Tag> _tags = [];
  List<Tag> _systemTags = [];
  Map<String, int> _tagUsageCount = {};
  bool _isLoading = false;
  String? _error;
  
  TagProvider(this._service);
  
  // Getters
  List<Tag> get tags => _tags;
  List<Tag> get systemTags => _systemTags;
  Map<String, int> get tagUsageCount => _tagUsageCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 加载所有标签
  Future<void> loadTags({String? searchQuery}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _tags = await _service.getTags(searchQuery: searchQuery);
      await _updateTagUsageCount();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 加载系统标签
  Future<void> loadSystemTags() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _systemTags = await _service.getSystemTags();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 创建标签
  Future<void> createTag(Tag tag) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.createTag(tag);
      await loadTags();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 更新标签
  Future<void> updateTag(Tag tag) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.updateTag(tag);
      await loadTags();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 删除标签
  Future<void> deleteTag(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.deleteTag(id);
      await loadTags();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 批量操作
  Future<void> batchCreateTags(List<Tag> tags) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.batchCreateTags(tags);
      await loadTags();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> batchUpdateTags(List<Tag> tags) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.batchUpdateTags(tags);
      await loadTags();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> batchDeleteTags(List<String> ids) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.batchDeleteTags(ids);
      await loadTags();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 标签关联
  Future<void> addTagsToTransaction(String transactionId, List<String> tagIds) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.addTagsToTransaction(transactionId, tagIds);
      await _updateTagUsageCount();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> removeTagsFromTransaction(String transactionId, List<String> tagIds) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.removeTagsFromTransaction(transactionId, tagIds);
      await _updateTagUsageCount();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Tag>> getTagsByTransaction(String transactionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      return await _service.getTagsByTransaction(transactionId);
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 标签统计
  Future<void> _updateTagUsageCount() async {
    try {
      _tagUsageCount = await _service.getTagUsageCount();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<Map<String, double>> getTagTotalAmount({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      return await _service.getTagTotalAmount(
        startDate: startDate,
        endDate: endDate,
      );
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 系统标签初始化
  Future<void> initializeSystemTags() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.initializeSystemTags();
      await loadSystemTags();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 错误处理
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 