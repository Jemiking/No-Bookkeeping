import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../../../core/security/security_validator.dart';
import '../../../core/security/security_logger.dart';

class TransactionImportExportService {
  static const String EXPORT_FOLDER = 'exports';
  static const String CSV_HEADER = 'ID,类型,金额,账户ID,目标账户ID,分类ID,标签IDs,日期,描述,状态,创建时间,更新时间';

  // 导出交易记录到CSV
  static Future<String> exportToCSV(
    List<Transaction> transactions,
    String userId,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/$EXPORT_FOLDER');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'transactions_$timestamp.csv';
      final file = File('${exportDir.path}/$fileName');

      // 准备CSV数据
      List<List<dynamic>> csvData = [
        CSV_HEADER.split(','),
      ];

      // 添加交易数据
      for (var transaction in transactions) {
        csvData.add([
          transaction.id,
          transaction.type.toString(),
          transaction.amount,
          transaction.accountId,
          transaction.toAccountId ?? '',
          transaction.categoryId ?? '',
          transaction.tagIds.join('|'),
          transaction.date.toIso8601String(),
          transaction.description ?? '',
          transaction.status.toString(),
          transaction.createdAt.toIso8601String(),
          transaction.updatedAt.toIso8601String(),
        ]);
      }

      // 生成CSV内容
      String csvContent = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csvContent);

      // 记录导出事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'TRANSACTION_EXPORT',
        userId: userId,
        operation: 'EXPORT_TO_CSV',
        details: {
          'fileName': fileName,
          'recordCount': transactions.length,
        },
      );

      return file.path;
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  // 从CSV导入交易记录
  static Future<List<Transaction>> importFromCSV(
    String filePath,
    String userId,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      final content = await file.readAsString();
      List<List<dynamic>> csvData = const CsvToListConverter().convert(content);

      // 验证CSV格式
      if (csvData.isEmpty || csvData[0].join(',') != CSV_HEADER) {
        throw Exception('无效的CSV格式');
      }

      // 解析交易数据
      List<Transaction> transactions = [];
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        try {
          final transaction = Transaction(
            id: row[0].toString(),
            type: TransactionType.values.firstWhere(
              (e) => e.toString() == row[1].toString(),
            ),
            amount: double.parse(row[2].toString()),
            accountId: row[3].toString(),
            toAccountId: row[4].toString().isEmpty ? null : row[4].toString(),
            categoryId: row[5].toString().isEmpty ? null : row[5].toString(),
            tagIds: row[6].toString().split('|').where((id) => id.isNotEmpty).toList(),
            date: DateTime.parse(row[7].toString()),
            description: row[8].toString().isEmpty ? null : row[8].toString(),
            status: TransactionStatus.values.firstWhere(
              (e) => e.toString() == row[9].toString(),
            ),
            createdAt: DateTime.parse(row[10].toString()),
            updatedAt: DateTime.parse(row[11].toString()),
          );
          transactions.add(transaction);
        } catch (e) {
          throw Exception('第${i + 1}行数据格式错误: $e');
        }
      }

      // 记录导入事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'TRANSACTION_IMPORT',
        userId: userId,
        operation: 'IMPORT_FROM_CSV',
        details: {
          'fileName': filePath.split('/').last,
          'recordCount': transactions.length,
        },
      );

      return transactions;
    } catch (e) {
      throw Exception('导入失败: $e');
    }
  }

  // 导出交易记录到JSON
  static Future<String> exportToJSON(
    List<Transaction> transactions,
    String userId,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/$EXPORT_FOLDER');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'transactions_$timestamp.json';
      final file = File('${exportDir.path}/$fileName');

      // 准备JSON数据
      final jsonData = {
        'version': '1.0',
        'exportTime': DateTime.now().toIso8601String(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

      // 生成JSON内容
      await file.writeAsString(jsonEncode(jsonData));

      // 记录导出事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'TRANSACTION_EXPORT',
        userId: userId,
        operation: 'EXPORT_TO_JSON',
        details: {
          'fileName': fileName,
          'recordCount': transactions.length,
        },
      );

      return file.path;
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  // 从JSON导入交易记录
  static Future<List<Transaction>> importFromJSON(
    String filePath,
    String userId,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      final content = await file.readAsString();
      final jsonData = jsonDecode(content);

      // 验证JSON格式
      if (!jsonData.containsKey('version') || !jsonData.containsKey('transactions')) {
        throw Exception('无效的JSON格式');
      }

      // 解析交易数据
      List<Transaction> transactions = [];
      for (var transactionData in jsonData['transactions']) {
        try {
          final transaction = Transaction.fromJson(transactionData);
          transactions.add(transaction);
        } catch (e) {
          throw Exception('交易数据格式错误: $e');
        }
      }

      // 记录导入事件
      await SecurityLogger.logSecurityEvent(
        eventType: 'TRANSACTION_IMPORT',
        userId: userId,
        operation: 'IMPORT_FROM_JSON',
        details: {
          'fileName': filePath.split('/').last,
          'recordCount': transactions.length,
        },
      );

      return transactions;
    } catch (e) {
      throw Exception('导入失败: $e');
    }
  }

  // 验证导入数据
  static Future<bool> validateImportData(
    List<Transaction> transactions,
    String userId,
  ) async {
    try {
      // 验证数据量
      if (transactions.isEmpty) {
        throw Exception('没有要导入的数据');
      }

      // 验证重复ID
      final ids = transactions.map((t) => t.id).toSet();
      if (ids.length != transactions.length) {
        throw Exception('存在重复的交易ID');
      }

      // 验证金额
      for (var transaction in transactions) {
        if (!SecurityValidator.validateLargeAmount(transaction.amount)) {
          throw Exception('交易金额超过限制: ${transaction.id}');
        }
      }

      return true;
    } catch (e) {
      await SecurityLogger.logSecurityEvent(
        eventType: 'TRANSACTION_IMPORT_VALIDATION',
        userId: userId,
        operation: 'VALIDATE_IMPORT_DATA',
        details: {
          'error': e.toString(),
          'recordCount': transactions.length,
        },
      );
      return false;
    }
  }
} 