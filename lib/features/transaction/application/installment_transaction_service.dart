import '../domain/installment_transaction.dart';
import '../data/installment_transaction_repository.dart';
import '../data/transaction_repository.dart';

class InstallmentTransactionService {
  final InstallmentTransactionRepository _installmentRepository;
  final TransactionRepository _transactionRepository;

  InstallmentTransactionService(
    this._installmentRepository,
    this._transactionRepository,
  );

  Future<String> createInstallmentTransaction({
    required String accountId,
    required double totalAmount,
    required String currency,
    required int totalInstallments,
    required DateTime startDate,
    required String description,
    String? categoryId,
    List<String> tagIds = const [],
  }) async {
    final transaction = InstallmentTransaction.create(
      accountId: accountId,
      totalAmount: totalAmount,
      currency: currency,
      totalInstallments: totalInstallments,
      startDate: startDate,
      description: description,
      categoryId: categoryId,
      tagIds: tagIds,
    );

    return await _installmentRepository.create(transaction);
  }

  Future<InstallmentTransaction?> getInstallmentTransaction(String id) async {
    return await _installmentRepository.get(id);
  }

  Future<List<InstallmentTransaction>> getAllInstallmentTransactions() async {
    return await _installmentRepository.getAll();
  }

  Future<List<InstallmentTransaction>> getAccountInstallmentTransactions(String accountId) async {
    return await _installmentRepository.getAllByAccountId(accountId);
  }

  Future<void> updateInstallmentTransaction(InstallmentTransaction transaction) async {
    final updatedTransaction = transaction.copyWith(
      updatedAt: DateTime.now(),
    );
    await _installmentRepository.update(updatedTransaction);
  }

  Future<void> deleteInstallmentTransaction(String id) async {
    await _installmentRepository.delete(id);
  }

  Future<void> deactivateInstallmentTransaction(String id) async {
    await _installmentRepository.deactivate(id);
  }

  Future<void> generateDueInstallments(DateTime date) async {
    final dueInstallments = await _installmentRepository.getDueInstallments(date);
    
    for (final installment in dueInstallments) {
      if (installment.shouldGenerateTransaction(date)) {
        final transaction = installment.generateTransaction(date);
        await _transactionRepository.create(transaction);
        await _installmentRepository.decrementRemainingInstallments(installment.id);
      }
    }
  }

  Future<void> generateInstallmentsForDateRange(DateTime start, DateTime end) async {
    final activeInstallments = await _installmentRepository.getActive();
    
    for (final installment in activeInstallments) {
      var currentDate = installment.startDate;
      while (currentDate.isBefore(end)) {
        if (currentDate.isAfter(start) && installment.shouldGenerateTransaction(currentDate)) {
          final transaction = installment.generateTransaction(currentDate);
          await _transactionRepository.create(transaction);
          await _installmentRepository.decrementRemainingInstallments(installment.id);
        }
        currentDate = installment.getNextInstallmentDate(currentDate);
      }
    }
  }

  Future<List<DateTime>> getNextInstallmentDates(String installmentId, int count) async {
    final installment = await _installmentRepository.get(installmentId);
    if (installment == null || !installment.isActive || installment.remainingInstallments <= 0) {
      return [];
    }

    final dates = <DateTime>[];
    var currentDate = installment.startDate;
    var remainingCount = count;

    while (remainingCount > 0 && dates.length < installment.remainingInstallments) {
      dates.add(currentDate);
      currentDate = installment.getNextInstallmentDate(currentDate);
      remainingCount--;
    }

    return dates;
  }

  Future<double> calculateRemainingAmount(String installmentId) async {
    final installment = await _installmentRepository.get(installmentId);
    if (installment == null) return 0;
    return installment.installmentAmount * installment.remainingInstallments;
  }

  Future<double> calculatePaidAmount(String installmentId) async {
    final installment = await _installmentRepository.get(installmentId);
    if (installment == null) return 0;
    return installment.totalAmount - (installment.installmentAmount * installment.remainingInstallments);
  }
} 