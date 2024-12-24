import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:crypto/crypto.dart';

class KeyPair {
  final String publicKey;
  final String privateKey;

  KeyPair({
    required this.publicKey,
    required this.privateKey,
  });
}

class E2EEncryptionService {
  static const int KEY_SIZE = 2048;
  static const String ALGORITHM = "RSA/ECB/OAEPWithSHA-256AndMGF1Padding";
  
  // 生成密钥对
  Future<KeyPair> generateKeyPair() async {
    final secureRandom = SecureRandom('Fortuna')
      ..seed(KeyParameter(
        Uint8List.fromList(
          DateTime.now().millisecondsSinceEpoch.toString().codeUnits,
        ),
      ));

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), KEY_SIZE, 64),
        secureRandom,
      ));

    final pair = keyGen.generateKeyPair();
    final publicKey = (pair.publicKey as RSAPublicKey);
    final privateKey = (pair.privateKey as RSAPrivateKey);

    return KeyPair(
      publicKey: _encodeKey(publicKey),
      privateKey: _encodeKey(privateKey),
    );
  }

  // 加密数据
  Future<String> encrypt(String data, String publicKey) async {
    try {
      final encrypter = OAEPEncoding(RSAEngine())
        ..init(
          true,
          PublicKeyParameter<RSAPublicKey>(_parsePublicKey(publicKey)),
        );

      final dataBytes = utf8.encode(data);
      final encrypted = _processInBlocks(encrypter, dataBytes);
      
      return base64.encode(encrypted);
    } catch (e) {
      throw Exception('加密失败: $e');
    }
  }

  // 解密数据
  Future<String> decrypt(String encryptedData, String privateKey) async {
    try {
      final decrypter = OAEPEncoding(RSAEngine())
        ..init(
          false,
          PrivateKeyParameter<RSAPrivateKey>(_parsePrivateKey(privateKey)),
        );

      final dataBytes = base64.decode(encryptedData);
      final decrypted = _processInBlocks(decrypter, dataBytes);
      
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('解密失败: $e');
    }
  }

  // 签名数据
  Future<String> sign(String data, String privateKey) async {
    try {
      final signer = RSASigner(SHA256Digest(), '0609608648016503040201')
        ..init(
          true,
          PrivateKeyParameter<RSAPrivateKey>(_parsePrivateKey(privateKey)),
        );

      final dataBytes = utf8.encode(data);
      final signature = signer.generateSignature(dataBytes);
      
      return base64.encode(signature.bytes);
    } catch (e) {
      throw Exception('签名失败: $e');
    }
  }

  // 验证签名
  Future<bool> verify(
    String data,
    String signature,
    String publicKey,
  ) async {
    try {
      final verifier = RSASigner(SHA256Digest(), '0609608648016503040201')
        ..init(
          false,
          PublicKeyParameter<RSAPublicKey>(_parsePublicKey(publicKey)),
        );

      final dataBytes = utf8.encode(data);
      final signatureBytes = base64.decode(signature);
      
      return verifier.verifySignature(
        dataBytes,
        RSASignature(signatureBytes),
      );
    } catch (e) {
      throw Exception('验证签名失败: $e');
    }
  }

  // 生成会话密钥
  Future<String> generateSessionKey() async {
    final random = SecureRandom('Fortuna')
      ..seed(KeyParameter(
        Uint8List.fromList(
          DateTime.now().millisecondsSinceEpoch.toString().codeUnits,
        ),
      ));

    final sessionKey = random.nextBytes(32);
    return base64.encode(sessionKey);
  }

  // 使用会话密钥加密数据
  Future<String> encryptWithSessionKey(
    String data,
    String sessionKey,
  ) async {
    try {
      final keyBytes = base64.decode(sessionKey);
      final iv = _generateIV();
      
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          true,
          AEADParameters(
            KeyParameter(keyBytes),
            128,
            iv,
            Uint8List(0),
          ),
        );

      final dataBytes = utf8.encode(data);
      final encrypted = Uint8List(cipher.getOutputSize(dataBytes.length));
      
      final len = cipher.processBytes(
        dataBytes,
        0,
        dataBytes.length,
        encrypted,
        0,
      );
      cipher.doFinal(encrypted, len);

      final result = Uint8List(iv.length + encrypted.length);
      result.setAll(0, iv);
      result.setAll(iv.length, encrypted);
      
      return base64.encode(result);
    } catch (e) {
      throw Exception('使用会话密钥加密失败: $e');
    }
  }

  // 使用会话密钥解密数据
  Future<String> decryptWithSessionKey(
    String encryptedData,
    String sessionKey,
  ) async {
    try {
      final keyBytes = base64.decode(sessionKey);
      final dataBytes = base64.decode(encryptedData);
      
      final iv = dataBytes.sublist(0, 12);
      final encrypted = dataBytes.sublist(12);

      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          false,
          AEADParameters(
            KeyParameter(keyBytes),
            128,
            iv,
            Uint8List(0),
          ),
        );

      final decrypted = Uint8List(cipher.getOutputSize(encrypted.length));
      
      final len = cipher.processBytes(
        encrypted,
        0,
        encrypted.length,
        decrypted,
        0,
      );
      cipher.doFinal(decrypted, len);
      
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('使用会话密钥解密失败: $e');
    }
  }

  // 生成密钥指纹
  Future<String> generateKeyFingerprint(String publicKey) async {
    final keyBytes = base64.decode(publicKey);
    final digest = sha256.convert(keyBytes);
    return digest.toString();
  }

  // 验证密钥指纹
  Future<bool> verifyKeyFingerprint(
    String publicKey,
    String fingerprint,
  ) async {
    final calculatedFingerprint = await generateKeyFingerprint(publicKey);
    return calculatedFingerprint == fingerprint;
  }

  // 编码密钥
  String _encodeKey(dynamic key) {
    if (key is RSAPublicKey) {
      return base64.encode(
        _bigIntToBytes(key.modulus!) +
        _bigIntToBytes(key.exponent!),
      );
    } else if (key is RSAPrivateKey) {
      return base64.encode(
        _bigIntToBytes(key.modulus!) +
        _bigIntToBytes(key.privateExponent!),
      );
    } else {
      throw Exception('不支持的密钥类型');
    }
  }

  // 解析公钥
  RSAPublicKey _parsePublicKey(String encoded) {
    final bytes = base64.decode(encoded);
    final modBytes = bytes.sublist(0, bytes.length ~/ 2);
    final expBytes = bytes.sublist(bytes.length ~/ 2);
    
    return RSAPublicKey(
      _bytesToBigInt(modBytes),
      _bytesToBigInt(expBytes),
    );
  }

  // 解析私钥
  RSAPrivateKey _parsePrivateKey(String encoded) {
    final bytes = base64.decode(encoded);
    final modBytes = bytes.sublist(0, bytes.length ~/ 2);
    final privExpBytes = bytes.sublist(bytes.length ~/ 2);
    
    return RSAPrivateKey(
      _bytesToBigInt(modBytes),
      _bytesToBigInt(privExpBytes),
      null,
      null,
    );
  }

  // BigInt转字节数组
  Uint8List _bigIntToBytes(BigInt big) {
    final data = big.toRadixString(16);
    return Uint8List.fromList(
      List<int>.generate(
        data.length ~/ 2,
        (i) => int.parse(data.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
  }

  // 字节数组转BigInt
  BigInt _bytesToBigInt(List<int> bytes) {
    final data = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return BigInt.parse(data, radix: 16);
  }

  // 生成初始化向量
  Uint8List _generateIV() {
    final random = SecureRandom('Fortuna')
      ..seed(KeyParameter(
        Uint8List.fromList(
          DateTime.now().millisecondsSinceEpoch.toString().codeUnits,
        ),
      ));
    return random.nextBytes(12);
  }

  // 分块处理数据
  Uint8List _processInBlocks(
    AsymmetricBlockCipher cipher,
    Uint8List input,
  ) {
    final numBlocks = (input.length + cipher.inputBlockSize - 1) ~/ cipher.inputBlockSize;
    final output = Uint8List(numBlocks * cipher.outputBlockSize);
    var inputOffset = 0;
    var outputOffset = 0;

    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + cipher.inputBlockSize <= input.length)
          ? cipher.inputBlockSize
          : input.length - inputOffset;

      final inputChunk = input.sublist(inputOffset, inputOffset + chunkSize);
      final outputChunk = cipher.process(inputChunk);
      
      output.setRange(
        outputOffset,
        outputOffset + outputChunk.length,
        outputChunk,
      );
      
      inputOffset += chunkSize;
      outputOffset += outputChunk.length;
    }

    return output.sublist(0, outputOffset);
  }
} 