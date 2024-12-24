class BalanceCalculationException implements Exception {
  final String message;
  final dynamic cause;

  BalanceCalculationException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'BalanceCalculationException: $message\nCause: $cause';
    }
    return 'BalanceCalculationException: $message';
  }
} 