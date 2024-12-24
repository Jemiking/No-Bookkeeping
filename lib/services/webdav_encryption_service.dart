import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionKeys {
  final Key key;
  final IV iv;

  EncryptionKeys({
    required this.key,
    required this.iv,
  });
}

class WebDAVEncryptionService {
  static const String _keyStorageKey = 'webdav_encryption_key';
  static const String _ivStorageKey = 'webdav_encryption_iv';
  
  final FlutterSecureStorage _secureStorage;
  late Encrypter _encrypter;
  late IV _iv;

  WebDAVEncryptionService() : _secureStorage = const FlutterSecureStorage();

  // 初始化加密服务
  Future<void> initialize() async {
    final keys = await _getOrGenerateKeys();
    _encrypter = Encrypter(AES(keys.key));
    _iv = keys.iv;
  }

  // 加密数据
  Future<Uint8List> encryptData(Uint8List data) async {
    final encrypted = _encrypter.encryptBytes(data, iv: _iv);
    return encrypted.bytes;
  }

  // 解密数据
  Future<Uint8List> decryptData(Uint8List encryptedData) async {
    final encrypted = Encrypted(encryptedData);
    final decrypted = _encrypter.decryptBytes(encrypted, iv: _iv);
    return Uint8List.fromList(decrypted);
  }

  // 加密文本
  Future<String> encryptText(String text) async {
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  // 解密文本
  Future<String> decryptText(String encryptedText) async {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  // 生成文件密钥
  Future<String> generateFileKey(String filePath) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$filePath:$timestamp';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return base64Encode(hash.bytes);
  }

  // 获取或生成加密密钥
  Future<EncryptionKeys> _getOrGenerateKeys() async {
    // 尝试从安全存储中获取现有密钥
    String? storedKey = await _secureStorage.read(key: _keyStorageKey);
    String? storedIV = await _secureStorage.read(key: _ivStorageKey);

    if (storedKey != null && storedIV != null) {
      return EncryptionKeys(
        key: Key(base64Decode(storedKey)),
        iv: IV(base64Decode(storedIV)),
      );
    }

    // 生成新的密钥
    final key = Key.fromSecureRandom(32); // 256 bits
    final iv = IV.fromSecureRandom(16); // 128 bits

    // 保存密钥到安全存储
    await _secureStorage.write(
      key: _keyStorageKey,
      value: base64Encode(key.bytes),
    );
    await _secureStorage.write(
      key: _ivStorageKey,
      value: base64Encode(iv.bytes),
    );

    return EncryptionKeys(key: key, iv: iv);
  }

  // 更新加密密钥
  Future<void> rotateKeys() async {
    final newKeys = await _generateNewKeys();
    await _saveKeys(newKeys);
    _encrypter = Encrypter(AES(newKeys.key));
    _iv = newKeys.iv;
  }

  // 生成新的密钥对
  Future<EncryptionKeys> _generateNewKeys() async {
    final key = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);
    return EncryptionKeys(key: key, iv: iv);
  }

  // 保存密钥对
  Future<void> _saveKeys(EncryptionKeys keys) async {
    await _secureStorage.write(
      key: _keyStorageKey,
      value: base64Encode(keys.key.bytes),
    );
    await _secureStorage.write(
      key: _ivStorageKey,
      value: base64Encode(keys.iv.bytes),
    );
  }

  // 验证加密数据完整性
  Future<bool> verifyDataIntegrity(Uint8List data, Uint8List encryptedData) async {
    try {
      final decrypted = await decryptData(encryptedData);
      return _compareBytes(data, decrypted);
    } catch (e) {
      return false;
    }
  }

  // 比较两个字节数组
  bool _compareBytes(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // 生成加密元数据
  Map<String, String> generateEncryptionMetadata(String fileKey) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final version = '1.0'; // 加密版本
    
    return {
      'encrypted': 'true',
      'encryption_version': version,
      'encryption_timestamp': timestamp,
      'file_key': fileKey,
    };
  }

  // 验证加密元数据
  bool validateEncryptionMetadata(Map<String, String> metadata) {
    return metadata.containsKey('encrypted') &&
           metadata.containsKey('encryption_version') &&
           metadata.containsKey('encryption_timestamp') &&
           metadata.containsKey('file_key');
  }

  // 清理加密密钥
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _ivStorageKey);
  }
} 