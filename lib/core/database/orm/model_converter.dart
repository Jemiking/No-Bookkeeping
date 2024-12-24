import 'dart:convert';

/// 模型转换器基类
abstract class ModelConverter<T> {
  /// 从Map创建实体对象
  T fromMap(Map<String, dynamic> map);

  /// 将实体对象转换为Map
  Map<String, dynamic> toMap(T entity);

  /// 从JSON字符串创建实体对象
  T fromJson(String json) {
    return fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  /// 将实体对象转换为JSON字符串
  String toJson(T entity) {
    return jsonEncode(toMap(entity));
  }

  /// 从Map列表创建实体对象列表
  List<T> fromMapList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => fromMap(map)).toList();
  }

  /// 将实体对象列表转换为Map列表
  List<Map<String, dynamic>> toMapList(List<T> entities) {
    return entities.map((entity) => toMap(entity)).toList();
  }

  /// 从JSON字符串列表创建实体对象列表
  List<T> fromJsonList(List<String> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }

  /// 将实体对象列表转换为JSON字符串列表
  List<String> toJsonList(List<T> entities) {
    return entities.map((entity) => toJson(entity)).toList();
  }

  /// 从JSON数组字符串创建实体对象列表
  List<T> fromJsonArray(String jsonArray) {
    final List<dynamic> decoded = jsonDecode(jsonArray);
    return decoded
        .cast<Map<String, dynamic>>()
        .map((map) => fromMap(map))
        .toList();
  }

  /// 将实体对象列表转换为JSON数组字符串
  String toJsonArray(List<T> entities) {
    final maps = entities.map((entity) => toMap(entity)).toList();
    return jsonEncode(maps);
  }

  /// 验证Map是否包含所有必需的字段
  bool validateMap(Map<String, dynamic> map, List<String> requiredFields) {
    return requiredFields.every((field) => map.containsKey(field));
  }

  /// 验证JSON字符串是否有效
  bool isValidJson(String json) {
    try {
      jsonDecode(json);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 合并两个实体对象
  T merge(T entity1, T entity2) {
    final map1 = toMap(entity1);
    final map2 = toMap(entity2);
    return fromMap({...map1, ...map2});
  }

  /// 复制实体对象
  T copy(T entity) {
    return fromMap(Map<String, dynamic>.from(toMap(entity)));
  }

  /// 比较两个实体对象是否相等
  bool equals(T entity1, T entity2) {
    return toJson(entity1) == toJson(entity2);
  }

  /// 获取实体对象的差异字段
  Map<String, dynamic> diff(T entity1, T entity2) {
    final map1 = toMap(entity1);
    final map2 = toMap(entity2);
    final result = <String, dynamic>{};

    map1.forEach((key, value1) {
      final value2 = map2[key];
      if (value1 != value2) {
        result[key] = {
          'old': value1,
          'new': value2,
        };
      }
    });

    return result;
  }
} 