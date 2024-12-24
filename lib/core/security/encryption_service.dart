import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

/// 加密服务接口
abstract class EncryptionService {
  /// 加密数据
  Future<Uint8List> encrypt(Uint8List data, String password);

  /// 解密数据
  Future<Uint8List> decrypt(Uint8List data, String password);

  /// 生成密钥
  Future<String> generateKey();

  /// 验证密码
  Future<bool> validatePassword(String password, String hash);

  /// 哈希密码
  Future<String> hashPassword(String password);
}