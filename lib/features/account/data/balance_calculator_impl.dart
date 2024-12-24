import 'package:sqflite/sqflite.dart';
import '../domain/account.dart';
import '../domain/balance_calculator.dart';
import '../domain/currency_converter.dart';
import '../../core/exceptions/balance_calculation_exception.dart';
import '../../core/utils/logger.dart';

class BalanceCalculatorImpl implements BalanceCalculator {
  final Database database;
  final CurrencyConverter currencyConverter;
  final Logger logger;

  BalanceCalculatorImpl({
    required this.database,
    required this.currencyConverter,
    required this.logger,
  });

  @override
  Future<double> calculateBalance(String accountId) async {
    try {
      final List<Map<String, dynamic>> result = await database.rawQuery('''
        WITH account_balance AS (
          SELECT 
            COALESCE(
              (SELECT balance FROM accounts WHERE id = ? AND status = 'active'),
              0
            ) as initial_balance
        ),
        transaction_balance AS (
          SELECT 
            COALESCE(
              SUM(
                CASE 
                  WHEN type = 'income' THEN amount 
                  WHEN type = 'expense' THEN -amount
                  WHEN type = 'transfer_in' THEN amount
                  WHEN type = 'transfer_out' THEN -amount
                  ELSE 0
                END
              ),
              0
            ) as transaction_sum
          FROM transactions 
          WHERE account_id = ? 
            AND status = 'completed'
            AND is_deleted = 0
        ),
        adjustment_balance AS (
          SELECT 
            COALESCE(
              SUM(amount),
              0
            ) as adjustment_sum
          FROM balance_adjustments
          WHERE account_id = ?
            AND status = 'applied'
        )
        SELECT 
          ab.initial_balance + tb.transaction_sum + adj.adjustment_sum as total_balance
        FROM account_balance ab
        CROSS JOIN transaction_balance tb
        CROSS JOIN adjustment_balance adj
      ''', [accountId, accountId, accountId]);

      if (result.isEmpty) {
        throw BalanceCalculationException('无法计算账户余额：账户不存在或已停用');
      }

      final totalBalance = result.first['total_balance'] as double;
      logger.info('账户 $accountId 的余额计算完成：$totalBalance');
      return totalBalance;
    } catch (e) {
      logger.error('计算账户 $accountId 余额时发生错误：$e');
      throw BalanceCalculationException('计算余额失败：$e');
    }
  }

  @override
  Future<Map<String, double>> calculateBalances(List<String> accountIds) async {
    try {
      final Map<String, double> balances = {};
      await Future.wait(
        accountIds.map((id) async {
          balances[id] = await calculateBalance(id);
        })
      );
      return balances;
    } catch (e) {
      logger.error('批量计算账户余额时发生错误：$e');
      throw BalanceCalculationException('批量计算余额失败：$e');
    }
  }

  @override
  Future<double> calculateTotalBalance(String currency) async {
    try {
      final List<Map<String, dynamic>> accounts = await database.query(
        'accounts',
        columns: ['id', 'currency', 'balance'],
        where: 'status = ?',
        whereArgs: ['active'],
      );

      double totalBalance = 0;
      await Future.wait(
        accounts.map((account) async {
          final accountCurrency = account['currency'] as String;
          final accountBalance = await calculateBalance(account['id'] as String);
          
          if (accountCurrency == currency) {
            totalBalance += accountBalance;
          } else {
            final convertedBalance = await currencyConverter.convert(
              amount: accountBalance,
              fromCurrency: accountCurrency,
              toCurrency: currency,
              date: DateTime.now(),
            );
            totalBalance += convertedBalance;
          }
        })
      );

      logger.info('总资产（$currency）计算完成：$totalBalance');
      return totalBalance;
    } catch (e) {
      logger.error('计算总资产时发生错误：$e');
      throw BalanceCalculationException('计算总资产失败：$e');
    }
  }

  @override
  Stream<double> watchBalance(String accountId) async* {
    try {
      while (true) {
        yield await calculateBalance(accountId);
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      logger.error('监听账户 $accountId 余额时发生错误：$e');
      throw BalanceCalculationException('监听余额失败：$e');
    }
  }

  @override
  Stream<Map<String, double>> watchBalances(List<String> accountIds) async* {
    try {
      while (true) {
        yield await calculateBalances(accountIds);
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      logger.error('批量监听账户余额时发生错误：$e');
      throw BalanceCalculationException('批量监听余额失败：$e');
    }
  }

  @override
  Stream<double> watchTotalBalance(String currency) async* {
    try {
      while (true) {
        yield await calculateTotalBalance(currency);
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      logger.error('监听总资产时发生错误：$e');
      throw BalanceCalculationException('监听总资产失败：$e');
    }
  }
} 