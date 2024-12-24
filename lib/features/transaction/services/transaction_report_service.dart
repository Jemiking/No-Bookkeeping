import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction.dart';
import 'transaction_statistics_service.dart';

class TransactionReportService {
  static const String REPORT_FOLDER = 'reports';

  // 生成PDF报表
  static Future<String> generatePDFReport(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
    String userId,
  ) async {
    try {
      final pdf = pw.Document();
      
      // 生成统计数据
      final statistics = TransactionStatisticsService.generateStatistics(
        transactions,
        startDate,
        endDate,
      );

      // 添加报表标题
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '交易报表',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('报表期间: ${_formatDate(startDate)} - ${_formatDate(endDate)}'),
              pw.SizedBox(height: 10),
              pw.Text('生成时间: ${_formatDate(DateTime.now())}'),
              pw.Divider(),
            ],
          ),
        ),
      );

      // 添加总览页面
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '总体概况',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildSummaryTable(statistics),
              pw.SizedBox(height: 20),
              _buildDistributionTable(
                '分类分布',
                statistics.categoryDistribution,
              ),
            ],
          ),
        ),
      );

      // 添加详细交易记录
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '交易明细',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildTransactionTable(transactions),
            ],
          ),
        ),
      );

      // 保存PDF文件
      final directory = await getApplicationDocumentsDirectory();
      final reportDir = Directory('${directory.path}/$REPORT_FOLDER');
      if (!await reportDir.exists()) {
        await reportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'transaction_report_$timestamp.pdf';
      final file = File('${reportDir.path}/$fileName');
      
      await file.writeAsBytes(await pdf.save());
      return file.path;
      
    } catch (e) {
      throw Exception('生成报表失败: $e');
    }
  }

  // 构建总览表格
  static pw.Widget _buildSummaryTable(TransactionStatistics statistics) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableCell('总收入', true),
            _buildTableCell('总支出', true),
            _buildTableCell('净额', true),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('¥${statistics.totalIncome.toStringAsFixed(2)}'),
            _buildTableCell('¥${statistics.totalExpense.toStringAsFixed(2)}'),
            _buildTableCell('¥${statistics.netAmount.toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }

  // 构建分布表格
  static pw.Widget _buildDistributionTable(
    String title,
    Map<String, double> distribution,
  ) {
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                _buildTableCell('项目', true),
                _buildTableCell('金额', true),
                _buildTableCell('占比', true),
              ],
            ),
            ...sortedEntries.map((entry) {
              final percentage = (entry.value / distribution.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1);
              return pw.TableRow(
                children: [
                  _buildTableCell(entry.key),
                  _buildTableCell('¥${entry.value.toStringAsFixed(2)}'),
                  _buildTableCell('$percentage%'),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  // 构建交易明细表格
  static pw.Widget _buildTransactionTable(List<Transaction> transactions) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableCell('日期', true),
            _buildTableCell('类型', true),
            _buildTableCell('金额', true),
            _buildTableCell('分类', true),
            _buildTableCell('描述', true),
          ],
        ),
        ...transactions.map((transaction) {
          return pw.TableRow(
            children: [
              _buildTableCell(_formatDate(transaction.date)),
              _buildTableCell(_formatTransactionType(transaction.type)),
              _buildTableCell('¥${transaction.amount.toStringAsFixed(2)}'),
              _buildTableCell(transaction.categoryId ?? '未分类'),
              _buildTableCell(transaction.description ?? ''),
            ],
          );
        }).toList(),
      ],
    );
  }

  // 构建表格单元格
  static pw.Widget _buildTableCell(String text, [bool isHeader = false]) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  // 格式化日期
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 格式化交易类型
  static String _formatTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return '收入';
      case TransactionType.expense:
        return '支出';
      case TransactionType.transfer:
        return '转账';
    }
  }
} 