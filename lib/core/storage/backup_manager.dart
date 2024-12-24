import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'database_config.dart';
import 'storage_interface.dart';

/// 备份状态
enum BackupStatus {
  pending,
  inProgress,
  completed,
  failed,
}

/// 备份信息
class BackupInfo {
  final String filename;
  final int size;
  final String hash;
  final DateTime createdAt;
  final BackupStatus status;
  final String? error;

  BackupInfo({
    required this.filename,
    required this.size,
    required this.hash,
    required this.createdAt,
    required this.status,
    this.error,
  });

  Map<String, dynamic> toMap() {
    return {
      'filename': filename,
      'size': size,
      'hash': hash,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'status': status.toString().split('.').last,
      'error': error,
    };
  }

  factory BackupInfo.fromMap(Map<String, dynamic> map) {
    return BackupInfo(
      filename: map['filename'],
      size: map['size'],
      hash: map['hash'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] * 1000),
      status: BackupStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      error: map['error'],
    );
  }
}

/// 数据库备份管理器
class BackupManager {
  final DatabaseConfig config;
  final StorageInterface storage;
  Timer? _backupTimer;
  bool _isBackupInProgress = false;

  BackupManager(this.config, this.storage) {
    if (config.enableAutoBackup && !kIsWeb) {
      _startAutoBackup();
    }
  }

  /// 启动自动备份
  void _startAutoBackup() {
    _backupTimer?.cancel();
    _backupTimer = Timer.periodic(
      Duration(hours: config.backupInterval),
      (_) => createBackup(),
    );
  }

  /// 创建备份
  Future<BackupInfo> createBackup() async {
    if (_isBackupInProgress) {
      throw StateError('Backup is already in progress');
    }

    _isBackupInProgress = true;
    BackupInfo? backupInfo;

    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFileName = 'backup_$timestamp.db';
      
      if (kIsWeb) {
        // Web平台使用localStorage进行备份
        final result = await storage.query('*');
        if (result.hasError) {
          throw StateError('Failed to backup data: ${result.error}');
        }
        
        final backupData = json.encode(result.data);
        final hash = _calculateWebHash(backupData);
        
        backupInfo = BackupInfo(
          filename: backupFileName,
          size: backupData.length,
          hash: hash,
          createdAt: DateTime.now(),
          status: BackupStatus.completed,
        );
        
        await _saveBackupInfo(backupInfo);
        return backupInfo;
      }

      // 创建备份文件名
      final backupPath = await _getBackupPath(backupFileName);

      // 确保备份目录存在
      final backupDir = Directory(path.dirname(backupPath));
      if (!backupDir.existsSync()) {
        await backupDir.create(recursive: true);
      }

      // 复制数据库文件
      final dbFile = File(await config.getDatabasePath());
      await dbFile.copy(backupPath);

      // 计算文件大小和哈希
      final backupFile = File(backupPath);
      final size = await backupFile.length();
      final hash = await _calculateFileHash(backupFile);

      // 创建备份信息
      backupInfo = BackupInfo(
        filename: backupFileName,
        size: size,
        hash: hash,
        createdAt: DateTime.now(),
        status: BackupStatus.completed,
      );

      // 记录备份信息到数据库
      await _saveBackupInfo(backupInfo);

      // 清理旧备份
      await _cleanupOldBackups();

      return backupInfo;
    } catch (e) {
      final errorBackupInfo = BackupInfo(
        filename: backupInfo?.filename ?? 'failed_backup',
        size: backupInfo?.size ?? 0,
        hash: backupInfo?.hash ?? '',
        createdAt: DateTime.now(),
        status: BackupStatus.failed,
        error: e.toString(),
      );

      await _saveBackupInfo(errorBackupInfo);
      rethrow;
    } finally {
      _isBackupInProgress = false;
    }
  }

  /// 还原备份
  Future<void> restoreBackup(String filename) async {
    if (_isBackupInProgress) {
      throw StateError('Cannot restore while backup is in progress');
    }

    if (kIsWeb) {
      // Web平台的还原逻辑
      final backupInfo = await _getBackupInfo(filename);
      if (backupInfo == null) {
        throw StateError('Backup information not found');
      }

      await storage.close();
      // Web平台的还原操作会在storage实现中处理
      await storage.initialize();
      return;
    }

    final backupPath = await _getBackupPath(filename);
    final backupFile = File(backupPath);

    if (!backupFile.existsSync()) {
      throw FileSystemException('Backup file not found', backupPath);
    }

    // 验证备份文件
    final backupInfo = await _getBackupInfo(filename);
    if (backupInfo == null) {
      throw StateError('Backup information not found in database');
    }

    final currentHash = await _calculateFileHash(backupFile);
    if (currentHash != backupInfo.hash) {
      throw StateError('Backup file is corrupted');
    }

    // 关闭数据库连接
    await storage.close();

    try {
      // 复制备份文件到数据库位置
      final dbPath = await config.getDatabasePath();
      await backupFile.copy(dbPath);
    } finally {
      // 重新初始化数据库
      await storage.initialize();
    }
  }

  /// 获取所有备份
  Future<List<BackupInfo>> getAllBackups() async {
    final result = await storage.query('backups', orderBy: 'created_at DESC');
    if (result.hasError) {
      throw StateError('Failed to get backups: ${result.error}');
    }
    return result.data!.map((map) => BackupInfo.fromMap(map)).toList();
  }

  /// 删除备份
  Future<void> deleteBackup(String filename) async {
    final backupPath = await _getBackupPath(filename);
    final backupFile = File(backupPath);

    if (backupFile.existsSync()) {
      await backupFile.delete();
    }

    final result = await storage.delete(
      'backups',
      where: 'filename = ?',
      whereArgs: [filename],
    );

    if (result.hasError) {
      throw StateError('Failed to delete backup: ${result.error}');
    }
  }

  /// 获取备份文件路径
  Future<String> _getBackupPath(String filename) async {
    final backupDir = await config.getBackupPath();
    return path.join(backupDir, filename);
  }

  /// 计算文件哈希
  Future<String> _calculateFileHash(File file) async {
    final sink = AccumulatorSink<Digest>();
    final hasher = md5.startChunkedConversion(sink);

    await for (final chunk in file.openRead()) {
      hasher.add(chunk);
    }

    hasher.close();
    return sink.events.single.toString();
  }

  /// 保存备份信息到数据库
  Future<void> _saveBackupInfo(BackupInfo info) async {
    final result = await storage.insert('backups', info.toMap());
    if (result.hasError) {
      throw StateError('Failed to save backup info: ${result.error}');
    }
  }

  /// 获取备份信息
  Future<BackupInfo?> _getBackupInfo(String filename) async {
    final result = await storage.query(
      'backups',
      where: 'filename = ?',
      whereArgs: [filename],
    );

    if (result.hasError) {
      throw StateError('Failed to get backup info: ${result.error}');
    }

    if (result.data!.isEmpty) return null;
    return BackupInfo.fromMap(result.data!.first);
  }

  /// 清理旧备份
  Future<void> _cleanupOldBackups() async {
    final backups = await getAllBackups();
    if (backups.length <= config.maxBackupFiles) return;

    final backupsToDelete = backups.sublist(config.maxBackupFiles);
    for (final backup in backupsToDelete) {
      await deleteBackup(backup.filename);
    }
  }

  /// 关闭备份管理器
  void dispose() {
    _backupTimer?.cancel();
  }

  String _calculateWebHash(String data) {
    final bytes = utf8.encode(data);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
} 