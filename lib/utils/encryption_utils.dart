import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// 加密工具类
class EncryptionUtils {
  /// 生成密钥
  static String generateKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// 生成盐值
  static String generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// 使用AES加密数据
  static List<int> encryptAES(List<int> data, String key) {
    final keyBytes = _deriveKey(key);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(Key(keyBytes)));
    
    final encrypted = encrypter.encryptBytes(data, iv: iv);
    return iv.bytes + encrypted.bytes;
  }

  /// 使用AES解密数据
  static List<int> decryptAES(List<int> data, String key) {
    if (data.length < 16) {
      throw Exception('数据长度不足');
    }

    final keyBytes = _deriveKey(key);
    final iv = IV(Uint8List.fromList(data.take(16).toList()));
    final encrypter = Encrypter(AES(Key(keyBytes)));
    
    final encryptedData = Encrypted(Uint8List.fromList(data.skip(16).toList()));
    return encrypter.decryptBytes(encryptedData, iv: iv);
  }

  /// 使用PBKDF2派生密钥
  static Uint8List _deriveKey(String password, {String? salt, int iterations = 10000}) {
    final saltBytes = salt != null ? base64Url.decode(salt) : generateSalt();
    final codec = utf8.encoder;
    final key = pbkdf2(
      codec.convert(password),
      saltBytes,
      iterations,
      32, // AES-256需要32字节密钥
      (data) => Hmac(sha256, data).convert(data).bytes,
    );
    return key;
  }

  /// PBKDF2密钥派生函数
  static Uint8List pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLength,
    List<int> Function(List<int> data) prf,
  ) {
    if (keyLength > (pow(2, 32) - 1) * 32) {
      throw Exception('派生密钥长度过长');
    }

    final numberOfBlocks = (keyLength + 31) ~/ 32;
    final result = Uint8List(keyLength);
    var offset = 0;

    for (var i = 1; i <= numberOfBlocks; i++) {
      // 计算每个块
      final block = _calculateBlock(password, salt, iterations, i, prf);
      
      // 复制到结果中
      final remainingBytes = keyLength - offset;
      if (remainingBytes > 32) {
        result.setRange(offset, offset + 32, block);
        offset += 32;
      } else {
        result.setRange(offset, offset + remainingBytes, block);
        offset += remainingBytes;
      }
    }

    return result;
  }

  /// 计算PBKDF2的单个块
  static List<int> _calculateBlock(
    List<int> password,
    List<int> salt,
    int iterations,
    int blockNumber,
    List<int> Function(List<int> data) prf,
  ) {
    final block = Uint8List(32);
    
    // 初始化块
    final initialBlock = List<int>.from(salt)
      ..addAll(_intToBytes(blockNumber));
    var lastBlock = prf(initialBlock);
    for (var i = 0; i < 32; i++) {
      block[i] = lastBlock[i];
    }

    // 迭代
    for (var i = 1; i < iterations; i++) {
      lastBlock = prf(lastBlock);
      for (var j = 0; j < 32; j++) {
        block[j] ^= lastBlock[j];
      }
    }

    return block;
  }

  /// 将整数转换为字节数组
  static List<int> _intToBytes(int value) {
    final result = Uint8List(4);
    result[0] = (value >> 24) & 0xFF;
    result[1] = (value >> 16) & 0xFF;
    result[2] = (value >> 8) & 0xFF;
    result[3] = value & 0xFF;
    return result;
  }

  /// 计算数据的SHA-256哈希值
  static String calculateHash(List<int> data) {
    return sha256.convert(data).toString();
  }

  /// 验证数据完整性
  static bool verifyIntegrity(List<int> data, String expectedHash) {
    final actualHash = calculateHash(data);
    return actualHash == expectedHash;
  }
} 