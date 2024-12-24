import '../models/tag.dart';

abstract class TagService {
  // 基础CRUD操作
  Future<String> createTag(Tag tag);
  Future<Tag> getTag(String id);
  Future<List<Tag>> getTags({String? searchQuery});
  Future<void> updateTag(Tag tag);
  Future<void> deleteTag(String id);
  
  // 批量操作
  Future<void> batchCreateTags(List<Tag> tags);
  Future<void> batchUpdateTags(List<Tag> tags);
  Future<void> batchDeleteTags(List<String> ids);
  
  // 标签关联
  Future<void> addTagsToTransaction(String transactionId, List<String> tagIds);
  Future<void> removeTagsFromTransaction(String transactionId, List<String> tagIds);
  Future<List<Tag>> getTagsByTransaction(String transactionId);
  Future<List<String>> getTransactionsByTag(String tagId);
  
  // 标签统计
  Future<Map<String, int>> getTagUsageCount();
  Future<Map<String, double>> getTagTotalAmount({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  // 系统标签
  Future<List<Tag>> getSystemTags();
  Future<void> initializeSystemTags();
} 