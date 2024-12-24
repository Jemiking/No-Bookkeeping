import '../data/batch_operation_repository.dart';
import '../domain/batch_operation.dart';
import '../domain/transaction.dart';
import 'transaction_service.dart';

class BatchOperationService {
  final BatchOperationRepository _repository;
  final TransactionService _transactionService;

  BatchOperationService(this._repository, this._transactionService);

  Future<String> createBatchOperation({
    required BatchOperationType type,
    required List<String> transactionIds,
    Map<String, dynamic>? updateData,
  }) async {
    final operation = BatchOperation.createBatchOperation(
      type: type,
      transactionIds: transactionIds,
      updateData: updateData,
    );
    return await _repository.create(operation);
  }

  Future<BatchOperation?> getBatchOperation(String id) async {
    return await _repository.get(id);
  }

  Future<List<BatchOperation>> getAllBatchOperations() async {
    return await _repository.getAll();
  }

  Future<List<BatchOperation>> getPendingBatchOperations() async {
    return await _repository.getPending();
  }

  Future<void> executeBatchOperation(String id) async {
    final operation = await _repository.get(id);
    if (operation == null) {
      throw Exception('Batch operation not found');
    }

    if (operation.isCompleted) {
      throw Exception('Batch operation already completed');
    }

    final successfulIds = <String>[];
    final failedIds = <String>[];
    final errors = <String, String>{};

    try {
      switch (operation.type) {
        case BatchOperationType.delete:
          await _executeDeleteOperation(
            operation,
            successfulIds,
            failedIds,
            errors,
          );
          break;
        case BatchOperationType.update:
          await _executeUpdateOperation(
            operation,
            successfulIds,
            failedIds,
            errors,
          );
          break;
        case BatchOperationType.archive:
          await _executeArchiveOperation(
            operation,
            successfulIds,
            failedIds,
            errors,
          );
          break;
        case BatchOperationType.unarchive:
          await _executeUnarchiveOperation(
            operation,
            successfulIds,
            failedIds,
            errors,
          );
          break;
        case BatchOperationType.changeCategory:
          await _executeChangeCategoryOperation(
            operation,
            successfulIds,
            failedIds,
            errors,
          );
          break;
        case BatchOperationType.changeAccount:
          await _executeChangeAccountOperation(
            operation,
            successfulIds,
            failedIds,
            errors,
          );
          break;
        case BatchOperationType.addTags:
          await _executeAddTagsOperation(
            operation,
            successfulIds,
            failedIds,
            errors,
          );
          break;
        case BatchOperationType.removeTags:
          await _executeRemoveTagsOperation(
            operation,
            successfulIds,
            failedIds,
            errors,
          );
          break;
      }

      final result = BatchOperationResult(
        batchId: operation.id,
        isSuccess: failedIds.isEmpty,
        successfulIds: successfulIds,
        failedIds: failedIds,
        errors: errors,
      );

      await _repository.saveResult(result);
      await _repository.markAsCompleted(operation.id);
    } catch (e) {
      await _repository.markAsCompleted(operation.id, error: e.toString());
      rethrow;
    }
  }

  Future<void> _executeDeleteOperation(
    BatchOperation operation,
    List<String> successfulIds,
    List<String> failedIds,
    Map<String, String> errors,
  ) async {
    for (final id in operation.transactionIds) {
      try {
        await _transactionService.deleteTransaction(id);
        successfulIds.add(id);
      } catch (e) {
        failedIds.add(id);
        errors[id] = e.toString();
      }
    }
  }

  Future<void> _executeUpdateOperation(
    BatchOperation operation,
    List<String> successfulIds,
    List<String> failedIds,
    Map<String, String> errors,
  ) async {
    if (operation.updateData == null) {
      throw Exception('Update data is required for update operation');
    }

    for (final id in operation.transactionIds) {
      try {
        final transaction = await _transactionService.getTransaction(id);
        if (transaction == null) {
          failedIds.add(id);
          errors[id] = 'Transaction not found';
          continue;
        }

        final updatedTransaction = transaction.copyWith(
          // Apply update data to transaction
          // This is a simplified example, actual implementation would need to handle
          // all possible update fields
          amount: operation.updateData!['amount'] as double?,
          description: operation.updateData!['description'] as String?,
          date: operation.updateData!['date'] != null
              ? DateTime.parse(operation.updateData!['date'] as String)
              : null,
        );

        await _transactionService.updateTransaction(updatedTransaction);
        successfulIds.add(id);
      } catch (e) {
        failedIds.add(id);
        errors[id] = e.toString();
      }
    }
  }

  Future<void> _executeArchiveOperation(
    BatchOperation operation,
    List<String> successfulIds,
    List<String> failedIds,
    Map<String, String> errors,
  ) async {
    for (final id in operation.transactionIds) {
      try {
        final transaction = await _transactionService.getTransaction(id);
        if (transaction == null) {
          failedIds.add(id);
          errors[id] = 'Transaction not found';
          continue;
        }

        final updatedTransaction = transaction.copyWith(isArchived: true);
        await _transactionService.updateTransaction(updatedTransaction);
        successfulIds.add(id);
      } catch (e) {
        failedIds.add(id);
        errors[id] = e.toString();
      }
    }
  }

  Future<void> _executeUnarchiveOperation(
    BatchOperation operation,
    List<String> successfulIds,
    List<String> failedIds,
    Map<String, String> errors,
  ) async {
    for (final id in operation.transactionIds) {
      try {
        final transaction = await _transactionService.getTransaction(id);
        if (transaction == null) {
          failedIds.add(id);
          errors[id] = 'Transaction not found';
          continue;
        }

        final updatedTransaction = transaction.copyWith(isArchived: false);
        await _transactionService.updateTransaction(updatedTransaction);
        successfulIds.add(id);
      } catch (e) {
        failedIds.add(id);
        errors[id] = e.toString();
      }
    }
  }

  Future<void> _executeChangeCategoryOperation(
    BatchOperation operation,
    List<String> successfulIds,
    List<String> failedIds,
    Map<String, String> errors,
  ) async {
    if (operation.updateData == null ||
        !operation.updateData!.containsKey('categoryId')) {
      throw Exception('Category ID is required for change category operation');
    }

    final categoryId = operation.updateData!['categoryId'] as String;

    for (final id in operation.transactionIds) {
      try {
        final transaction = await _transactionService.getTransaction(id);
        if (transaction == null) {
          failedIds.add(id);
          errors[id] = 'Transaction not found';
          continue;
        }

        final updatedTransaction = transaction.copyWith(categoryId: categoryId);
        await _transactionService.updateTransaction(updatedTransaction);
        successfulIds.add(id);
      } catch (e) {
        failedIds.add(id);
        errors[id] = e.toString();
      }
    }
  }

  Future<void> _executeChangeAccountOperation(
    BatchOperation operation,
    List<String> successfulIds,
    List<String> failedIds,
    Map<String, String> errors,
  ) async {
    if (operation.updateData == null ||
        !operation.updateData!.containsKey('accountId')) {
      throw Exception('Account ID is required for change account operation');
    }

    final accountId = operation.updateData!['accountId'] as String;

    for (final id in operation.transactionIds) {
      try {
        final transaction = await _transactionService.getTransaction(id);
        if (transaction == null) {
          failedIds.add(id);
          errors[id] = 'Transaction not found';
          continue;
        }

        final updatedTransaction = transaction.copyWith(accountId: accountId);
        await _transactionService.updateTransaction(updatedTransaction);
        successfulIds.add(id);
      } catch (e) {
        failedIds.add(id);
        errors[id] = e.toString();
      }
    }
  }

  Future<void> _executeAddTagsOperation(
    BatchOperation operation,
    List<String> successfulIds,
    List<String> failedIds,
    Map<String, String> errors,
  ) async {
    if (operation.updateData == null || !operation.updateData!.containsKey('tags')) {
      throw Exception('Tags are required for add tags operation');
    }

    final tagsToAdd = List<String>.from(operation.updateData!['tags']);

    for (final id in operation.transactionIds) {
      try {
        final transaction = await _transactionService.getTransaction(id);
        if (transaction == null) {
          failedIds.add(id);
          errors[id] = 'Transaction not found';
          continue;
        }

        final currentTags = Set<String>.from(transaction.tags ?? []);
        currentTags.addAll(tagsToAdd);

        final updatedTransaction = transaction.copyWith(
          tags: currentTags.toList(),
        );
        await _transactionService.updateTransaction(updatedTransaction);
        successfulIds.add(id);
      } catch (e) {
        failedIds.add(id);
        errors[id] = e.toString();
      }
    }
  }

  Future<void> _executeRemoveTagsOperation(
    BatchOperation operation,
    List<String> successfulIds,
    List<String> failedIds,
    Map<String, String> errors,
  ) async {
    if (operation.updateData == null || !operation.updateData!.containsKey('tags')) {
      throw Exception('Tags are required for remove tags operation');
    }

    final tagsToRemove = Set<String>.from(operation.updateData!['tags']);

    for (final id in operation.transactionIds) {
      try {
        final transaction = await _transactionService.getTransaction(id);
        if (transaction == null) {
          failedIds.add(id);
          errors[id] = 'Transaction not found';
          continue;
        }

        final currentTags = Set<String>.from(transaction.tags ?? []);
        currentTags.removeAll(tagsToRemove);

        final updatedTransaction = transaction.copyWith(
          tags: currentTags.toList(),
        );
        await _transactionService.updateTransaction(updatedTransaction);
        successfulIds.add(id);
      } catch (e) {
        failedIds.add(id);
        errors[id] = e.toString();
      }
    }
  }

  Future<BatchOperationResult?> getBatchOperationResult(String batchId) async {
    return await _repository.getResult(batchId);
  }

  Future<void> deleteBatchOperation(String id) async {
    await _repository.delete(id);
    await _repository.deleteResult(id);
  }
} 