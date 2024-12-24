class StorageError implements Exception {
  final String code;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  StorageError({
    required this.code,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('StorageError: [$code] $message');
    
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    
    if (stackTrace != null) {
      buffer.write('\nStack trace:\n$stackTrace');
    }
    
    return buffer.toString();
  }
} 