import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'webdav_sync_service.dart';
import 'webdav_auth_service.dart';

class SyncFile {
  final String path;
  final String hash;
  final DateTime lastModified;
  final int size;

  SyncFile({
    required this.path,
    required this.hash,
    required this.lastModified,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'hash': hash,
    'lastModified': lastModified.toIso8601String(),
    'size': size,
  };

  factory SyncFile.fromJson(Map<String, dynamic> json) {
    return SyncFile(
      path: json['path'] as String,
      hash: json['hash'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
      size: json['size'] as int,
    );
  }
}

class SyncResult {
  final bool success;
  final String message;
  final List<String> syncedFiles;
  final List<String> failedFiles;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedFiles = const [],
    this.failedFiles = const [],
  });
}

class WebDAVFileSyncManager {
  final WebDAVSyncService _syncService;
  final WebDAVAuthService _authService;
  final String _localBasePath;
  final String _manifestFileName = '.sync_manifest.json';

  WebDAVFileSyncManager({
    required WebDAVSyncService syncService,
    required WebDAVAuthService authService,
    required String localBasePath,
  })  : _syncService = syncService,
        _authService = authService,
        _localBasePath = localBasePath;

  // 执行同步操作
  Future<SyncResult> sync() async {
    try {
      // 验证凭证
      final credentials = await _authService.getCredentials();
      if (credentials == null) {
        return SyncResult(
          success: false,
          message: '未找到WebDAV凭证',
        );
      }

      // 获取本地文件清单
      final localManifest = await _getLocalManifest();
      
      // 获取远程文件清单
      final remoteManifest = await _getRemoteManifest();

      // 比较差异并同步
      final syncedFiles = <String>[];
      final failedFiles = <String>[];

      // 上传新文件和更新的文件
      for (final localFile in localManifest.entries) {
        final remotefile = remoteManifest[localFile.key];
        if (remotefile == null || remotefile.hash != localFile.value.hash) {
          final success = await _uploadFile(localFile.key, localFile.value);
          if (success) {
            syncedFiles.add(localFile.key);
          } else {
            failedFiles.add(localFile.key);
          }
        }
      }

      // 下载新文件
      for (final remoteFile in remoteManifest.entries) {
        final localFile = localManifest[remoteFile.key];
        if (localFile == null || localFile.hash != remoteFile.value.hash) {
          final success = await _downloadFile(remoteFile.key, remoteFile.value);
          if (success) {
            syncedFiles.add(remoteFile.key);
          } else {
            failedFiles.add(remoteFile.key);
          }
        }
      }

      // 更新同步清单
      await _updateManifest();

      return SyncResult(
        success: failedFiles.isEmpty,
        message: '同步完成',
        syncedFiles: syncedFiles,
        failedFiles: failedFiles,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: '同步失败: ${e.toString()}',
      );
    }
  }

  // 获取本地文件清单
  Future<Map<String, SyncFile>> _getLocalManifest() async {
    final manifest = <String, SyncFile>{};
    final directory = Directory(_localBasePath);
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      return manifest;
    }

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        final relativePath = path.relative(entity.path, from: _localBasePath);
        final hash = await _calculateFileHash(entity);
        final stat = await entity.stat();
        
        manifest[relativePath] = SyncFile(
          path: relativePath,
          hash: hash,
          lastModified: stat.modified,
          size: stat.size,
        );
      }
    }

    return manifest;
  }

  // 获取远程文件清单
  Future<Map<String, SyncFile>> _getRemoteManifest() async {
    try {
      if (!await _syncService.fileExists(_manifestFileName)) {
        return {};
      }

      final tempFile = File(path.join(_localBasePath, '.temp_manifest'));
      await _syncService.downloadFile(_manifestFileName, tempFile.path);
      
      final content = await tempFile.readAsString();
      await tempFile.delete();
      
      final Map<String, dynamic> data = jsonDecode(content);
      return Map.fromEntries(
        data.entries.map((e) => MapEntry(
          e.key,
          SyncFile.fromJson(e.value as Map<String, dynamic>),
        )),
      );
    } catch (e) {
      return {};
    }
  }

  // 更新同步清单
  Future<void> _updateManifest() async {
    final manifest = await _getLocalManifest();
    final content = jsonEncode(
      manifest.map((key, value) => MapEntry(key, value.toJson())),
    );
    
    final tempFile = File(path.join(_localBasePath, '.temp_manifest'));
    await tempFile.writeAsString(content);
    
    await _syncService.uploadFile(tempFile.path, _manifestFileName);
    await tempFile.delete();
  }

  // 上传文件
  Future<bool> _uploadFile(String relativePath, SyncFile file) async {
    final localPath = path.join(_localBasePath, relativePath);
    return await _syncService.uploadFile(localPath, relativePath);
  }

  // 下载文件
  Future<bool> _downloadFile(String relativePath, SyncFile file) async {
    final localPath = path.join(_localBasePath, relativePath);
    final directory = Directory(path.dirname(localPath));
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return await _syncService.downloadFile(relativePath, localPath);
  }

  // 计算文件哈希
  Future<String> _calculateFileHash(File file) async {
    final bytes = await file.readAsBytes();
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // 检查文件是否需要同步
  Future<bool> _needsSync(String relativePath, SyncFile localFile) async {
    try {
      final remoteInfo = await _syncService.getFileInfo(relativePath);
      if (remoteInfo.isEmpty) return true;
      
      // 这里需要根据实际WebDAV服务器返回的信息进行比较
      return true;
    } catch (e) {
      return true;
    }
  }

  // 处理同步冲突
  Future<void> _handleConflict(String relativePath) async {
    // 这里可以实现冲突处理逻辑
    // 例如：重命名文件、创建备份等
  }
} 