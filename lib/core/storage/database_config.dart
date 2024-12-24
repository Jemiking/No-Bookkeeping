import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;

/// 数据库配置类
class DatabaseConfig {
  /// 数据库名称
  final String name;
  
  /// 数据库版本
  final int version;
  
  /// 是否启用日志
  final bool enableLogging;
  
  /// 是否启用加密
  final bool enableEncryption;
  
  /// 加密密钥
  final String? encryptionKey;
  
  /// 最大连接数
  final int maxConnections;
  
  /// 连接超时时间（毫秒）
  final int connectionTimeout;
  
  /// 查询超时时间（毫秒）
  final int queryTimeout;
  
  /// 是否启用自动备份
  final bool enableAutoBackup;
  
  /// 备份间隔（小时）
  final int backupInterval;
  
  /// 最大备份文件数
  final int maxBackupFiles;
  
  /// 是否启用WAL模式
  final bool enableWAL;
  
  /// 是否启用外键约束
  final bool enableForeignKeys;
  
  /// 是否启用软删除
  final bool enableSoftDeletes;

  const DatabaseConfig({
    required this.name,
    required this.version,
    this.enableLogging = false,
    this.enableEncryption = false,
    this.encryptionKey,
    this.maxConnections = 5,
    this.connectionTimeout = 5000,
    this.queryTimeout = 3000,
    this.enableAutoBackup = true,
    this.backupInterval = 24,
    this.maxBackupFiles = 7,
    this.enableWAL = true,
    this.enableForeignKeys = true,
    this.enableSoftDeletes = true,
  }) : assert(
          !enableEncryption || (enableEncryption && encryptionKey != null),
          'Encryption key must be provided when encryption is enabled',
        );

  /// 获取数据库路径
  Future<String> getDatabasePath() async {
    if (kIsWeb) {
      return 'web_storage';
    }

    final dbFolder = await _getDatabaseFolder();
    return path.join(dbFolder, name);
  }

  /// 获取备份路径
  Future<String> getBackupPath() async {
    if (kIsWeb) {
      return 'web_storage_backup';
    }

    final dbFolder = await _getDatabaseFolder();
    return path.join(dbFolder, 'backups');
  }

  /// 获取数据库文件夹
  Future<String> _getDatabaseFolder() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final dbFolder = await sqflite.getDatabasesPath();
      return dbFolder;
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      final dbFolder = path.join(appDir.path, 'databases');
      await Directory(dbFolder).create(recursive: true);
      return dbFolder;
    }
  }

  /// 创建一个新的配置实例，但使用不同的值
  DatabaseConfig copyWith({
    String? name,
    int? version,
    bool? enableLogging,
    bool? enableEncryption,
    String? encryptionKey,
    int? maxConnections,
    int? connectionTimeout,
    int? queryTimeout,
    bool? enableAutoBackup,
    int? backupInterval,
    int? maxBackupFiles,
    bool? enableWAL,
    bool? enableForeignKeys,
    bool? enableSoftDeletes,
  }) {
    return DatabaseConfig(
      name: name ?? this.name,
      version: version ?? this.version,
      enableLogging: enableLogging ?? this.enableLogging,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      maxConnections: maxConnections ?? this.maxConnections,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      queryTimeout: queryTimeout ?? this.queryTimeout,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      backupInterval: backupInterval ?? this.backupInterval,
      maxBackupFiles: maxBackupFiles ?? this.maxBackupFiles,
      enableWAL: enableWAL ?? this.enableWAL,
      enableForeignKeys: enableForeignKeys ?? this.enableForeignKeys,
      enableSoftDeletes: enableSoftDeletes ?? this.enableSoftDeletes,
    );
  }

  @override
  String toString() {
    return 'DatabaseConfig('
        'name: $name, '
        'version: $version, '
        'enableLogging: $enableLogging, '
        'enableEncryption: $enableEncryption, '
        'maxConnections: $maxConnections, '
        'connectionTimeout: $connectionTimeout, '
        'queryTimeout: $queryTimeout, '
        'enableAutoBackup: $enableAutoBackup, '
        'backupInterval: $backupInterval, '
        'maxBackupFiles: $maxBackupFiles, '
        'enableWAL: $enableWAL, '
        'enableForeignKeys: $enableForeignKeys, '
        'enableSoftDeletes: $enableSoftDeletes)';
  }
} 