class ValidationException implements Exception {
  final String message;
  final dynamic invalidValue;
  final String? paramName;
  final StackTrace? stackTrace;

  ValidationException(
    this.message, {
    this.invalidValue,
    this.paramName,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ValidationException: $message');
    if (paramName != null) {
      buffer.write('\nParameter: $paramName');
    }
    if (invalidValue != null) {
      buffer.write('\nInvalid value: $invalidValue');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    return buffer.toString();
  }
} 