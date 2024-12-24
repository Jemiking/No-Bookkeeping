import 'package:sqflite/sqflite.dart';
import '../domain/balance_adjustment.dart';
import '../../core/database/tables/balance_adjustments_table.dart';
import '../../core/utils/logger.dart';

class BalanceAdjustmentDao {
  final Database database;
  final Logger logger;

  BalanceAdjustmentDao({
    required this.database,
    required this.logger,
  });

  Future<void> insert(BalanceAdjustment adjustment) async {
    try {
      await database.insert(
        BalanceAdjustmentsTable.tableName,
        adjustment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      logger.info('余额调整记录已创建：${adjustment.id}');
    } catch (e) {
      logger.error('创建余额调整记录失败：$e');
      rethrow;
    }
  }

  Future<void> update(BalanceAdjustment adjustment) async {
    try {
      await database.update(
        BalanceAdjustmentsTable.tableName,
        adjustment.toMap(),
        where: 'id = ?',
        whereArgs: [adjustment.id],
      );
      logger.info('余额调整记录已更新：${adjustment.id}');
    } catch (e) {
      logger.error('更新余额调整记录失��：$e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await database.delete(
        BalanceAdjustmentsTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      logger.info('余额调整记录已删除：$id');
    } catch (e) {
      logger.error('删除余额调整记录失败：$e');
      rethrow;
    }
  }

  Future<BalanceAdjustment?> findById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        BalanceAdjustmentsTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }

      return BalanceAdjustment.fromMap(maps.first);
    } catch (e) {
      logger.error('查询余额调整记录失败：$e');
      rethrow;
    }
  }

  Future<List<BalanceAdjustment>> findByAccountId(String accountId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        BalanceAdjustmentsTable.tableName,
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => BalanceAdjustment.fromMap(map)).toList();
    } catch (e) {
      logger.error('查询账户余额调整记录失败：$e');
      rethrow;
    }
  }

  Future<List<BalanceAdjustment>> findPendingAdjustments() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        BalanceAdjustmentsTable.tableName,
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'created_at ASC',
      );

      return maps.map((map) => BalanceAdjustment.fromMap(map)).toList();
    } catch (e) {
      logger.error('查询待处理的余额调整记录失败：$e');
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status, String? approvedBy) async {
    try {
      await database.update(
        BalanceAdjustmentsTable.tableName,
        {
          'status': status,
          'approved_by': approvedBy,
          'applied_at': status == 'applied' ? DateTime.now().millisecondsSinceEpoch : null,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      logger.info('余额调整记录状态已更新：$id -> $status');
    } catch (e) {
      logger.error('更新余额调整记录状态失败：$e');
      rethrow;
    }
  }
} 