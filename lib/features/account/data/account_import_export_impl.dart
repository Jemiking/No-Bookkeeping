import 'dart:convert';
import 'package:csv/csv.dart';
import '../domain/account.dart';
import '../domain/account_import_export.dart';

class AccountImportExportImpl implements AccountImportExport {
  @override
  Future<String> exportToJson(List<Account> accounts) async {
    final List<Map<String, dynamic>> jsonList = accounts.map((a) => a.toJson()).toList();
    return jsonEncode(jsonList);
  }

  @override
  Future<String> exportToCsv(List<Account> accounts) async {
    final List<List<dynamic>> rows = [
      // Header
      ['ID', '名称', '类型', '币种', '余额', '状态', '描述', '创建时间', '更新时间'],
      // Data
      ...accounts.map((a) => [
        a.id,
        a.name,
        a.type.toString(),
        a.currency,
        a.balance,
        a.status.toString(),
        a.description ?? '',
        a.createdAt.toIso8601String(),
        a.updatedAt.toIso8601String(),
      ]),
    ];

    return const ListToCsvConverter().convert(rows);
  }

  @override
  Future<List<Account>> importFromJson(String jsonString) async {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Account.fromJson(json)).toList();
  }

  @override
  Future<List<Account>> importFromCsv(String csvString) async {
    final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
    
    if (rows.isEmpty) return [];
    
    // Skip header row
    return rows.skip(1).map((row) {
      return Account(
        id: row[0].toString(),
        name: row[1].toString(),
        type: AccountType.values.firstWhere(
          (t) => t.toString() == row[2].toString(),
        ),
        currency: row[3].toString(),
        balance: double.parse(row[4].toString()),
        status: AccountStatus.values.firstWhere(
          (s) => s.toString() == row[5].toString(),
        ),
        description: row[6].toString().isEmpty ? null : row[6].toString(),
        createdAt: DateTime.parse(row[7].toString()),
        updatedAt: DateTime.parse(row[8].toString()),
      );
    }).toList();
  }
} 