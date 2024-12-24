import 'package:flutter/foundation.dart';

/// 导出格式枚举
enum ExportFormat {
  excel,
  csv,
  json,
  pdf,
}

/// 导出选项
class ExportOptions {
  final DateTime startDate;
  final DateTime endDate;
  final ExportFormat format;
  final String? password;
  final bool includeTransactions;
  final bool includeAccounts;
  final bool includeCategories;
  final bool includeTags;
  final bool includeBudgets;

  ExportOptions({
    required this.startDate,
    required this.endDate,
    required this.format,
    this.password,
    this.includeTransactions = true,
    this.includeAccounts = true,
    this.includeCategories = true,
    this.includeTags = true,
    this.includeBudgets = true,
  });
}

/// 导入选项
class ImportOptions {
  final ExportFormat format;
  final bool overwriteExisting;
  final String? password;

  ImportOptions({
    required this.format,
    this.overwriteExisting = false,
    this.password,
  });
}

/// 导出进度
class ExportProgress {
  final int totalItems;
  final int processedItems;
  final String currentOperation;
  final double progress;

  ExportProgress({
    required this.totalItems,
    required this.processedItems,
    required this.currentOperation,
    required this.progress,
  });
}

/// 导入进度
class ImportProgress {
  final int totalItems;
  final int processedItems;
  final String currentOperation;
  final double progress;
  final List<String> warnings;

  ImportProgress({
    required this.totalItems,
    required this.processedItems,
    required this.currentOperation,
    required this.progress,
    required this.warnings,
  });
}

/// 导出数据
class ExportData {
  final List<dynamic>? transactions;
  final List<dynamic>? accounts;
  final List<dynamic>? categories;
  final List<dynamic>? tags;
  final List<dynamic>? budgets;
  final DateTime exportTime;
  final String version;

  ExportData({
    this.transactions,
    this.accounts,
    this.categories,
    this.tags,
    this.budgets,
    required this.exportTime,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactions': transactions,
      'accounts': accounts,
      'categories': categories,
      'tags': tags,
      'budgets': budgets,
      'exportTime': exportTime.toIso8601String(),
      'version': version,
    };
  }

  factory ExportData.fromJson(Map<String, dynamic> json) {
    return ExportData(
      transactions: json['transactions'] as List<dynamic>?,
      accounts: json['accounts'] as List<dynamic>?,
      categories: json['categories'] as List<dynamic>?,
      tags: json['tags'] as List<dynamic>?,
      budgets: json['budgets'] as List<dynamic>?,
      exportTime: DateTime.parse(json['exportTime'] as String),
      version: json['version'] as String,
    );
  }
}

/// 数据导出导入接口
abstract class DataExportImport {
  /// 导出数据
  Future<String> exportData({
    required ExportOptions options,
    required ValueChanged<ExportProgress>? onProgress,
  });

  /// 导入数据
  Future<ExportData> importData({
    required String filePath,
    required ImportOptions options,
    required ValueChanged<ImportProgress>? onProgress,
  });

  /// 备份数据
  Future<String> backupData({
    required String backupName,
    String? password,
    required ValueChanged<ExportProgress>? onProgress,
  });

  /// 恢复数据
  Future<void> restoreData({
    required String backupPath,
    String? password,
    required ValueChanged<ImportProgress>? onProgress,
  });

  /// 获取备份列表
  Future<List<String>> getBackupList();

  /// 删除备份
  Future<void> deleteBackup(String backupPath);

  /// 验证备份
  Future<bool> validateBackup(String backupPath, [String? password]);

  /// 获取备份信息
  Future<Map<String, dynamic>> getBackupInfo(String backupPath);
} 