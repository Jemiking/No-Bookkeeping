import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/data_export_import.dart';

/// 备份信息
class BackupInfo {
  final String path;
  final String name;
  final DateTime timestamp;
  final String version;
  final String? description;

  BackupInfo({
    required this.path,
    required this.name,
    required this.timestamp,
    required this.version,
    this.description,
  });

  factory BackupInfo.fromJson(String path, Map<String, dynamic> json) {
    return BackupInfo(
      path: path,
      name: json['name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      version: json['version'] as String,
      description: json['description'] as String?,
    );
  }
}

/// 数据导出导入Provider
class DataExportImportProvider with ChangeNotifier {
  final DataExportImport _service;
  final _exportProgressController = StreamController<ExportProgress>.broadcast();
  final _importProgressController = StreamController<ImportProgress>.broadcast();
  List<BackupInfo>? _backupList;
  bool _isLoading = false;

  DataExportImportProvider(this._service);

  Stream<ExportProgress> get exportProgress => _exportProgressController.stream;
  Stream<ImportProgress> get importProgress => _importProgressController.stream;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _exportProgressController.close();
    _importProgressController.close();
    super.dispose();
  }

  /// 导出数据
  Future<String> exportData(ExportOptions options) async {
    try {
      _setLoading(true);
      final filePath = await _service.exportData(
        options: options,
        onProgress: (progress) {
          _exportProgressController.add(progress);
        },
      );
      return filePath;
    } finally {
      _setLoading(false);
    }
  }

  /// 导入数据
  Future<void> importData(String filePath, ImportOptions options) async {
    try {
      _setLoading(true);
      await _service.importData(
        filePath: filePath,
        options: options,
        onProgress: (progress) {
          _importProgressController.add(progress);
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 创建备份
  Future<String> backupData(String backupName) async {
    try {
      _setLoading(true);
      final backupPath = await _service.backupData(
        backupName: backupName,
        onProgress: (progress) {
          _exportProgressController.add(progress);
        },
      );
      await refreshBackupList();
      return backupPath;
    } finally {
      _setLoading(false);
    }
  }

  /// 恢复备份
  Future<void> restoreData(String backupPath) async {
    try {
      _setLoading(true);
      await _service.restoreData(
        backupPath: backupPath,
        onProgress: (progress) {
          _importProgressController.add(progress);
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 删除备份
  Future<void> deleteBackup(String backupPath) async {
    try {
      _setLoading(true);
      await _service.deleteBackup(backupPath);
      await refreshBackupList();
    } finally {
      _setLoading(false);
    }
  }

  /// 获取备份列表
  Future<List<BackupInfo>> getBackupList() async {
    if (_backupList != null) {
      return _backupList!;
    }
    return refreshBackupList();
  }

  /// 刷新备份列表
  Future<List<BackupInfo>> refreshBackupList() async {
    try {
      _setLoading(true);
      final paths = await _service.getBackupList();
      final backups = <BackupInfo>[];

      for (var path in paths) {
        try {
          final info = await _service.getBackupInfo(path);
          backups.add(BackupInfo.fromJson(path, info));
        } catch (e) {
          print('读取备份信息失败：$path, $e');
        }
      }

      backups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _backupList = backups;
      notifyListeners();
      return backups;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 