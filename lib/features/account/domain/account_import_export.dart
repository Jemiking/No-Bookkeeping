import 'account.dart';

abstract class AccountImportExport {
  Future<String> exportToJson(List<Account> accounts);
  Future<String> exportToCsv(List<Account> accounts);
  Future<List<Account>> importFromJson(String jsonString);
  Future<List<Account>> importFromCsv(String csvString);
} 