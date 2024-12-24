abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class TransactionException extends AppException {
  TransactionException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class MappingException extends AppException {
  MappingException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class AppDatabaseException implements Exception {
  final String message;
  final dynamic details;

  AppDatabaseException(this.message, {this.details});

  @override
  String toString() => 'AppDatabaseException: $message ${details ?? ''}';
} 