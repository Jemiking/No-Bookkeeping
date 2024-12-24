import 'encryption_service.dart';

/// 加密管理器类，负责管理加密服务的生命周期和配置
class EncryptionManager {
  static EncryptionManager? _instance;
  late final EncryptionService _encryptionService;
  
  // 私有构造函数
  EncryptionManager._();
  
  /// 获取单例实例
  static EncryptionManager get instance {
    _instance ??= EncryptionManager._();
    return _instance!;
  }

  /// 初始化加密管理器
  Future<void> initialize(String secretKey) async {
    _encryptionService = EncryptionService.initialize(secretKey);
  }

  /// 获取加密服务实例
  EncryptionService get service {
    if (_encryptionService == null) {
      throw StateError('EncryptionManager not initialized');
    }
    return _encryptionService;
  }

  /// 重置加密服务
  Future<void> reset(String newSecretKey) async {
    _encryptionService = EncryptionService.initialize(newSecretKey);
  }

  /// 生成新的安全密钥
  String generateNewKey() {
    return EncryptionService.generateSecureKey();
  }

  /// 加密敏感数据
  String encryptSensitiveData(String data) {
    return service.encryptString(data);
  }

  /// 解密敏感数据
  String decryptSensitiveData(String encryptedData) {
    return service.decryptString(encryptedData);
  }

  /// 加密文件数据
  Future<List<int>> encryptFile(List<int> fileData) async {
    final bytes = Uint8List.fromList(fileData);
    return service.encryptBytes(bytes).toList();
  }

  /// 解密文件数据
  Future<List<int>> decryptFile(List<int> encryptedData) async {
    final bytes = Uint8List.fromList(encryptedData);
    return service.decryptBytes(bytes).toList();
  }

  /// 生成数据哈希
  String hashData(String data) {
    return service.generateHash(data);
  }

  /// 验证数据哈希
  bool verifyDataHash(String data, String hash) {
    return service.verifyHash(data, hash);
  }
} 