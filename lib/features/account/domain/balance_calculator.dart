import 'account.dart';

abstract class BalanceCalculator {
  Future<double> calculateBalance(String accountId);
  Future<Map<String, double>> calculateBalances(List<String> accountIds);
  Future<double> calculateTotalBalance(String currency);
  Stream<double> watchBalance(String accountId);
  Stream<Map<String, double>> watchBalances(List<String> accountIds);
  Stream<double> watchTotalBalance(String currency);
} 