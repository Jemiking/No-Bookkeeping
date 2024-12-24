import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';
import '../domain/data_export_import.dart';
import '../../transaction/models/transaction.dart';
import '../../account/models/account.dart';
import '../../category/models/category.dart';
import '../../tag/models/tag.dart';
import '../../budget/models/budget.dart';
import '../../../core/utils/logger.dart';
import '../../../core/security/encryption_service.dart';

class DataExportImportImpl implements DataExportImport {
  final Database database;
  final Logger logger;
  final EncryptionService encryptionService;

  static const String BACKUP_FOLDER = 'backups';
  static const String EXPORT_FOLDER = 'exports';
  static const String APP_VERSION = '1.0.0';

  DataExportImportImpl({
    required this.database,
    required this.logger,
    required this.encryptionService,
  });

  @override
  Future<String> exportData({
    required ExportOptions options,
    required ValueChanged<ExportProgress>? onProgress,
  }) async {
    try {
      // 准备导出数据
      final data = await _prepareExportData(options, onProgress);

      // 根据格式导出
      final String filePath = await _exportToFormat(data, options, onProgress);

      // 加密（如果需要）
      if (options.password != null) {
        await _encryptFile(filePath, options.password!);
      }

      return filePath;
    } catch (e) {
      logger.error('导出数据失败：$e');
      rethrow;
    }
  }

  @override
  Future<ExportData> importData({
    required String filePath,
    required ImportOptions options,
    required ValueChanged<ImportProgress>? onProgress,
  }) async {
    try {
      // 解密（如果需要）
      if (options.password != null) {
        await _decryptFile(filePath, options.password!);
      }

      // 根据格式导入
      final data = await _importFromFormat(filePath, options, onProgress);

      // 保存数据
      await _saveImportedData(data, options, onProgress);

      return data;
    } catch (e) {
      logger.error('导入数据失败：$e');
      rethrow;
    }
  }

  @override
  Future<String> backupData({
    required String backupName,
    String? password,
    required ValueChanged<ExportProgress>? onProgress,
  }) async {
    try {
      // 准备备份目录
      final backupDir = await _prepareBackupDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = '${backupDir.path}/${backupName}_$timestamp.zip';

      // 导出所有数据
      final data = await _prepareExportData(
        ExportOptions(
          startDate: DateTime(2000),
          endDate: DateTime.now(),
          format: ExportFormat.json,
          password: password,
        ),
        onProgress,
      );

      // 创建ZIP文件
      final encoder = ZipEncoder();
      final archive = Archive();

      // 添加数据文件
      final jsonBytes = utf8.encode(jsonEncode(data.toJson()));
      archive.addFile(ArchiveFile(
        'data.json',
        jsonBytes.length,
        jsonBytes,
      ));

      // 添加元数据
      final metadataBytes = utf8.encode(jsonEncode({
        'version': APP_VERSION,
        'timestamp': timestamp,
        'name': backupName,
      }));
      archive.addFile(ArchiveFile(
        'metadata.json',
        metadataBytes.length,
        metadataBytes,
      ));

      // 写入ZIP文件
      final zipBytes = encoder.encode(archive);
      if (zipBytes != null) {
        final file = File(backupPath);
        await file.writeAsBytes(zipBytes);
      }

      // 加密（如果需要）
      if (password != null) {
        await _encryptFile(backupPath, password);
      }

      return backupPath;
    } catch (e) {
      logger.error('备份数据失败：$e');
      rethrow;
    }
  }

  @override
  Future<void> restoreData({
    required String backupPath,
    String? password,
    required ValueChanged<ImportProgress>? onProgress,
  }) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        throw Exception('备份文件不存在');
      }

      // 解密（如果需要）
      if (password != null) {
        await _decryptFile(backupPath, password);
      }

      // 读取ZIP文件
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 读取数据文件
      final dataFile = archive.findFile('data.json');
      if (dataFile == null) {
        throw Exception('备份文件损坏');
      }

      final jsonString = utf8.decode(dataFile.content as List<int>);
      final data = ExportData.fromJson(jsonDecode(jsonString));

      // 恢复数据
      await _saveImportedData(
        data,
        ImportOptions(
          format: ExportFormat.json,
          overwriteExisting: true,
          password: password,
        ),
        onProgress,
      );
    } catch (e) {
      logger.error('恢复数据失败：$e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getBackupList() async {
    try {
      final backupDir = await _prepareBackupDirectory();
      final files = await backupDir.list().toList();
      return files
          .whereType<File>()
          .where((f) => f.path.endsWith('.zip'))
          .map((f) => f.path)
          .toList();
    } catch (e) {
      logger.error('获取备份列表失败：$e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      logger.error('删除备份失败：$e');
      rethrow;
    }
  }

  @override
  Future<bool> validateBackup(String backupPath, [String? password]) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        return false;
      }

      // 解密（如果需要）
      if (password != null) {
        try {
          await _decryptFile(backupPath, password);
        } catch (e) {
          return false;
        }
      }

      // 验证ZIP文件结构
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final dataFile = archive.findFile('data.json');
      final metadataFile = archive.findFile('metadata.json');

      if (dataFile == null || metadataFile == null) {
        return false;
      }

      // 验证数据格式
      try {
        final jsonString = utf8.decode(dataFile.content as List<int>);
        ExportData.fromJson(jsonDecode(jsonString));
        return true;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getBackupInfo(String backupPath) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        throw Exception('备份文件不存在');
      }

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final metadataFile = archive.findFile('metadata.json');
      if (metadataFile == null) {
        throw Exception('备份文件损坏');
      }

      final jsonString = utf8.decode(metadataFile.content as List<int>);
      return jsonDecode(jsonString);
    } catch (e) {
      logger.error('获取备份信息失败：$e');
      rethrow;
    }
  }

  // 私有辅助方法

  Future<ExportData> _prepareExportData(
    ExportOptions options,
    ValueChanged<ExportProgress>? onProgress,
  ) async {
    final totalSteps = [
      options.includeTransactions,
      options.includeAccounts,
      options.includeCategories,
      options.includeTags,
      options.includeBudgets,
    ].where((include) => include).length;

    int currentStep = 0;

    List<Transaction>? transactions;
    List<Account>? accounts;
    List<Category>? categories;
    List<Tag>? tags;
    List<Budget>? budgets;

    void updateProgress(String operation) {
      if (onProgress != null) {
        onProgress(ExportProgress(
          totalItems: totalSteps,
          processedItems: currentStep,
          currentOperation: operation,
          progress: currentStep / totalSteps,
        ));
      }
    }

    if (options.includeTransactions) {
      updateProgress('导出交易记录');
      transactions = await _getTransactions(options.startDate, options.endDate);
      currentStep++;
    }

    if (options.includeAccounts) {
      updateProgress('导出账户信息');
      accounts = await _getAccounts();
      currentStep++;
    }

    if (options.includeCategories) {
      updateProgress('导出分类信息');
      categories = await _getCategories();
      currentStep++;
    }

    if (options.includeTags) {
      updateProgress('导出标签信息');
      tags = await _getTags();
      currentStep++;
    }

    if (options.includeBudgets) {
      updateProgress('导出预算信息');
      budgets = await _getBudgets();
      currentStep++;
    }

    return ExportData(
      transactions: transactions,
      accounts: accounts,
      categories: categories,
      tags: tags,
      budgets: budgets,
      exportTime: DateTime.now(),
      version: APP_VERSION,
    );
  }

  Future<String> _exportToFormat(
    ExportData data,
    ExportOptions options,
    ValueChanged<ExportProgress>? onProgress,
  ) async {
    switch (options.format) {
      case ExportFormat.excel:
        return _exportToExcel(data, options);
      case ExportFormat.csv:
        return _exportToCsv(data, options);
      case ExportFormat.json:
        return _exportToJson(data, options);
      case ExportFormat.pdf:
        throw UnimplementedError('PDF导出暂未实现');
    }
  }

  Future<String> _exportToExcel(
    ExportData data,
    ExportOptions options,
  ) async {
    try {
      final excel = Excel.createExcel();
      
      // 创建交易记录工作表
      final transactionSheet = excel['Transactions'];
      
      // 添加表头
      transactionSheet.appendRow([
        'ID',
        'Date',
        'Type',
        'Amount',
        'Category',
        'Account',
        'Tags',
        'Notes',
        'Created At',
        'Updated At'
      ]);
      
      // 添加数据行
      for (final transaction in data.transactions) {
        transactionSheet.appendRow([
          transaction.id,
          transaction.date.toIso8601String(),
          transaction.type.toString(),
          transaction.amount,
          transaction.category?.name ?? '',
          transaction.account.name,
          transaction.tags.map((t) => t.name).join(', '),
          transaction.notes,
          transaction.createdAt.toIso8601String(),
          transaction.updatedAt.toIso8601String(),
        ]);
      }
      
      // 创建账户工作表
      final accountSheet = excel['Accounts'];
      accountSheet.appendRow([
        'ID',
        'Name',
        'Type',
        'Currency',
        'Balance',
        'Notes',
        'Created At',
        'Updated At'
      ]);
      
      for (final account in data.accounts) {
        accountSheet.appendRow([
          account.id,
          account.name,
          account.type.toString(),
          account.currency,
          account.balance,
          account.notes,
          account.createdAt.toIso8601String(),
          account.updatedAt.toIso8601String(),
        ]);
      }
      
      // 创建分类工作表
      final categorySheet = excel['Categories'];
      categorySheet.appendRow([
        'ID',
        'Name',
        'Parent ID',
        'Type',
        'Icon',
        'Created At',
        'Updated At'
      ]);
      
      for (final category in data.categories) {
        categorySheet.appendRow([
          category.id,
          category.name,
          category.parentId,
          category.type.toString(),
          category.icon,
          category.createdAt.toIso8601String(),
          category.updatedAt.toIso8601String(),
        ]);
      }
      
      // 创建标签工作表
      final tagSheet = excel['Tags'];
      tagSheet.appendRow([
        'ID',
        'Name',
        'Color',
        'Created At',
        'Updated At'
      ]);
      
      for (final tag in data.tags) {
        tagSheet.appendRow([
          tag.id,
          tag.name,
          tag.color,
          tag.createdAt.toIso8601String(),
          tag.updatedAt.toIso8601String(),
        ]);
      }
      
      // 设置列宽
      for (final sheet in excel.sheets.values) {
        for (var col = 0; col < sheet.maxCols; col++) {
          sheet.setColWidth(col, 15.0);
        }
      }
      
      // 保存文件
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filePath = '${directory.path}/$EXPORT_FOLDER/export_$timestamp.xlsx';
      
      final file = File(filePath);
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);
      }
      
      return filePath;
    } catch (e) {
      logger.error('导出Excel失败：$e');
      rethrow;
    }
  }

  Future<String> _exportToCsv(
    ExportData data,
    ExportOptions options,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final baseDir = '${directory.path}/$EXPORT_FOLDER';
      
      // 创建导出目录
      final exportDir = Directory(baseDir);
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      
      // 导出交易记录
      final transactionFile = File('$baseDir/transactions_$timestamp.csv');
      final transactionSink = transactionFile.openWrite();
      final transactionCsv = ListToCsvConverter();
      
      // 写入表头
      transactionSink.writeln(transactionCsv.convert([
        ['ID', 'Date', 'Type', 'Amount', 'Category', 'Account', 'Tags', 'Notes', 'Created At', 'Updated At']
      ]));
      
      // 写入数据
      for (final transaction in data.transactions) {
        transactionSink.writeln(transactionCsv.convert([[
          transaction.id,
          transaction.date.toIso8601String(),
          transaction.type.toString(),
          transaction.amount,
          transaction.category?.name ?? '',
          transaction.account.name,
          transaction.tags.map((t) => t.name).join(';'),
          transaction.notes,
          transaction.createdAt.toIso8601String(),
          transaction.updatedAt.toIso8601String(),
        ]]));
      }
      await transactionSink.close();
      
      // 导出账户信息
      final accountFile = File('$baseDir/accounts_$timestamp.csv');
      final accountSink = accountFile.openWrite();
      final accountCsv = ListToCsvConverter();
      
      accountSink.writeln(accountCsv.convert([
        ['ID', 'Name', 'Type', 'Currency', 'Balance', 'Notes', 'Created At', 'Updated At']
      ]));
      
      for (final account in data.accounts) {
        accountSink.writeln(accountCsv.convert([[
          account.id,
          account.name,
          account.type.toString(),
          account.currency,
          account.balance,
          account.notes,
          account.createdAt.toIso8601String(),
          account.updatedAt.toIso8601String(),
        ]]));
      }
      await accountSink.close();
      
      // 导出分类信息
      final categoryFile = File('$baseDir/categories_$timestamp.csv');
      final categorySink = categoryFile.openWrite();
      final categoryCsv = ListToCsvConverter();
      
      categorySink.writeln(categoryCsv.convert([
        ['ID', 'Name', 'Parent ID', 'Type', 'Icon', 'Created At', 'Updated At']
      ]));
      
      for (final category in data.categories) {
        categorySink.writeln(categoryCsv.convert([[
          category.id,
          category.name,
          category.parentId,
          category.type.toString(),
          category.icon,
          category.createdAt.toIso8601String(),
          category.updatedAt.toIso8601String(),
        ]]));
      }
      await categorySink.close();
      
      // 导出标签信息
      final tagFile = File('$baseDir/tags_$timestamp.csv');
      final tagSink = tagFile.openWrite();
      final tagCsv = ListToCsvConverter();
      
      tagSink.writeln(tagCsv.convert([
        ['ID', 'Name', 'Color', 'Created At', 'Updated At']
      ]));
      
      for (final tag in data.tags) {
        tagSink.writeln(tagCsv.convert([[
          tag.id,
          tag.name,
          tag.color,
          tag.createdAt.toIso8601String(),
          tag.updatedAt.toIso8601String(),
        ]]));
      }
      await tagSink.close();
      
      // 创建ZIP文件
      final zipFile = File('$baseDir/export_$timestamp.zip');
      final encoder = ZipEncoder();
      final archive = Archive();
      
      // 添加所有CSV文件到ZIP
      final files = [
        transactionFile,
        accountFile,
        categoryFile,
        tagFile,
      ];
      
      for (final file in files) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(
          file.path.split('/').last,
          bytes.length,
          bytes,
        ));
        // 删除临时CSV文件
        await file.delete();
      }
      
      // 保存ZIP文件
      final zipBytes = encoder.encode(archive);
      if (zipBytes != null) {
        await zipFile.writeAsBytes(zipBytes);
      }
      
      return zipFile.path;
    } catch (e) {
      logger.error('导出CSV失败：$e');
      rethrow;
    }
  }

  Future<String> _exportToJson(
    ExportData data,
    ExportOptions options,
  ) async {
    final filePath = '${exportDir.path}/export_$timestamp.json';
    final file = File(filePath);
    await file.writeAsString(jsonEncode(data.toJson()));
    return filePath;
  }

  Future<ExportData> _importFromFormat(
    String filePath,
    ImportOptions options,
    ValueChanged<ImportProgress>? onProgress,
  ) async {
    switch (options.format) {
      case ExportFormat.excel:
        return _importFromExcel(filePath, onProgress);
      case ExportFormat.csv:
        return _importFromCsv(filePath, onProgress);
      case ExportFormat.json:
        return _importFromJson(filePath, onProgress);
      case ExportFormat.pdf:
        throw UnimplementedError('PDF导入暂未实现');
    }
  }

  Future<ExportData> _importFromExcel(
    String filePath,
    ValueChanged<ImportProgress>? onProgress,
  ) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    List<Transaction>? transactions;
    List<Account>? accounts;

    // 读取交易记录
    if (excel.tables.containsKey('交易记录')) {
      final sheet = excel['交易记录'];
      final rows = sheet.rows;
      if (rows.length > 1) {
        transactions = [];
        for (var i = 1; i < rows.length; i++) {
          final row = rows[i];
          transactions.add(Transaction(
            id: row[0]?.value.toString() ?? '',
            type: TransactionType.values.firstWhere(
              (t) => t.toString() == row[1]?.value.toString(),
            ),
            amount: double.parse(row[2]?.value.toString() ?? '0'),
            accountId: row[3]?.value.toString() ?? '',
            toAccountId: row[4]?.value.toString().isEmpty
                ? null
                : row[4]?.value.toString(),
            categoryId: row[5]?.value.toString().isEmpty
                ? null
                : row[5]?.value.toString(),
            tagIds: row[6]?.value.toString().split('|'),
            date: DateTime.parse(row[7]?.value.toString() ?? ''),
            description: row[8]?.value.toString().isEmpty
                ? null
                : row[8]?.value.toString(),
            status: TransactionStatus.values.firstWhere(
              (s) => s.toString() == row[9]?.value.toString(),
            ),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
      }
    }

    // 读取账户信息
    if (excel.tables.containsKey('账户信息')) {
      final sheet = excel['账户信息'];
      final rows = sheet.rows;
      if (rows.length > 1) {
        accounts = [];
        for (var i = 1; i < rows.length; i++) {
          final row = rows[i];
          accounts.add(Account(
            id: row[0]?.value.toString() ?? '',
            name: row[1]?.value.toString() ?? '',
            type: AccountType.values.firstWhere(
              (t) => t.toString() == row[2]?.value.toString(),
            ),
            currency: row[3]?.value.toString() ?? '',
            balance: double.parse(row[4]?.value.toString() ?? '0'),
            status: AccountStatus.values.firstWhere(
              (s) => s.toString() == row[5]?.value.toString(),
            ),
            description: row[6]?.value.toString().isEmpty
                ? null
                : row[6]?.value.toString(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
      }
    }

    return ExportData(
      transactions: transactions,
      accounts: accounts,
      exportTime: DateTime.now(),
      version: APP_VERSION,
    );
  }

  Future<ExportData> _importFromCsv(
    String filePath,
    ValueChanged<ImportProgress>? onProgress,
  ) async {
    final content = await File(filePath).readAsString();
    final lines = content.split('\n');

    List<Transaction>? transactions;
    List<Account>? accounts;

    int currentSection = -1; // -1: 未知, 0: 交易记录, 1: 账户信息
    List<String> headers = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#')) {
        if (line.contains('交易记录')) {
          currentSection = 0;
          transactions = [];
        } else if (line.contains('账户信息')) {
          currentSection = 1;
          accounts = [];
        }
        continue;
      }

      if (line.startsWith('交易ID,') || line.startsWith('账户ID,')) {
        headers = line.split(',');
        continue;
      }

      final values = line.split(',');
      if (values.isEmpty) continue;

      switch (currentSection) {
        case 0: // 交易记录
          transactions?.add(Transaction(
            id: values[0],
            type: TransactionType.values.firstWhere(
              (t) => t.toString() == values[1],
            ),
            amount: double.parse(values[2]),
            accountId: values[3],
            toAccountId: values[4].isEmpty ? null : values[4],
            categoryId: values[5].isEmpty ? null : values[5],
            tagIds: values[6].split('|'),
            date: DateTime.parse(values[7]),
            description: values[8].isEmpty ? null : values[8],
            status: TransactionStatus.values.firstWhere(
              (s) => s.toString() == values[9],
            ),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
          break;
        case 1: // 账户信息
          accounts?.add(Account(
            id: values[0],
            name: values[1],
            type: AccountType.values.firstWhere(
              (t) => t.toString() == values[2],
            ),
            currency: values[3],
            balance: double.parse(values[4]),
            status: AccountStatus.values.firstWhere(
              (s) => s.toString() == values[5],
            ),
            description: values[6].isEmpty ? null : values[6],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
          break;
      }
    }

    return ExportData(
      transactions: transactions,
      accounts: accounts,
      exportTime: DateTime.now(),
      version: APP_VERSION,
    );
  }

  Future<ExportData> _importFromJson(
    String filePath,
    ValueChanged<ImportProgress>? onProgress,
  ) async {
    final content = await File(filePath).readAsString();
    return ExportData.fromJson(jsonDecode(content));
  }

  Future<void> _saveImportedData(
    ExportData data,
    ImportOptions options,
    ValueChanged<ImportProgress>? onProgress,
  ) async {
    final batch = database.batch();

    int totalItems = 0;
    int processedItems = 0;

    if (data.transactions != null) totalItems += data.transactions!.length;
    if (data.accounts != null) totalItems += data.accounts!.length;
    if (data.categories != null) totalItems += data.categories!.length;
    if (data.tags != null) totalItems += data.tags!.length;
    if (data.budgets != null) totalItems += data.budgets!.length;

    void updateProgress(String operation) {
      if (onProgress != null) {
        onProgress(ImportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: operation,
          progress: totalItems > 0 ? processedItems / totalItems : 0,
          warnings: [],
        ));
      }
    }

    // 保存账户信息
    if (data.accounts != null) {
      for (var account in data.accounts!) {
        if (options.overwriteExisting) {
          batch.delete('accounts', where: 'id = ?', whereArgs: [account.id]);
        }
        batch.insert('accounts', account.toMap());
        processedItems++;
        updateProgress('导入账户信息');
      }
    }

    // 保存分类信息
    if (data.categories != null) {
      for (var category in data.categories!) {
        if (options.overwriteExisting) {
          batch.delete('categories', where: 'id = ?', whereArgs: [category.id]);
        }
        batch.insert('categories', category.toMap());
        processedItems++;
        updateProgress('导入分类信息');
      }
    }

    // 保存标签信息
    if (data.tags != null) {
      for (var tag in data.tags!) {
        if (options.overwriteExisting) {
          batch.delete('tags', where: 'id = ?', whereArgs: [tag.id]);
        }
        batch.insert('tags', tag.toMap());
        processedItems++;
        updateProgress('导入标签信息');
      }
    }

    // 保存交易记录
    if (data.transactions != null) {
      for (var transaction in data.transactions!) {
        if (options.overwriteExisting) {
          batch.delete('transactions', where: 'id = ?', whereArgs: [transaction.id]);
        }
        batch.insert('transactions', transaction.toMap());
        processedItems++;
        updateProgress('导入交易记录');
      }
    }

    // 保存预算信息
    if (data.budgets != null) {
      for (var budget in data.budgets!) {
        if (options.overwriteExisting) {
          batch.delete('budgets', where: 'id = ?', whereArgs: [budget.id]);
        }
        batch.insert('budgets', budget.toMap());
        processedItems++;
        updateProgress('导入预算信息');
      }
    }

    await batch.commit();
  }

  Future<Directory> _prepareExportDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${appDir.path}/$EXPORT_FOLDER');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  Future<Directory> _prepareBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/$BACKUP_FOLDER');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<void> _encryptFile(String filePath, String password) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final encryptedBytes = await encryptionService.encrypt(bytes, password);
    await file.writeAsBytes(encryptedBytes);
  }

  Future<void> _decryptFile(String filePath, String password) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final decryptedBytes = await encryptionService.decrypt(bytes, password);
    await file.writeAsBytes(decryptedBytes);
  }

  // 数据查询方法

  Future<List<Transaction>> _getTransactions(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Account>> _getAccounts() async {
    final List<Map<String, dynamic>> maps = await database.query('accounts');
    return maps.map((map) => Account.fromMap(map)).toList();
  }

  Future<List<Category>> _getCategories() async {
    final List<Map<String, dynamic>> maps = await database.query('categories');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Tag>> _getTags() async {
    final List<Map<String, dynamic>> maps = await database.query('tags');
    return maps.map((map) => Tag.fromMap(map)).toList();
  }

  Future<List<Budget>> _getBudgets() async {
    final List<Map<String, dynamic>> maps = await database.query('budgets');
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  Future<void> _importFromCsv(String filePath, ImportOptions options, ValueChanged<ImportProgress>? onProgress) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('导入文件不存在');
      }

      // 如果是ZIP文件，先解压
      if (filePath.endsWith('.zip')) {
        final bytes = await file.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        // 创建临时目录
        final tempDir = await getTemporaryDirectory();
        final importDir = Directory('${tempDir.path}/import_${DateTime.now().millisecondsSinceEpoch}');
        await importDir.create();
        
        // 解压文件
        for (final file in archive.files) {
          if (file.isFile) {
            final data = file.content as List<int>;
            final filePath = '${importDir.path}/${file.name}';
            await File(filePath).writeAsBytes(data);
          }
        }
        
        // 读取各个CSV文件
        final files = await importDir.list().where((f) => f.path.endsWith('.csv')).toList();
        
        // 导入交易记录
        final transactionFile = files.firstWhere((f) => f.path.contains('transactions'), orElse: () => null);
        if (transactionFile != null) {
          final lines = await transactionFile.readAsLines();
          final header = lines.first.split(',');
          final transactions = lines.skip(1).map((line) {
            final values = line.split(',');
            return Transaction(
              id: values[header.indexOf('ID')],
              date: DateTime.parse(values[header.indexOf('Date')]),
              type: TransactionType.values.firstWhere((t) => t.toString() == values[header.indexOf('Type')]),
              amount: double.parse(values[header.indexOf('Amount')]),
              categoryId: values[header.indexOf('Category')],
              accountId: values[header.indexOf('Account')],
              tags: values[header.indexOf('Tags')].split(';').where((t) => t.isNotEmpty).toList(),
              notes: values[header.indexOf('Notes')],
              createdAt: DateTime.parse(values[header.indexOf('Created At')]),
              updatedAt: DateTime.parse(values[header.indexOf('Updated At')]),
            );
          }).toList();
          
          // 保存交易记录
          await _saveTransactions(transactions, options.overwriteExisting);
        }
        
        // 导入账户信息
        final accountFile = files.firstWhere((f) => f.path.contains('accounts'), orElse: () => null);
        if (accountFile != null) {
          final lines = await accountFile.readAsLines();
          final header = lines.first.split(',');
          final accounts = lines.skip(1).map((line) {
            final values = line.split(',');
            return Account(
              id: values[header.indexOf('ID')],
              name: values[header.indexOf('Name')],
              type: AccountType.values.firstWhere((t) => t.toString() == values[header.indexOf('Type')]),
              currency: values[header.indexOf('Currency')],
              balance: double.parse(values[header.indexOf('Balance')]),
              notes: values[header.indexOf('Notes')],
              createdAt: DateTime.parse(values[header.indexOf('Created At')]),
              updatedAt: DateTime.parse(values[header.indexOf('Updated At')]),
            );
          }).toList();
          
          // 保存账户信息
          await _saveAccounts(accounts, options.overwriteExisting);
        }
        
        // 导入分类信息
        final categoryFile = files.firstWhere((f) => f.path.contains('categories'), orElse: () => null);
        if (categoryFile != null) {
          final lines = await categoryFile.readAsLines();
          final header = lines.first.split(',');
          final categories = lines.skip(1).map((line) {
            final values = line.split(',');
            return Category(
              id: values[header.indexOf('ID')],
              name: values[header.indexOf('Name')],
              parentId: values[header.indexOf('Parent ID')],
              type: CategoryType.values.firstWhere((t) => t.toString() == values[header.indexOf('Type')]),
              icon: values[header.indexOf('Icon')],
              createdAt: DateTime.parse(values[header.indexOf('Created At')]),
              updatedAt: DateTime.parse(values[header.indexOf('Updated At')]),
            );
          }).toList();
          
          // 保存分类信息
          await _saveCategories(categories, options.overwriteExisting);
        }
        
        // 导入标签信息
        final tagFile = files.firstWhere((f) => f.path.contains('tags'), orElse: () => null);
        if (tagFile != null) {
          final lines = await tagFile.readAsLines();
          final header = lines.first.split(',');
          final tags = lines.skip(1).map((line) {
            final values = line.split(',');
            return Tag(
              id: values[header.indexOf('ID')],
              name: values[header.indexOf('Name')],
              color: values[header.indexOf('Color')],
              createdAt: DateTime.parse(values[header.indexOf('Created At')]),
              updatedAt: DateTime.parse(values[header.indexOf('Updated At')]),
            );
          }).toList();
          
          // 保存标签信息
          await _saveTags(tags, options.overwriteExisting);
        }
        
        // 清理临时文件
        await importDir.delete(recursive: true);
      } else {
        throw Exception('不支持的文件格式');
      }
    } catch (e) {
      logger.error('导入CSV失败：$e');
      rethrow;
    }
  }

  Future<void> _saveTransactions(List<Transaction> transactions, bool overwriteExisting) async {
    final batch = database.batch();
    
    for (final transaction in transactions) {
      if (overwriteExisting) {
        batch.insert(
          'transactions',
          transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        batch.insert(
          'transactions',
          transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    
    await batch.commit(noResult: true);
  }

  Future<void> _saveAccounts(List<Account> accounts, bool overwriteExisting) async {
    final batch = database.batch();
    
    for (final account in accounts) {
      if (overwriteExisting) {
        batch.insert(
          'accounts',
          account.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        batch.insert(
          'accounts',
          account.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    
    await batch.commit(noResult: true);
  }

  Future<void> _saveCategories(List<Category> categories, bool overwriteExisting) async {
    final batch = database.batch();
    
    for (final category in categories) {
      if (overwriteExisting) {
        batch.insert(
          'categories',
          category.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        batch.insert(
          'categories',
          category.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    
    await batch.commit(noResult: true);
  }

  Future<void> _saveTags(List<Tag> tags, bool overwriteExisting) async {
    final batch = database.batch();
    
    for (final tag in tags) {
      if (overwriteExisting) {
        batch.insert(
          'tags',
          tag.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        batch.insert(
          'tags',
          tag.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    
    await batch.commit(noResult: true);
  }
} 