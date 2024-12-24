import '../../services/database_service.dart';

class ServiceProvider {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> initialize() async {
    // 初始化数据库
    await _databaseService.database;
  }
} 