import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/exceptions/app_exceptions.dart';

class BackupService {
  static const String _backupPrefix = 'money_tracker_backup';

  /// 创建数据库备份
  Future<String> createBackup() async {
    try {
      // 获取数据库路径
      final dbPath = await getDatabasesPath();
      final dbFile = join(dbPath, 'money_tracker.db');

      // 检查数据库是否存在
      if (!await File(dbFile).exists()) {
        throw DatabaseException('Database file does not exist');
      }

      // 创建备份文件名（包含时间戳）
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFile = join(dbPath, '${_backupPrefix}_$timestamp.db');

      // 复制数据库文件
      await File(dbFile).copy(backupFile);

      return backupFile;
    } catch (e) {
      throw DatabaseException(
        'Failed to create database backup',
        details: e.toString(),
      );
    }
  }

  /// 从备份恢复数据库
  Future<void> restoreFromBackup(String backupPath) async {
    try {
      // 获取当前数据库路径
      final dbPath = await getDatabasesPath();
      final dbFile = join(dbPath, 'money_tracker.db');

      // 检查备份文件是否存在
      if (!await File(backupPath).exists()) {
        throw DatabaseException('Backup file does not exist');
      }

      // 如果当前数据库存在，先删除
      if (await File(dbFile).exists()) {
        await File(dbFile).delete();
      }

      // 复制备份文件到数据库位置
      await File(backupPath).copy(dbFile);
    } catch (e) {
      throw DatabaseException(
        'Failed to restore database from backup',
        details: e.toString(),
      );
    }
  }

  /// 获取所有备份文件
  Future<List<String>> getAllBackups() async {
    try {
      final dbPath = await getDatabasesPath();
      final dir = Directory(dbPath);
      
      if (!await dir.exists()) {
        return [];
      }

      return dir
          .listSync()
          .where((file) => file.path.contains(_backupPrefix))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      throw DatabaseException(
        'Failed to get backup list',
        details: e.toString(),
      );
    }
  }

  /// 删除备份文件
  Future<void> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw DatabaseException(
        'Failed to delete backup',
        details: e.toString(),
      );
    }
  }
} 