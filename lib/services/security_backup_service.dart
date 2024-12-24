import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:archive/archive.dart';
import '../models/backup_config.dart';
import '../utils/encryption_utils.dart';
import '../utils/validation_utils.dart';
import '../services/database_service.dart';

/// 备份状态
enum BackupStatus {
  idle,
  inProgress,
  completed,
  failed,
}

/// 备份配置
class BackupConfig {
  final String backupPath;
  final bool encryptBackup;
  final String? encryptionKey;
  final List<String> includedTables;
  final bool compressBackup;
  final Duration backupInterval;

  BackupConfig({
    required this.backupPath,
    this.encryptBackup = true,
    this.encryptionKey,
    this.includedTables = const ['accounts', 'transactions', 'categories', 'tags', 'budgets'],
    this.compressBackup = true,
    this.backupInterval = const Duration(days: 1),
  });
}

/// 备份元数据
class BackupMetadata {
  final String id;
  final DateTime timestamp;
  final int size;
  final String checksum;
  final Map<String, int> recordCounts;
  final bool isEncrypted;
  final bool isCompressed;

  BackupMetadata({
    required this.id,
    required this.timestamp,
    required this.size,
    required this.checksum,
    required this.recordCounts,
    required this.isEncrypted,
    required this.isCompressed,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'size': size,
    'checksum': checksum,
    'recordCounts': recordCounts,
    'isEncrypted': isEncrypted,
    'isCompressed': isCompressed,
  };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) => BackupMetadata(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    size: json['size'] as int,
    checksum: json['checksum'] as String,
    recordCounts: Map<String, int>.from(json['recordCounts'] as Map),
    isEncrypted: json['isEncrypted'] as bool,
    isCompressed: json['isCompressed'] as bool,
  );
}

/// 安全备份服务
class SecurityBackupService {
  static final SecurityBackupService _instance = SecurityBackupService._internal();
  late Directory _backupDirectory;
  BackupConfig? _config;
  Timer? _backupTimer;
  BackupStatus _status = BackupStatus.idle;
  final _statusController = StreamController<BackupStatus>.broadcast();

  /// 获取单例实例
  factory SecurityBackupService() {
    return _instance;
  }

  SecurityBackupService._internal();

  /// 初始化备份服务
  Future<void> init(BackupConfig config) async {
    try {
      _config = config;
      final directory = await getApplicationDocumentsDirectory();
      _backupDirectory = Directory('${directory.path}/${config.backupPath}');
      
      if (!await _backupDirectory.exists()) {
        await _backupDirectory.create(recursive: true);
      }

      // 设置定期备份
      _backupTimer?.cancel();
      _backupTimer = Timer.periodic(config.backupInterval, (_) => createBackup());
    } catch (e) {
      throw Exception('初始化备份服务失败: $e');
    }
  }

  /// 创建备份
  Future<BackupMetadata> createBackup() async {
    if (_status == BackupStatus.inProgress) {
      throw Exception('备份正在进行中');
    }

    try {
      _updateStatus(BackupStatus.inProgress);
      
      // 1. 收集数据
      final data = await _collectData();
      
      // 2. 生成元数据
      final metadata = await _generateMetadata(data);
      
      // 3. 压缩数据
      var processedData = data;
      if (_config?.compressBackup == true) {
        processedData = await _compressData(data);
      }
      
      // 4. 加密数据
      if (_config?.encryptBackup == true) {
        if (_config?.encryptionKey == null) {
          throw Exception('未提供加密密钥');
        }
        processedData = await _encryptData(processedData, _config!.encryptionKey!);
      }
      
      // 5. 保存备份文件
      final backupFile = File('${_backupDirectory.path}/backup_${metadata.id}.bak');
      await backupFile.writeAsBytes(processedData);
      
      // 6. 保存元数据
      final metadataFile = File('${_backupDirectory.path}/backup_${metadata.id}.meta');
      await metadataFile.writeAsString(jsonEncode(metadata.toJson()));
      
      _updateStatus(BackupStatus.completed);
      return metadata;
    } catch (e) {
      _updateStatus(BackupStatus.failed);
      throw Exception('创建备份失败: $e');
    }
  }

  /// 恢复备份
  Future<void> restoreBackup(String backupId, {String? encryptionKey}) async {
    if (_status == BackupStatus.inProgress) {
      throw Exception('备份正在进行中');
    }

    try {
      _updateStatus(BackupStatus.inProgress);
      
      // 1. 读取元数据
      final metadataFile = File('${_backupDirectory.path}/backup_$backupId.meta');
      if (!await metadataFile.exists()) {
        throw Exception('备份元数据不存在');
      }
      
      final metadata = BackupMetadata.fromJson(
        jsonDecode(await metadataFile.readAsString())
      );
      
      // 2. 读取备份文件
      final backupFile = File('${_backupDirectory.path}/backup_$backupId.bak');
      if (!await backupFile.exists()) {
        throw Exception('备份文件不存在');
      }
      
      var data = await backupFile.readAsBytes();
      
      // 3. 解密数据
      if (metadata.isEncrypted) {
        if (encryptionKey == null) {
          throw Exception('未提供解密密钥');
        }
        data = await _decryptData(data, encryptionKey);
      }
      
      // 4. 解压数据
      if (metadata.isCompressed) {
        data = await _decompressData(data);
      }
      
      // 5. 验证数据完整性
      final checksum = _calculateChecksum(data);
      if (checksum != metadata.checksum) {
        throw Exception('数据完整性验证失败');
      }
      
      // 6. 恢复数据
      await _restoreData(data);
      
      _updateStatus(BackupStatus.completed);
    } catch (e) {
      _updateStatus(BackupStatus.failed);
      throw Exception('恢复备份失败: $e');
    }
  }

  /// 获取备份列表
  Future<List<BackupMetadata>> getBackupList() async {
    try {
      final metadataFiles = await _backupDirectory
          .list()
          .where((entity) => entity.path.endsWith('.meta'))
          .toList();
      
      final metadataList = <BackupMetadata>[];
      for (final file in metadataFiles) {
        final content = await File(file.path).readAsString();
        metadataList.add(BackupMetadata.fromJson(jsonDecode(content)));
      }
      
      return metadataList..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      throw Exception('获取备份列表失败: $e');
    }
  }

  /// 删除备份
  Future<void> deleteBackup(String backupId) async {
    try {
      final backupFile = File('${_backupDirectory.path}/backup_$backupId.bak');
      final metadataFile = File('${_backupDirectory.path}/backup_$backupId.meta');
      
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
      
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }
    } catch (e) {
      throw Exception('删除备份失败: $e');
    }
  }

  /// 获取备份状态流
  Stream<BackupStatus> get statusStream => _statusController.stream;

  /// 更新备份状态
  void _updateStatus(BackupStatus status) {
    _status = status;
    _statusController.add(status);
  }

  /// 收集需要备份的数据
  Future<List<int>> _collectData() async {
    final db = DatabaseService();
    final Map<String, dynamic> data = {
      'timestamp': DateTime.now().toIso8601String(),
      'tables': {},
    };
    
    for (final table in _config?.includedTables ?? []) {
      final records = await db.queryAll(table);
      data['tables'][table] = records;
    }
    
    return utf8.encode(jsonEncode(data));
  }

  /// 生成备份元数据
  Future<BackupMetadata> _generateMetadata(List<int> data) async {
    final checksum = _calculateChecksum(data);
    final recordCounts = await _countRecords();
    
    return BackupMetadata(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      size: data.length,
      checksum: checksum,
      recordCounts: recordCounts,
      isEncrypted: _config?.encryptBackup ?? false,
      isCompressed: _config?.compressBackup ?? false,
    );
  }

  /// 计算数据校验和
  String _calculateChecksum(List<int> data) {
    return sha256.convert(data).toString();
  }

  /// 统计记录数
  Future<Map<String, int>> _countRecords() async {
    final db = DatabaseService();
    final Map<String, int> counts = {};
    
    for (final table in _config?.includedTables ?? []) {
      counts[table] = await db.count(table);
    }
    
    return counts;
  }

  /// 压缩数据
  Future<List<int>> _compressData(List<int> data) async {
    final encoder = GZipEncoder();
    return encoder.encode(data) ?? [];
  }

  /// 解压数据
  Future<List<int>> _decompressData(List<int> data) async {
    final decoder = GZipDecoder();
    return decoder.decodeBytes(data);
  }

  /// 加密数据
  Future<List<int>> _encryptData(List<int> data, String key) async {
    return EncryptionUtils.encryptAES(data, key);
  }

  /// 解密数据
  Future<List<int>> _decryptData(List<int> data, String key) async {
    return EncryptionUtils.decryptAES(data, key);
  }

  /// 恢复数据
  Future<void> _restoreData(List<int> data) async {
    final db = DatabaseService();
    final jsonData = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
    final tables = jsonData['tables'] as Map<String, dynamic>;
    
    await db.transaction((txn) async {
      for (final table in tables.keys) {
        final records = tables[table] as List;
        // 先清空表
        await txn.delete(table);
        // 批量插入记录
        for (final record in records) {
          await txn.insert(table, record as Map<String, dynamic>);
        }
      }
    });
  }

  /// 销毁服务
  void dispose() {
    _backupTimer?.cancel();
    _statusController.close();
  }
} 