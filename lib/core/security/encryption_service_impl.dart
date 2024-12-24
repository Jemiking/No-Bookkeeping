import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import './encryption_service.dart';

/// 加密服务实现类
class EncryptionServiceImpl implements EncryptionService {
  static const int _keyLength = 32; // 256位密钥
  static const int _ivLength = 16; // 128位IV
  static const int _saltLength = 16; // 128位盐值
  static const int _iterations = 100000; // PBKDF2迭代次数

  @override
  Future<Uint8List> encrypt(Uint8List data, String password) async {
    try {
      // 生成随机盐值
      final salt = _generateRandomBytes(_saltLength);
      
      // 使用PBKDF2从密码生成密钥
      final keyData = await _deriveKey(password, salt);
      final key = Key(keyData.sublist(0, _keyLength));
      final iv = IV(keyData.sublist(_keyLength, _keyLength + _ivLength));

      // 创建加密器
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

      // 加密数据
      final encrypted = encrypter.encryptBytes(data, iv: iv);

      // 组合盐值和加密数据
      final result = Uint8List(salt.length + encrypted.bytes.length);
      result.setAll(0, salt);
      result.setAll(salt.length, encrypted.bytes);

      return result;
    } catch (e) {
      throw Exception('加密失败：$e');
    }
  }

  @override
  Future<Uint8List> decrypt(Uint8List data, String password) async {
    try {
      if (data.length < _saltLength) {
        throw Exception('数据格式无效');
      }

      // 提取盐值
      final salt = data.sublist(0, _saltLength);
      final encryptedData = data.sublist(_saltLength);

      // 使用PBKDF2从密码生成密钥
      final keyData = await _deriveKey(password, salt);
      final key = Key(keyData.sublist(0, _keyLength));
      final iv = IV(keyData.sublist(_keyLength, _keyLength + _ivLength));

      // 创建解密器
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

      // 解密数据
      final decrypted = encrypter.decryptBytes(
        Encrypted(encryptedData),
        iv: iv,
      );

      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw Exception('解密失败：$e');
    }
  }

  @override
  Future<String> generateKey() async {
    try {
      final random = Random.secure();
      final values = List<int>.generate(_keyLength, (i) => random.nextInt(256));
      return base64Url.encode(values);
    } catch (e) {
      throw Exception('生成密钥失败：$e');
    }
  }

  @override
  Future<bool> validatePassword(String password, String hash) async {
    try {
      final parts = hash.split('.');
      if (parts.length != 3) {
        return false;
      }

      final salt = base64Decode(parts[0]);
      final iterations = int.parse(parts[1]);
      final expectedHash = parts[2];

      final computedHash = await _hashPasswordWithSalt(
        password,
        salt,
        iterations,
      );

      return computedHash == expectedHash;
    } catch (e) {
      throw Exception('验证密码失败：$e');
    }
  }

  @override
  Future<String> hashPassword(String password) async {
    try {
      final salt = _generateRandomBytes(_saltLength);
      final hash = await _hashPasswordWithSalt(
        password,
        salt,
        _iterations,
      );

      return '${base64Encode(salt)}.$_iterations.$hash';
    } catch (e) {
      throw Exception('哈希密码失败：$e');
    }
  }

  // 私有辅助方法

  /// 生成随机字节
  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (i) => random.nextInt(256)),
    );
  }

  /// 使用PBKDF2从密码派生密钥
  Future<Uint8List> _deriveKey(String password, Uint8List salt) async {
    final passwordBytes = utf8.encode(password);
    final result = Uint8List(_keyLength + _ivLength);
    
    var hmac = Hmac(sha256, passwordBytes);
    var currentBlock = Uint8List(0);
    var blockIndex = 1;
    var offset = 0;

    while (offset < result.length) {
      // 计算当前块
      var block = Uint8List.fromList([
        ...salt,
        ...blockIndex.toRadixString(16).padLeft(8, '0').codeUnits,
      ]);

      for (var i = 0; i < _iterations; i++) {
        block = Uint8List.fromList(hmac.convert(block).bytes);
        for (var j = 0; j < currentBlock.length; j++) {
          block[j] ^= currentBlock[j];
        }
        currentBlock = block;
      }

      // 复制到结果中
      final remaining = result.length - offset;
      final toCopy = remaining > currentBlock.length ? currentBlock.length : remaining;
      result.setRange(offset, offset + toCopy, currentBlock);

      offset += currentBlock.length;
      blockIndex++;
    }

    return result;
  }

  /// 使用指定的盐值和迭代次数哈希密码
  Future<String> _hashPasswordWithSalt(
    String password,
    Uint8List salt,
    int iterations,
  ) async {
    final passwordBytes = utf8.encode(password);
    var key = Uint8List.fromList(passwordBytes);

    for (var i = 0; i < iterations; i++) {
      key = Uint8List.fromList(sha256.convert([...salt, ...key]).bytes);
    }

    return base64Encode(key);
  }
} 