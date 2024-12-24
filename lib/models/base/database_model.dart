/// 基础模型接口
abstract class DatabaseModel {
  Map<String, dynamic> toMap();
  String get tableName;
} 