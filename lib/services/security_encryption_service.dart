import 'dart:async';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityEncryptionService {
  final _storage = const FlutterSecureStorage();
  late final Key _key;
  late final IV _iv;

  SecurityEncryptionService() {
    _initializeEncryption();
  }

  Future<void> _initializeEncryption() async {
    // 从安全存储中获取或生成密钥
    String? storedKey = await _storage.read(key: 'encryption_key');
    if (storedKey == null) {
      final key = Key.fromSecureRandom(32);
      await _storage.write(key: 'encryption_key', value: base64.encode(key.bytes));
      _key = key;
    } else {
      _key = Key(base64.decode(storedKey));
    }

    // 从安全存储中获取或生成IV
    String? storedIV = await _storage.read(key: 'encryption_iv');
    if (storedIV == null) {
      final iv = IV.fromSecureRandom(16);
      await _storage.write(key: 'encryption_iv', value: base64.encode(iv.bytes));
      _iv = iv;
    } else {
      _iv = IV(base64.decode(storedIV));
    }
  }

  Future<String> encrypt(String data) async {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  Future<String> decrypt(String encryptedData) async {
    final encrypter = Encrypter(AES(_key));
    final decrypted = encrypter.decrypt64(encryptedData, iv: _iv);
    return decrypted;
  }

  Future<String> generateKey() async {
    final key = Key.fromSecureRandom(32);
    return base64.encode(key.bytes);
  }

  Future<bool> storeKey(String key) async {
    try {
      await _storage.write(key: 'user_key', value: key);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> retrieveKey() async {
    return await _storage.read(key: 'user_key');
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> verifyPassword(String password, String hashedPassword) async {
    final hash = hashPassword(password);
    return hash == hashedPassword;
  }

  Future<void> clearKeys() async {
    await _storage.deleteAll();
  }
} 