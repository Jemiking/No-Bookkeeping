import 'package:uuid/uuid.dart';
import '../data/balance_adjustment_dao.dart';
import 'balance_adjustment.dart';
import '../../core/utils/logger.dart';
import '../../core/exceptions/balance_calculation_exception.dart';

class BalanceAdjustmentService {
  final BalanceAdjustmentDao _dao;
  final Logger _logger;
  final Uuid _uuid;

  BalanceAdjustmentService({
    required BalanceAdjustmentDao dao,
    required Logger logger,
  }) : _dao = dao,
       _logger = logger,
       _uuid = const Uuid();

  Future<BalanceAdjustment> createAdjustment({
    required String accountId,
    required double amount,
    required String reason,
    required String createdBy,
    String? notes,
  }) async {
    try {
      final adjustment = BalanceAdjustment(
        id: _uuid.v4(),
        accountId: accountId,
        amount: amount,
        reason: reason,
        status: 'pending',
        createdAt: DateTime.now(),
        createdBy: createdBy,
        notes: notes,
      );

      await _dao.insert(adjustment);
      _logger.info('创建余额调整：$adjustment');
      return adjustment;
    } catch (e) {
      _logger.error('创建余额调整失败：$e');
      throw BalanceCalculationException('创建余额调整失败', e);
    }
  }

  Future<void> approveAdjustment({
    required String adjustmentId,
    required String approvedBy,
  }) async {
    try {
      final adjustment = await _dao.findById(adjustmentId);
      if (adjustment == null) {
        throw BalanceCalculationException('余额调整记录不存在');
      }

      if (adjustment.status != 'pending') {
        throw BalanceCalculationException('余额调整记录状态不正确：${adjustment.status}');
      }

      await _dao.updateStatus(adjustmentId, 'applied', approvedBy);
      _logger.info('余额调整已审批：$adjustmentId');
    } catch (e) {
      _logger.error('审批余额调整失败：$e');
      throw BalanceCalculationException('审批余额调整失败', e);
    }
  }

  Future<void> rejectAdjustment({
    required String adjustmentId,
    required String approvedBy,
  }) async {
    try {
      final adjustment = await _dao.findById(adjustmentId);
      if (adjustment == null) {
        throw BalanceCalculationException('余额调整记录不存在');
      }

      if (adjustment.status != 'pending') {
        throw BalanceCalculationException('余额调整记录状态不正确：${adjustment.status}');
      }

      await _dao.updateStatus(adjustmentId, 'rejected', approvedBy);
      _logger.info('余额调整已拒绝：$adjustmentId');
    } catch (e) {
      _logger.error('拒绝余额调整失败：$e');
      throw BalanceCalculationException('拒绝余额调整失败', e);
    }
  }

  Future<void> cancelAdjustment(String adjustmentId) async {
    try {
      final adjustment = await _dao.findById(adjustmentId);
      if (adjustment == null) {
        throw BalanceCalculationException('余额调整记录不存在');
      }

      if (adjustment.status != 'pending') {
        throw BalanceCalculationException('余额调整记录状态不正确：${adjustment.status}');
      }

      await _dao.updateStatus(adjustmentId, 'cancelled', null);
      _logger.info('余额调整已取消：$adjustmentId');
    } catch (e) {
      _logger.error('取消余额调整失败：$e');
      throw BalanceCalculationException('取消余额调整失败', e);
    }
  }

  Future<List<BalanceAdjustment>> getPendingAdjustments() async {
    try {
      return await _dao.findPendingAdjustments();
    } catch (e) {
      _logger.error('获取待处理的余额调整失败：$e');
      throw BalanceCalculationException('获取待处理的余额调整失败', e);
    }
  }

  Future<List<BalanceAdjustment>> getAccountAdjustments(String accountId) async {
    try {
      return await _dao.findByAccountId(accountId);
    } catch (e) {
      _logger.error('获取账户余额调整记录失败：$e');
      throw BalanceCalculationException('获取账户余额调整记录失败', e);
    }
  }
} 