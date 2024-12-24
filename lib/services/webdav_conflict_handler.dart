import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'webdav_sync_service.dart';

enum ConflictResolutionStrategy {
  keepLocal,
  keepRemote,
  keepBoth,
  merge,
  askUser,
}

class ConflictFile {
  final String path;
  final DateTime localModified;
  final DateTime remoteModified;
  final int localSize;
  final int remoteSize;
  final String localHash;
  final String remoteHash;

  ConflictFile({
    required this.path,
    required this.localModified,
    required this.remoteModified,
    required this.localSize,
    required this.remoteSize,
    required this.localHash,
    required this.remoteHash,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'localModified': localModified.toIso8601String(),
    'remoteModified': remoteModified.toIso8601String(),
    'localSize': localSize,
    'remoteSize': remoteSize,
    'localHash': localHash,
    'remoteHash': remoteHash,
  };

  factory ConflictFile.fromJson(Map<String, dynamic> json) {
    return ConflictFile(
      path: json['path'] as String,
      localModified: DateTime.parse(json['localModified'] as String),
      remoteModified: DateTime.parse(json['remoteModified'] as String),
      localSize: json['localSize'] as int,
      remoteSize: json['remoteSize'] as int,
      localHash: json['localHash'] as String,
      remoteHash: json['remoteHash'] as String,
    );
  }
}

class ConflictResolution {
  final String path;
  final ConflictResolutionStrategy strategy;
  final String? mergedContent;

  ConflictResolution({
    required this.path,
    required this.strategy,
    this.mergedContent,
  });
}

class WebDAVConflictHandler {
  final WebDAVSyncService _syncService;
  final String _localBasePath;
  final String _conflictLogFile = '.sync_conflicts.json';
  final ConflictResolutionStrategy defaultStrategy;

  WebDAVConflictHandler({
    required WebDAVSyncService syncService,
    required String localBasePath,
    this.defaultStrategy = ConflictResolutionStrategy.askUser,
  })  : _syncService = syncService,
        _localBasePath = localBasePath;

  // 检测文件冲突
  Future<bool> hasConflict(String relativePath, String localHash, String remoteHash) async {
    if (localHash != remoteHash) {
      final localFile = File(path.join(_localBasePath, relativePath));
      final localStat = await localFile.stat();
      
      final remoteInfo = await _syncService.getFileInfo(relativePath);
      if (remoteInfo.isEmpty) return false;

      // 如果文件在同一时间被修改，认为存在冲突
      final timeDiff = localStat.modified.difference(
        DateTime.parse(remoteInfo['lastModified'] as String),
      ).abs();

      return timeDiff.inMinutes < 5; // 5分钟内的修改视为冲突
    }
    return false;
  }

  // 解决冲突
  Future<void> resolveConflict(ConflictFile conflict) async {
    final resolution = await _getResolutionStrategy(conflict);
    await _applyResolution(conflict, resolution);
    await _logConflictResolution(conflict, resolution);
  }

  // 获取解决策略
  Future<ConflictResolution> _getResolutionStrategy(ConflictFile conflict) async {
    switch (defaultStrategy) {
      case ConflictResolutionStrategy.keepLocal:
        return ConflictResolution(
          path: conflict.path,
          strategy: ConflictResolutionStrategy.keepLocal,
        );
      
      case ConflictResolutionStrategy.keepRemote:
        return ConflictResolution(
          path: conflict.path,
          strategy: ConflictResolutionStrategy.keepRemote,
        );
      
      case ConflictResolutionStrategy.keepBoth:
        return ConflictResolution(
          path: conflict.path,
          strategy: ConflictResolutionStrategy.keepBoth,
        );
      
      case ConflictResolutionStrategy.merge:
        final mergedContent = await _mergeFiles(conflict);
        return ConflictResolution(
          path: conflict.path,
          strategy: ConflictResolutionStrategy.merge,
          mergedContent: mergedContent,
        );
      
      case ConflictResolutionStrategy.askUser:
      default:
        // 在实际应用中，这里应该实现用户交互逻辑
        return ConflictResolution(
          path: conflict.path,
          strategy: ConflictResolutionStrategy.keepBoth,
        );
    }
  }

  // 应用解决方案
  Future<void> _applyResolution(ConflictFile conflict, ConflictResolution resolution) async {
    final localPath = path.join(_localBasePath, conflict.path);
    
    switch (resolution.strategy) {
      case ConflictResolutionStrategy.keepLocal:
        // 不需要操作，保持本地文件
        break;
      
      case ConflictResolutionStrategy.keepRemote:
        await _syncService.downloadFile(conflict.path, localPath);
        break;
      
      case ConflictResolutionStrategy.keepBoth:
        final extension = path.extension(conflict.path);
        final nameWithoutExtension = path.basenameWithoutExtension(conflict.path);
        final newName = '${nameWithoutExtension}_conflict_${DateTime.now().millisecondsSinceEpoch}$extension';
        final newPath = path.join(path.dirname(localPath), newName);
        
        await _syncService.downloadFile(conflict.path, newPath);
        break;
      
      case ConflictResolutionStrategy.merge:
        if (resolution.mergedContent != null) {
          final file = File(localPath);
          await file.writeAsString(resolution.mergedContent!);
          await _syncService.uploadFile(localPath, conflict.path);
        }
        break;
      
      case ConflictResolutionStrategy.askUser:
        // 在实际应用中，这里应该等待用户选择
        break;
    }
  }

  // 合并文件内容
  Future<String?> _mergeFiles(ConflictFile conflict) async {
    try {
      final localPath = path.join(_localBasePath, conflict.path);
      final localFile = File(localPath);
      final localContent = await localFile.readAsString();

      final tempFile = File(path.join(_localBasePath, '.temp_merge'));
      await _syncService.downloadFile(conflict.path, tempFile.path);
      final remoteContent = await tempFile.readAsString();
      await tempFile.delete();

      // 这里应该实现实际的文件合并逻辑
      // 当前仅返回一个简单的合并示例
      return '''
// <<<<<<< LOCAL
$localContent
// =======
$remoteContent
// >>>>>>> REMOTE
''';
    } catch (e) {
      return null;
    }
  }

  // 记录冲突解决日志
  Future<void> _logConflictResolution(ConflictFile conflict, ConflictResolution resolution) async {
    final logFile = File(path.join(_localBasePath, _conflictLogFile));
    final log = {
      'timestamp': DateTime.now().toIso8601String(),
      'conflict': conflict.toJson(),
      'resolution': resolution.strategy.toString(),
    };

    List<Map<String, dynamic>> logs = [];
    if (await logFile.exists()) {
      final content = await logFile.readAsString();
      logs = List<Map<String, dynamic>>.from(jsonDecode(content));
    }

    logs.add(log);
    await logFile.writeAsString(jsonEncode(logs));
  }

  // 获取冲突历史记录
  Future<List<Map<String, dynamic>>> getConflictHistory() async {
    final logFile = File(path.join(_localBasePath, _conflictLogFile));
    if (!await logFile.exists()) {
      return [];
    }

    final content = await logFile.readAsString();
    return List<Map<String, dynamic>>.from(jsonDecode(content));
  }

  // 清理冲突历史记录
  Future<void> clearConflictHistory() async {
    final logFile = File(path.join(_localBasePath, _conflictLogFile));
    if (await logFile.exists()) {
      await logFile.delete();
    }
  }
} 