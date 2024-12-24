import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/batch_operation.dart';
import '../services/batch_operation_service.dart';

final batchOperationServiceProvider = Provider<BatchOperationService>((ref) {
  throw UnimplementedError();
});

final batchOperationsProvider = StateNotifierProvider<BatchOperationsNotifier,
    AsyncValue<List<BatchOperation>>>((ref) {
  final service = ref.watch(batchOperationServiceProvider);
  return BatchOperationsNotifier(service);
});

final pendingBatchOperationsProvider = StateNotifierProvider<BatchOperationsNotifier,
    AsyncValue<List<BatchOperation>>>((ref) {
  final service = ref.watch(batchOperationServiceProvider);
  return BatchOperationsNotifier(service, onlyPending: true);
});

final selectedBatchOperationProvider =
    StateProvider<BatchOperation?>((ref) => null);

final batchOperationResultProvider = FutureProvider.family
    .autoDispose<BatchOperationResult?, String>((ref, batchId) async {
  final service = ref.watch(batchOperationServiceProvider);
  return await service.getBatchOperationResult(batchId);
});

class BatchOperationsNotifier
    extends StateNotifier<AsyncValue<List<BatchOperation>>> {
  final BatchOperationService _service;
  final bool onlyPending;

  BatchOperationsNotifier(this._service, {this.onlyPending = false})
      : super(const AsyncValue.loading()) {
    _loadBatchOperations();
  }

  Future<void> _loadBatchOperations() async {
    try {
      final operations = onlyPending
          ? await _service.getPendingBatchOperations()
          : await _service.getAllBatchOperations();
      state = AsyncValue.data(operations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadBatchOperations();
  }

  Future<String> createBatchOperation({
    required BatchOperationType type,
    required List<String> transactionIds,
    Map<String, dynamic>? updateData,
  }) async {
    try {
      final id = await _service.createBatchOperation(
        type: type,
        transactionIds: transactionIds,
        updateData: updateData,
      );
      await refresh();
      return id;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> executeBatchOperation(String id) async {
    try {
      await _service.executeBatchOperation(id);
      await refresh();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteBatchOperation(String id) async {
    try {
      await _service.deleteBatchOperation(id);
      await refresh();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }
}

class BatchOperationExecutor {
  final BatchOperationService _service;
  final void Function(String message)? onProgress;
  final void Function(String error)? onError;

  BatchOperationExecutor(
    this._service, {
    this.onProgress,
    this.onError,
  });

  Future<BatchOperationResult?> execute(BatchOperation operation) async {
    try {
      onProgress?.call('开始执行批量操作...');

      await _service.executeBatchOperation(operation.id);
      final result = await _service.getBatchOperationResult(operation.id);

      if (result == null) {
        onError?.call('批量操作执行失败：无法获取执行结果');
        return null;
      }

      final successCount = result.successfulIds.length;
      final failCount = result.failedIds.length;
      final totalCount = operation.transactionIds.length;

      onProgress?.call(
        '批量操作执行完成：\n'
        '成功：$successCount\n'
        '失败：$failCount\n'
        '总计：$totalCount',
      );

      if (failCount > 0) {
        final errorMessages = result.errors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('\n');
        onError?.call('部分操作失败：\n$errorMessages');
      }

      return result;
    } catch (e) {
      onError?.call('批量操作执行失败：${e.toString()}');
      return null;
    }
  }
} 